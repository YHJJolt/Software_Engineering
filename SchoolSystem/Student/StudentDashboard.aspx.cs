using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class StudentDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            ((StudentMaster)this.Master).PageTitle = "Student Dashboard";

            if (!IsPostBack)
            {
                LoadDashboardStats();
                LoadEnrolledCourses();
            }
        }

        private int GetStudentId()
        {
            if (Session["StudentID"] != null)
            {
                return Convert.ToInt32(Session["StudentID"]);
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT student_id FROM Student WHERE student_email = @Email";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) return Convert.ToInt32(result);
                }
            }
            return 0;
        }

        private void LoadDashboardStats()
        {
            int studentId = GetStudentId();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Courses Enrolled count (Filters by Approved AND Current Semester)
                string sqlCourses = @"
                    SELECT COUNT(*) 
                    FROM Enrollment e
                    INNER JOIN Student s ON e.student_id = s.student_id
                    WHERE e.student_id = @StudentId 
                      AND e.enrolled_semester = s.student_sem
                      AND e.status = 'Approved'";
                using (SqlCommand cmd = new SqlCommand(sqlCourses, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    litCourseCount.Text = cmd.ExecuteScalar()?.ToString() ?? "0";
                }

                // 2. Current CGPA (Matches your new Grades table architecture)
                string sqlCgpa = "SELECT TOP 1 cgpa FROM Grades WHERE Student_id = @StudentId ORDER BY semester DESC";
                using (SqlCommand cmd = new SqlCommand(sqlCgpa, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    object cgpaResult = cmd.ExecuteScalar();
                    litCGPA.Text = cgpaResult != null && cgpaResult != DBNull.Value ? Convert.ToDecimal(cgpaResult).ToString("0.00") : "N/A";
                }

                // 3. Average Attendance Calculation 
                string sqlAttendance = @"
                    SELECT SUM(cg.attended_hours) as Attended, SUM(cg.total_hours) as Total 
                    FROM CourseGrade cg
                    INNER JOIN Enrollment e ON cg.Enrollment_id = e.enrollment_id
                    INNER JOIN Student s ON e.student_id = s.student_id
                    WHERE e.student_id = @StudentId AND e.enrolled_semester = s.student_sem";

                using (SqlCommand cmd = new SqlCommand(sqlAttendance, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            int attended = rdr["Attended"] != DBNull.Value ? Convert.ToInt32(rdr["Attended"]) : 0;
                            int total = rdr["Total"] != DBNull.Value ? Convert.ToInt32(rdr["Total"]) : 0;

                            if (total > 0)
                            {
                                double percentage = ((double)attended / total) * 100;
                                litAttendance.Text = percentage.ToString("0") + "%";
                            }
                            else
                            {
                                litAttendance.Text = "0%";
                            }
                        }
                    }
                }
            }
        }

        private void LoadEnrolledCourses()
        {
            int studentId = GetStudentId();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // MAGIC QUERY: Only fetches courses where the stamped enrollment semester matches their current semester
                string sql = @"
            SELECT c.course_id, c.course_code, c.course_name, c.course_img 
            FROM Course c 
            INNER JOIN Enrollment e ON c.course_id = e.course_id 
            INNER JOIN Student s ON e.student_id = s.student_id
            WHERE e.student_id = @StudentId 
              AND e.enrolled_semester = s.student_sem 
              AND e.status = 'Approved'
            ORDER BY c.course_name ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();

                    noCoursesPanel.Visible = dt.Rows.Count == 0;
                    rptCourses.Visible = dt.Rows.Count > 0;
                }
            }
        }

        protected string GetImageSrc(object imgObj)
        {
            if (imgObj == DBNull.Value || imgObj == null)
            {
                return "../Images/default-course.png";
            }
            byte[] bytes = (byte[])imgObj;
            string base64String = Convert.ToBase64String(bytes);
            return "data:image/png;base64," + base64String;
        }
    }
}