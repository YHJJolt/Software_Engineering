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
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

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
                // Count distinct active course assignments for this lecturer
                string sqlCourses = @"
            SELECT COUNT(DISTINCT cas.course_id)
            FROM CourseAssignment_Session cas
            JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
            WHERE l.lecturer_email = @Email AND cas.assign_status = 'Active'";

                // Count students enrolled in the lecturer's active-session courses
                string sqlStudents = @"
            SELECT COUNT(DISTINCT e.student_id)
            FROM Enrollment e
            JOIN CourseAssignment_Session cas ON e.course_id = cas.course_id AND e.academic_session = cas.academic_session
            JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
            WHERE l.lecturer_email = @Email
              AND e.status = 'Approved'
              AND cas.assign_status = 'Active'";

                // Pass rate across all active-session courses for this lecturer
                string sqlPassRate = @"
            SELECT
                CAST(SUM(CASE WHEN cg.letter_grade <> 'F' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(cg.letter_grade), 0) * 100 as PassRate
            FROM CourseGrade cg
            JOIN Enrollment e ON cg.Enrollment_id = e.enrollment_id
            JOIN CourseAssignment_Session cas ON e.course_id = cas.course_id AND e.academic_session = cas.academic_session
            JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
            WHERE l.lecturer_email = @Email
              AND e.status = 'Approved'
              AND cas.assign_status = 'Active'";

                conn.Open();

                SqlCommand cmd1 = new SqlCommand(sqlCourses, conn);
                cmd1.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                litCourseCount.Text = cmd1.ExecuteScalar().ToString();

                SqlCommand cmd2 = new SqlCommand(sqlStudents, conn);
                cmd2.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                litStudentCount.Text = cmd2.ExecuteScalar().ToString();

                SqlCommand cmd3 = new SqlCommand(sqlPassRate, conn);
                cmd3.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                object passRateResult = cmd3.ExecuteScalar();

                if (passRateResult != DBNull.Value && passRateResult != null)
                {
                    litPassRate.Text = Convert.ToDouble(passRateResult).ToString("0.0") + "%";
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
                // Course pass rates grouped by course+session for this lecturer
                string sql = @"
                    SELECT
                        c.course_code,
                        c.course_name,
                        cas.academic_session,
                        COUNT(cg.letter_grade) as TotalGraded,
                        CAST(SUM(CASE WHEN cg.letter_grade <> 'F' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(cg.letter_grade), 0) * 100 as PassRate
                    FROM CourseAssignment_Session cas
                    JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
                    JOIN Course c ON cas.course_id = c.course_id
                    LEFT JOIN Enrollment e ON c.course_id = e.course_id AND e.academic_session = cas.academic_session AND e.status = 'Approved'
                    LEFT JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
                    WHERE l.lecturer_email = @Email AND cas.assign_status = 'Active'
                    GROUP BY c.course_code, c.course_name, cas.academic_session";

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
            SELECT DISTINCT c.course_id, c.course_code, c.course_name, c.course_img,
                   cas.academic_session
            FROM Course c
            JOIN CourseAssignment_Session cas ON cas.course_id = c.course_id
            JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
            INNER JOIN LecturerCourseFavourite f
                   ON f.course_id   = c.course_id
                  AND f.lecturer_id = l.lecturer_id
            WHERE l.lecturer_email = @Email AND cas.assign_status = 'Active'
            ORDER BY c.course_name ASC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptCourses.DataSource = dt;
                rptCourses.DataBind();

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