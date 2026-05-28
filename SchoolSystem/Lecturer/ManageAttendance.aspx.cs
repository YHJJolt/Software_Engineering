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
                string sql = @"
                    WITH AttendanceData AS (
                        SELECT 
                            e.Enrollment_id,
                            s.student_code, 
                            s.student_name,
                            ISNULL(cg.total_hours, 0) AS total_hours,
                            ISNULL(cg.attended_hours, 0) AS attended_hours,
                            CASE 
                                WHEN ISNULL(cg.total_hours, 0) = 0 THEN 0.0  -- CHANGED: 0 total hours now equals 0.0%
                                ELSE (CAST(ISNULL(cg.attended_hours, 0) AS FLOAT) / CAST(ISNULL(cg.total_hours, 0) AS FLOAT)) * 100.0
                            END AS AttendancePercentage
                        FROM Enrollment e
                        JOIN Student s ON e.student_id = s.student_id
                        LEFT JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
                        WHERE e.course_id = @CourseID
                    )
                    SELECT * FROM AttendanceData 
                    WHERE 1=1 ";

                // Apply Search Filter
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    sql += " AND student_name LIKE @SearchTerm ";
                }

                // Apply High/Low Filter
                if (ddlAttendanceFilter.SelectedValue == "Low")
                {
                    // Ensure total_hours > 0 so unstarted classes aren't flagged as "Low"
                    sql += " AND AttendancePercentage < 75.0 AND total_hours > 0 ";
                }
                else if (ddlAttendanceFilter.SelectedValue == "High")
                {
                    sql += " AND AttendancePercentage >= 75.0 ";
                }

                // Apply alphabetical sorting by student code
                sql += " ORDER BY student_code ASC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseID", courseId);

                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    cmd.Parameters.AddWithValue("@SearchTerm", "%" + txtSearch.Text.Trim() + "%");
                }

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