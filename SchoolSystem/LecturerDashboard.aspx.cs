using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class LecturerDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");

            ((LecturerMaster)this.Master).PageTitle = "Dashboard Overview";

            if (!IsPostBack)
            {
                LoadDashboardStats();
                LoadCourses();
                LoadCourseRates();
            }
        }

        private void LoadDashboardStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // FIXED: Query courses directly from Course table matching the Lecturer ID
                string sqlCourses = @"
                    SELECT COUNT(c.course_id) 
                    FROM Course c 
                    JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id 
                    WHERE l.lecturer_email = @Email";

                // FIXED: Query student enrollments linked directly via Course table ownership
                string sqlStudents = @"
                    SELECT COUNT(e.student_id) 
                    FROM Enrollment e
                    JOIN Course c ON e.course_id = c.course_id
                    JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
                    WHERE l.lecturer_email = @Email";

                // FIXED: Calculate passing rates by evaluating grades linked to assigned courses
                string sqlPassRate = @"
                    SELECT 
                        CAST(SUM(CASE WHEN cg.letter_grade <> 'F' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(cg.letter_grade), 0) * 100 as PassRate
                    FROM CourseGrade cg
                    JOIN Enrollment e ON cg.Enrollment_id = e.Enrollment_id
                    JOIN Course c ON e.course_id = c.course_id
                    JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
                    WHERE l.lecturer_email = @Email";

                conn.Open();

                SqlCommand cmd1 = new SqlCommand(sqlCourses, conn);
                cmd1.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                litCourseCount.Text = cmd1.ExecuteScalar()?.ToString() ?? "0";

                SqlCommand cmd2 = new SqlCommand(sqlStudents, conn);
                cmd2.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                litStudentCount.Text = cmd2.ExecuteScalar()?.ToString() ?? "0";

                SqlCommand cmd3 = new SqlCommand(sqlPassRate, conn);
                cmd3.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                object rateObj = cmd3.ExecuteScalar();

                if (rateObj != DBNull.Value && rateObj != null)
                {
                    double rate = Convert.ToDouble(rateObj);
                    litPassRate.Text = rate.ToString("0.0") + "%";
                }
                else
                {
                    litPassRate.Text = "N/A";
                }
            }
        }

        private void LoadCourseRates()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // FIXED: Removed LecturerEnrollment tracking reference from data aggregates
                string sql = @"
                    SELECT 
                        c.course_code, 
                        c.course_name,
                        COUNT(cg.letter_grade) as TotalGraded,
                        CAST(SUM(CASE WHEN cg.letter_grade <> 'F' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(cg.letter_grade), 0) * 100 as PassRate
                    FROM Course c
                    JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
                    LEFT JOIN Enrollment e ON c.course_id = e.course_id
                    LEFT JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
                    WHERE l.lecturer_email = @Email
                    GROUP BY c.course_code, c.course_name";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dt.Columns.Add("PassRateFormatted", typeof(string));
                foreach (DataRow row in dt.Rows)
                {
                    if (row["PassRate"] == DBNull.Value)
                        row["PassRateFormatted"] = "N/A";
                    else
                        row["PassRateFormatted"] = Convert.ToDouble(row["PassRate"]).ToString("0.0") + "%";
                }

                rptCourseRates.DataSource = dt;
                rptCourseRates.DataBind();
            }
        }

        private void LoadCourses()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            SELECT c.course_id, c.course_code, c.course_name, c.course_img
            FROM Course c
            JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
            INNER JOIN LecturerCourseFavourite f
                   ON f.course_id   = c.course_id
                  AND f.lecturer_id = l.lecturer_id
            WHERE l.lecturer_email = @Email
            ORDER BY c.course_name ASC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptCourses.DataSource = dt;
                rptCourses.DataBind();

                // Show/hide empty state
                noFavsPanel.Visible = dt.Rows.Count == 0;
                rptCourses.Visible = dt.Rows.Count > 0;
            }
        }

        protected string GetImageSrc(object imgObj)
        {
            if (imgObj == DBNull.Value || imgObj == null)
            {
                return "Images/default-course.png";
            }
            byte[] bytes = (byte[])imgObj;
            string base64String = Convert.ToBase64String(bytes);
            return "data:image/png;base64," + base64String;
        }
    }
}