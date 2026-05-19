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
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");

            // Safety check to ensure a Course ID was passed
            if (Request.QueryString["id"] == null) Response.Redirect("LecturerDashboard.aspx");

            ((CourseMaster)this.Master).PageTitle = "Manage Attendance";

            if (!IsPostBack)
            {
                LoadStudentAttendance();
            }
        }

        private void LoadStudentAttendance()
        {
            string courseId = Request.QueryString["id"];

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Joins Enrollment to Student. Uses LEFT JOIN on CourseGrade to handle brand new students without records safely.
                string sql = @"
                    SELECT 
                        e.Enrollment_id,
                        s.student_id,
                        s.student_name,
                        ISNULL(cg.total_hours, 0) AS total_hours,
                        ISNULL(cg.attended_hours, 0) AS attended_hours,
                        CASE 
                            WHEN ISNULL(cg.total_hours, 0) = 0 THEN 100.0 
                            ELSE (CAST(ISNULL(cg.attended_hours, 0) AS FLOAT) / CAST(ISNULL(cg.total_hours, 0) AS FLOAT)) * 100.0 
                        END AS AttendancePercentage
                    FROM Enrollment e
                    JOIN Student s ON e.student_id = s.student_id
                    LEFT JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
                    WHERE e.course_id = @CourseID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseID", courseId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptStudents.DataSource = dt;
                rptStudents.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Loop through every student row in the Repeater
                foreach (RepeaterItem item in rptStudents.Items)
                {
                    if (item.ItemType == ListItemType.Item || item.ItemType == ListItemType.AlternatingItem)
                    {
                        HiddenField hfEnrollmentId = (HiddenField)item.FindControl("hfEnrollmentId");
                        DropDownList ddlStatus = (DropDownList)item.FindControl("ddlStatus");

                        int enrollmentId = Convert.ToInt32(hfEnrollmentId.Value);
                        int hoursToAdd = (ddlStatus.SelectedValue == "Present") ? 2 : 0;

                        // UPSERT Logic: 
                        // If record exists, add hours. If it doesn't, create it and add hours.
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

            // Show success message and reload the table with new numbers
            lblSuccessMsg.Text = "<i class='fas fa-check-circle'></i> Attendance saved successfully! (+2 Total Hours applied to all).";
            lblSuccessMsg.Visible = true;
            LoadStudentAttendance();
        }
    }
}