using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentAllGrades : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        // Exposed to the ASPX for the print modal
        public string StudentName = "";
        public string SemesterLabel = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            ((StudentMaster)this.Master).PageTitle = "Grades";

            if (!IsPostBack)
            {
                int defaultSem = LoadSemesterDropdown();
                LoadGrades(defaultSem);
            }
            else
            {
                // On postback, still set StudentName for the modal
                StudentName = GetStudentName();
                SemesterLabel = ddlSemester.SelectedItem?.Text ?? "All Semesters";
            }
        }

        private int GetStudentId()
        {
            if (Session["StudentID"] != null)
                return Convert.ToInt32(Session["StudentID"]);

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

        private string GetStudentName()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT student_name FROM Student WHERE student_email = @Email";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return result?.ToString() ?? "";
                }
            }
        }

        // Returns 0 = All Semesters (default)
        private int LoadSemesterDropdown()
        {
            int studentId = GetStudentId();

            ddlSemester.Items.Clear();
            ddlSemester.Items.Add(new ListItem("All Semesters", "0"));

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT DISTINCT e.enrolled_semester
                    FROM Enrollment e
                    WHERE e.student_id = @StudentId
                    ORDER BY e.enrolled_semester ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    conn.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        int sem = Convert.ToInt32(rdr["enrolled_semester"]);
                        ddlSemester.Items.Add(new ListItem("Semester " + sem, sem.ToString()));
                    }
                }
            }

            ddlSemester.SelectedValue = "0";
            return 0;
        }

        private void LoadGrades(int semester)
        {
            int studentId = GetStudentId();
            StudentName = GetStudentName();
            SemesterLabel = semester == 0 ? "All Semesters" : "Semester " + semester;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Each course score = SUM(marks_awarded) / SUM(max_marks for graded only) * 100
                // This mirrors the trigger logic so it stays consistent.
                string sql = @"
                    SELECT
                        c.course_code,
                        c.course_name,
                        c.credit_hours,
                        e.enrolled_semester,
                        ISNULL(cg.letter_grade, 'N/A')                  AS letter_grade,
                        ISNULL(CAST(cg.grade_point AS DECIMAL(4,2)), 0)  AS grade_point,
                        ISNULL(
                            CAST(
                                (SUM(sub.marks_awarded) /
                                 NULLIF(SUM(CASE WHEN sub.marks_awarded IS NOT NULL THEN ca.max_marks ELSE 0 END), 0))
                                * 100
                            AS DECIMAL(5,1)), 0)                         AS score_pct
                    FROM Enrollment e
                    INNER JOIN Course        c   ON e.course_id    = c.course_id
                    LEFT  JOIN CourseGrade   cg  ON cg.Enrollment_id = e.enrollment_id
                    LEFT  JOIN CourseAssignment ca ON ca.course_id  = c.course_id
                                                  AND ca.academic_session = e.academic_session
                    LEFT  JOIN AssignmentSubmission sub
                                                 ON sub.assignment_id = ca.assignment_id
                                                AND sub.student_id    = e.student_id
                    WHERE e.student_id = @StudentId
                      AND e.status     = 'Approved'
                      " + (semester != 0 ? "AND e.enrolled_semester = @Semester" : "") + @"
                    GROUP BY
                        c.course_code, c.course_name, c.credit_hours,
                        e.enrolled_semester, cg.letter_grade, cg.grade_point
                    ORDER BY e.enrolled_semester ASC, c.course_name ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    if (semester != 0)
                        cmd.Parameters.AddWithValue("@Semester", semester);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    bool hasRows = dt.Rows.Count > 0;
                    pnlEmpty.Visible = !hasRows;
                    pnlTable.Visible = hasRows;

                    if (hasRows)
                    {
                        rptGrades.DataSource = dt;
                        rptGrades.DataBind();

                        // Total credits
                        int totalCredits = 0;
                        foreach (DataRow row in dt.Rows)
                            if (row["credit_hours"] != DBNull.Value)
                                totalCredits += Convert.ToInt32(row["credit_hours"]);

                        litCredits.Text = totalCredits.ToString();
                        litFooterCredits.Text = totalCredits.ToString();
                    }

                    // GPA & CGPA — pull from Grades table
                    LoadGpaStats(studentId, semester);
                }
            }
        }

        // Each query opens its own connection — the previous conn passed in was
        // already disposed by the time this runs, causing the InvalidOperationException.
        private void LoadGpaStats(int studentId, int semester)
        {
            // Sem GPA
            string sqlGpa = semester != 0
                ? "SELECT gpa FROM Grades WHERE Student_id = @StudentId AND semester = @Semester"
                : "SELECT TOP 1 gpa FROM Grades WHERE Student_id = @StudentId ORDER BY semester DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sqlGpa, conn))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                if (semester != 0) cmd.Parameters.AddWithValue("@Semester", semester);
                conn.Open();
                object result = cmd.ExecuteScalar();
                litSemGPA.Text = result != null && result != DBNull.Value
                    ? Convert.ToDecimal(result).ToString("0.00") : "N/A";
            }

            // CGPA
            string sqlCgpa = "SELECT TOP 1 cgpa FROM Grades WHERE Student_id = @StudentId ORDER BY semester DESC";
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sqlCgpa, conn))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                litCGPA.Text = result != null && result != DBNull.Value
                    ? Convert.ToDecimal(result).ToString("0.00") : "N/A";
            }
        }

        protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedSem = 0;
            int.TryParse(ddlSemester.SelectedValue, out selectedSem);
            LoadGrades(selectedSem);
        }

        // Score bar color: green ≥ 70, amber 50-69, red < 50
        public string GetBarColor(string scorePct)
        {
            double pct = 0;
            double.TryParse(scorePct, out pct);
            if (pct >= 70) return "#22c55e";
            if (pct >= 50) return "#f59e0b";
            return "#ef4444";
        }

        // CSS class for the letter grade pill
        public string GetGradeClass(string grade)
        {
            switch (grade)
            {
                case "A": return "gl-A";
                case "A-": return "gl-Am";
                case "B+": return "gl-Bp";
                case "B": return "gl-B";
                case "B-": return "gl-Bm";
                case "C+": return "gl-Cp";
                case "C": return "gl-C";
                case "F": return "gl-F";
                default: return "gl-NA";
            }
        }

        // Pass if score >= 50 and not N/A; Fail if < 50; N/A if no submissions
        public string GetStatusClass(string scorePct, string grade)
        {
            if (grade == "N/A") return "status-na";
            double pct = 0;
            double.TryParse(scorePct, out pct);
            return pct >= 50 ? "status-pass" : "status-fail";
        }

        public string GetStatusText(string scorePct, string grade)
        {
            if (grade == "N/A") return "Pending";
            double pct = 0;
            double.TryParse(scorePct, out pct);
            return pct >= 50 ? "Pass" : "Fail";
        }
    }
}