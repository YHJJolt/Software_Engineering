using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class ManageAttendance : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            if (Request.QueryString["id"] == null) Response.Redirect("~/Lecturer/LecturerDashboard.aspx");

            if (this.Master is LecturerCourseMaster)
            {
                ((LecturerCourseMaster)this.Master).PageTitle = "Manage Attendance";
            }

            if (!IsPostBack)
            {
                // Default the session date to today
                txtAttendanceDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadStudentAttendance();
            }
        }

        // Returns the lecturer-selected session date, falling back to today if empty/invalid
        private DateTime GetSelectedDate()
        {
            DateTime selectedDate;
            if (!DateTime.TryParse(txtAttendanceDate.Text, out selectedDate))
            {
                selectedDate = DateTime.Today;
                txtAttendanceDate.Text = selectedDate.ToString("yyyy-MM-dd");
            }
            return selectedDate;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // Reload the grid based on the newly selected filters
            LoadStudentAttendance();
        }

        protected void txtAttendanceDate_TextChanged(object sender, EventArgs e)
        {
            // Reload the grid showing the saved attendance for the newly selected date
            lblSuccessMsg.Visible = false;
            LoadStudentAttendance();
        }

        private void LoadStudentAttendance()
        {
            string courseId = Request.QueryString["id"];
            DateTime selectedDate = GetSelectedDate();
            litSelectedDate.Text = selectedDate.ToString("dd MMM yyyy");

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Joins AttendanceRecord on the selected date so the dropdown shows what was
                // already saved for that day (and can be changed and re-saved).
                string sql = @"
                    WITH AttendanceData AS (
                        SELECT
                            e.Enrollment_id,
                            s.student_code,
                            s.student_name,
                            ISNULL(cg.total_hours, 0) AS total_hours,       
                            ISNULL(cg.attended_hours, 0) AS attended_hours, 
                            ISNULL(ar.status, 'NotMarked') AS day_status,   
                            CASE
                                WHEN ISNULL(cg.total_hours, 0) = 0 THEN 0.0
                                ELSE (CAST(ISNULL(cg.attended_hours, 0) AS FLOAT) / CAST(cg.total_hours AS FLOAT)) * 100
                            END as AttendancePercentage
                        FROM Enrollment e
                        JOIN Student s ON e.student_id = s.student_id
                        LEFT JOIN CourseGrade cg ON e.enrollment_id = cg.Enrollment_id
                        LEFT JOIN AttendanceRecord ar ON e.enrollment_id = ar.enrollment_id AND ar.attendance_date = @Date
                        WHERE e.course_id = @CourseID
                          AND e.status = 'Approved'
                          AND (@Session = '' OR e.academic_session = @Session)
                    )
                    SELECT * FROM AttendanceData
                    WHERE (
                           (@Filter = 'All')
                           OR (@Filter = 'High' AND AttendancePercentage >= 75.0)
                           OR (@Filter = 'Low' AND AttendancePercentage < 75.0)
                          )
                      AND (student_name LIKE '%' + @Search + '%' OR student_code LIKE '%' + @Search + '%')
                    ORDER BY student_name ASC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseID", courseId);
                cmd.Parameters.AddWithValue("@Session", Request.QueryString["session"] ?? "");
                cmd.Parameters.AddWithValue("@Filter", ddlAttendanceFilter.SelectedValue);
                cmd.Parameters.AddWithValue("@Search", txtSearch.Text.Trim());
                cmd.Parameters.AddWithValue("@Date", selectedDate.Date);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptAttendance.DataSource = dt;
                rptAttendance.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblSuccessMsg.Visible = false;
            DateTime selectedDate = GetSelectedDate();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                foreach (RepeaterItem item in rptAttendance.Items)
                {
                    if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
                    {
                        HiddenField hfEnrollmentId = (HiddenField)item.FindControl("hfEnrollmentId");
                        DropDownList ddlStatus = (DropDownList)item.FindControl("ddlStatus");

                        int enrollmentId = Convert.ToInt32(hfEnrollmentId.Value);
                        string status = ddlStatus.SelectedValue;

                        // Upsert (or remove) the mark for this student on the selected date,
                        // then recompute the aggregate hours from AttendanceRecord so editing
                        // a past date keeps the totals accurate (2 hours per session).
                        string sql = @"
                            IF @Status = 'NotMarked'
                            BEGIN
                                DELETE FROM AttendanceRecord
                                WHERE enrollment_id = @EnrollID AND attendance_date = @Date;
                            END
                            ELSE
                            BEGIN
                                MERGE INTO AttendanceRecord AS target
                                USING (SELECT @EnrollID AS enrollment_id, @Date AS attendance_date) AS source
                                    ON target.enrollment_id = source.enrollment_id
                                   AND target.attendance_date = source.attendance_date
                                WHEN MATCHED THEN
                                    UPDATE SET status = @Status
                                WHEN NOT MATCHED THEN
                                    INSERT (enrollment_id, attendance_date, status)
                                    VALUES (@EnrollID, @Date, @Status);
                            END

                            DECLARE @Total INT = (SELECT COUNT(*) * 2 FROM AttendanceRecord WHERE enrollment_id = @EnrollID);
                            DECLARE @Attended INT = (SELECT COUNT(*) * 2 FROM AttendanceRecord WHERE enrollment_id = @EnrollID AND status = 'Present');

                            IF EXISTS (SELECT 1 FROM CourseGrade WHERE Enrollment_id = @EnrollID)
                            BEGIN
                                UPDATE CourseGrade
                                SET total_hours = @Total,
                                    attended_hours = @Attended
                                WHERE Enrollment_id = @EnrollID
                            END
                            ELSE
                            BEGIN
                                INSERT INTO CourseGrade (Enrollment_id, total_hours, attended_hours)
                                VALUES (@EnrollID, @Total, @Attended)
                            END";

                        SqlCommand cmd = new SqlCommand(sql, conn);
                        cmd.Parameters.AddWithValue("@EnrollID", enrollmentId);
                        cmd.Parameters.AddWithValue("@Status", status);
                        cmd.Parameters.AddWithValue("@Date", selectedDate.Date);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            lblSuccessMsg.Text = "<i class='fas fa-check-circle'></i> Attendance for " + selectedDate.ToString("dd MMM yyyy") + " saved successfully!";
            lblSuccessMsg.Visible = true;

            LoadStudentAttendance();
        }
    }
}