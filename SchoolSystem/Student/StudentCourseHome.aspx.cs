using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class StudentCourseHome : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        private int courseId;
        private int studentId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!int.TryParse(Request.QueryString["id"], out courseId))
            {
                Response.Redirect("~/Student/StudentDashboard.aspx");
                return;
            }

            ((StudentCourseMaster)this.Master).PageTitle = "Home";

            if (!IsPostBack)
            {
                studentId = GetStudentId();
                if (studentId == 0) { Response.Redirect("~/Student/StudentDashboard.aspx"); return; }

                LoadCourseDetails();
                LoadStats();
                LoadAssignments();
                LoadAnnouncements();
            }
        }

        private int GetStudentId()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "SELECT student_id FROM [Student] WHERE student_email = @email", conn);
                cmd.Parameters.AddWithValue("@email", Session["UserEmail"].ToString());
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
        }

        private void LoadCourseDetails()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT c.course_code, c.course_name, c.credit_hours,
                           p.program_name, l.lecturer_name
                    FROM [Course] c
                    LEFT JOIN [Program]  p ON c.Program_id  = p.program_id
                    LEFT JOIN [Lecturer] l ON c.Lecturer_id = l.lecturer_id
                    WHERE c.course_id = @id", conn);
                cmd.Parameters.AddWithValue("@id", courseId);

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litCourseCode.Text = rdr["course_code"].ToString();
                        litCourseName.Text = rdr["course_name"].ToString();
                        litCreditHours.Text = rdr["credit_hours"].ToString();
                        litProgramName.Text = rdr["program_name"].ToString();
                        litLecturerName.Text = rdr["lecturer_name"].ToString();
                    }
                }
            }
        }

        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // My attendance %
                SqlCommand c1 = new SqlCommand(@"
                    SELECT cg.attended_hours, cg.total_hours
                    FROM [CourseGrade] cg
                    JOIN [Enrollment] e ON cg.Enrollment_id = e.enrollment_id
                    WHERE e.course_id = @cid AND e.student_id = @sid", conn);
                c1.Parameters.AddWithValue("@cid", courseId);
                c1.Parameters.AddWithValue("@sid", studentId);
                using (SqlDataReader rdr = c1.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        int attended = Convert.ToInt32(rdr["attended_hours"]);
                        int total = Convert.ToInt32(rdr["total_hours"]);
                        litMyAttendance.Text = total > 0
                            ? Math.Round((double)attended / total * 100, 1,
                                MidpointRounding.AwayFromZero).ToString("0.0") + "%"
                            : "N/A";
                    }
                    else litMyAttendance.Text = "N/A";
                }

                // My letter grade
                SqlCommand c2 = new SqlCommand(@"
                    SELECT cg.letter_grade
                    FROM [CourseGrade] cg
                    JOIN [Enrollment] e ON cg.Enrollment_id = e.enrollment_id
                    WHERE e.course_id = @cid AND e.student_id = @sid", conn);
                c2.Parameters.AddWithValue("@cid", courseId);
                c2.Parameters.AddWithValue("@sid", studentId);
                object grade = c2.ExecuteScalar();
                litMyGrade.Text = (grade != null && grade != DBNull.Value
                                   && grade.ToString().Trim() != "")
                    ? grade.ToString() : "N/A";
            }
        }

        private void LoadAssignments()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 5
                        title,
                        assignment_type,
                        due_date
                    FROM [CourseAssignment]
                    WHERE course_id = @cid
                      AND due_date >= GETDATE()
                    ORDER BY due_date ASC", conn);
                cmd.Parameters.AddWithValue("@cid", courseId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                rptAssignments.DataSource = dt;
                rptAssignments.DataBind();
                pnlNoAssign.Visible = (dt.Rows.Count == 0);
            }
        }

        private void LoadAnnouncements()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 5 a.title, a.category, a.created_at
                    FROM [Announcement] a
                    WHERE a.Course_id = @cid
                      AND (a.Lecturer_id IS NOT NULL OR a.Admin_id IS NOT NULL)
                    ORDER BY a.created_at DESC", conn);
                cmd.Parameters.AddWithValue("@cid", courseId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
                pnlNoAnnounce.Visible = (dt.Rows.Count == 0);
            }
        }

        // Returns CSS class based on how close the due date is
        public string GetDueClass(object dueDateObj)
        {
            if (dueDateObj == null || dueDateObj == DBNull.Value) return "sch-assign-due";
            DateTime due = Convert.ToDateTime(dueDateObj);
            int daysLeft = (due.Date - DateTime.Today).Days;
            if (daysLeft <= 3) return "sch-assign-due danger";
            if (daysLeft <= 7) return "sch-assign-due warning";
            return "sch-assign-due";
        }
    }
}