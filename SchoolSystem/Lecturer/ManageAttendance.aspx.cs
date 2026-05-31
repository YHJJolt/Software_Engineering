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
                LoadStudentAttendance();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // Reload the grid based on the newly selected filters
            LoadStudentAttendance();
        }

        private void LoadStudentAttendance()
        {
            string courseId = Request.QueryString["id"];

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Added enrolled_semester check AND fixed the search/filter grouping logic
                string sql = @"
            WITH AttendanceData AS (
                SELECT 
                    e.Enrollment_id,
                    s.student_code, 
                    s.student_name,
                    cg.total_hours,
                    cg.attended_hours,
                    CASE 
                        WHEN ISNULL(cg.total_hours, 0) = 0 THEN 0.0
                        ELSE (CAST(ISNULL(cg.attended_hours, 0) AS FLOAT) / CAST(cg.total_hours AS FLOAT)) * 100 
                    END as AttendancePercentage
                FROM Enrollment e
                JOIN Student s ON e.student_id = s.student_id
                LEFT JOIN CourseGrade cg ON e.enrollment_id = cg.Enrollment_id
                WHERE e.course_id = @CourseID 
                  AND e.status = 'Approved'
                  AND e.enrolled_semester = s.student_sem -- <--- Filters out past students
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
                cmd.Parameters.AddWithValue("@Filter", ddlAttendanceFilter.SelectedValue);
                cmd.Parameters.AddWithValue("@Search", txtSearch.Text.Trim());

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
                        int hoursToAdd = (ddlStatus.SelectedValue == "Present") ? 2 : 0;

                        string sql = @"
                            IF EXISTS (SELECT 1 FROM CourseGrade WHERE Enrollment_id = @EnrollID)
                            BEGIN
                                UPDATE CourseGrade
                                SET total_hours = ISNULL(total_hours, 0) + 2,
                                    attended_hours = ISNULL(attended_hours, 0) + @AttendedHours
                                WHERE Enrollment_id = @EnrollID
                            END
                            ELSE
                            BEGIN
                                INSERT INTO CourseGrade (Enrollment_id, total_hours, attended_hours)
                                VALUES (@EnrollID, 2, @AttendedHours)
                            END";

                        SqlCommand cmd = new SqlCommand(sql, conn);
                        cmd.Parameters.AddWithValue("@EnrollID", enrollmentId);
                        cmd.Parameters.AddWithValue("@AttendedHours", hoursToAdd);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            lblSuccessMsg.Text = "<i class='fas fa-check-circle'></i> Attendance saved successfully! (+2 Total Hours applied to all).";
            lblSuccessMsg.Visible = true;

            LoadStudentAttendance();
        }
    }
}