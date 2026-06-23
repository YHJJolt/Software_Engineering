using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CourseHome : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int courseId;
        string academicSession;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!int.TryParse(Request.QueryString["id"], out courseId))
            {
                Response.Redirect("~/Lecturer/LecturerDashboard.aspx");
                return;
            }

            academicSession = Request.QueryString["session"] ?? "";

            ((LecturerCourseMaster)this.Master).PageTitle = "Home";

            if (!IsPostBack)
            {
                LoadCourseDetails();
                LoadStats();
                LoadStudents();
                LoadAnnouncements();
            }
        }

        // ── Course hero banner ────────────────────────────────────────
        private void LoadCourseDetails()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT c.course_code, c.course_name, c.credit_hours, c.course_fee,
                           CASE
                               WHEN EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CourseProgram')
                               THEN (SELECT TOP 1 p.program_name
                                     FROM CourseProgram cp
                                     JOIN Program p ON cp.program_id = p.program_id
                                     WHERE cp.course_id = c.course_id)
                               ELSE NULL
                           END AS program_name
                    FROM [Course] c
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
                    }
                }
            }
        }

        // ── Stats: enrolled, approved, pass rate, at-risk ────────────
        // ── Stats: enrolled, approved, pass rate, at-risk ────────────
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. Total enrolled (session-scoped)
                var c1 = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM [Enrollment] e
                    WHERE e.course_id = @id
                      AND e.status = 'Approved'
                      AND (@Session = '' OR e.academic_session = @Session)", conn);
                c1.Parameters.AddWithValue("@id", courseId);
                c1.Parameters.AddWithValue("@Session", academicSession);
                litEnrolled.Text = c1.ExecuteScalar().ToString();

                // 2. Avg attendance % (session-scoped)
                var c2 = new SqlCommand(@"
            SELECT AVG(
                CAST(cg.attended_hours AS FLOAT) / CAST(NULLIF(cg.total_hours, 0) AS FLOAT) * 100.0
            )
            FROM CourseGrade cg
            JOIN Enrollment e ON cg.Enrollment_id = e.enrollment_id
            WHERE e.course_id = @id
              AND e.status = 'Approved'
              AND (@Session = '' OR e.academic_session = @Session)
              AND cg.total_hours > 0", conn);
                c2.Parameters.AddWithValue("@id", courseId);
                c2.Parameters.AddWithValue("@Session", academicSession);
                object avg = c2.ExecuteScalar();
                litAvgAttendance.Text = (avg != DBNull.Value && avg != null)
                    ? Math.Round(Convert.ToDouble(avg), 1, MidpointRounding.AwayFromZero).ToString("0.0") + "%" : "N/A";

                // 3. Pass rate (session-scoped)
                var c3 = new SqlCommand(@"
            SELECT CAST(SUM(CASE WHEN cg.letter_grade <> 'F' THEN 1 ELSE 0 END) AS FLOAT)
                   / NULLIF(COUNT(cg.letter_grade), 0) * 100
            FROM CourseGrade cg
            JOIN Enrollment e ON cg.Enrollment_id = e.Enrollment_id
            WHERE e.course_id = @id
              AND e.status = 'Approved'
              AND (@Session = '' OR e.academic_session = @Session)", conn);
                c3.Parameters.AddWithValue("@id", courseId);
                c3.Parameters.AddWithValue("@Session", academicSession);
                object rate = c3.ExecuteScalar();
                litPassRate.Text = (rate != DBNull.Value && rate != null)
                    ? Convert.ToDouble(rate).ToString("0.0") + "%" : "N/A";

                // 4. At risk — grade F, session-scoped
                var c4 = new SqlCommand(@"
            SELECT COUNT(*)
            FROM CourseGrade cg
            JOIN Enrollment e ON cg.Enrollment_id = e.Enrollment_id
            WHERE e.course_id = @id
              AND e.status = 'Approved'
              AND (@Session = '' OR e.academic_session = @Session)
              AND cg.letter_grade = 'F'", conn);
                c4.Parameters.AddWithValue("@id", courseId);
                c4.Parameters.AddWithValue("@Session", academicSession);
                litAtRisk.Text = c4.ExecuteScalar().ToString();
            }
        }

        // ── Recent enrolled students with grade ────────────────
        private void LoadStudents()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
            SELECT TOP 5
                s.student_code, s.student_name,
                e.status,
                cg.letter_grade
            FROM [Enrollment] e
            JOIN [Student] s ON e.student_id = s.student_id
            LEFT JOIN [CourseGrade] cg ON e.enrollment_id = cg.Enrollment_id
            WHERE e.course_id = @id
              AND e.status = 'Approved'
              AND (@Session = '' OR e.academic_session = @Session)
            ORDER BY e.enrollment_date DESC", conn);
                cmd.Parameters.AddWithValue("@id", courseId);
                cmd.Parameters.AddWithValue("@Session", academicSession);
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                rptStudents.DataSource = dt;
                rptStudents.DataBind();
                pnlNoStudents.Visible = (dt.Rows.Count == 0);
            }
        }

        // ── Course-related announcements ─────────────────────────────
        private void LoadAnnouncements()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // Only show announcements posted by the lecturer for this specific course
                SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 5 a.title, a.category, a.created_at
                    FROM [Announcement] a
                    JOIN [Lecturer] l ON a.Lecturer_id = l.lecturer_id
                    WHERE a.Course_id = @cid
                      AND l.lecturer_email = @email
                      AND (@Session = '' OR a.academic_session = @Session)
                    ORDER BY a.created_at DESC", conn);
                cmd.Parameters.AddWithValue("@cid", courseId);
                cmd.Parameters.AddWithValue("@email", Session["UserEmail"].ToString());
                cmd.Parameters.AddWithValue("@Session", academicSession);
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
                pnlNoAnnounce.Visible = (dt.Rows.Count == 0);
            }
        }

        // ── Helper: CSS class for grade badge ────────────────────────
        public string GetGradeClass(object gradeObj)
        {
            if (gradeObj == DBNull.Value || gradeObj == null) return "grade-na";
            string g = gradeObj.ToString().ToUpper();
            if (g.StartsWith("A")) return "grade-a";
            if (g.StartsWith("B")) return "grade-b";
            if (g.StartsWith("C") || g.StartsWith("D")) return "grade-c";
            if (g == "F") return "grade-f";
            return "grade-na";
        }
    }
}