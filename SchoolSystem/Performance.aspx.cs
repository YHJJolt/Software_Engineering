using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace YourApp
{
    public partial class Performance : Page
    {
        protected string StudentJsonData = "{}";
        protected string StudentMetaJson = "{}";
        protected string AllStudentsJson = "[]";
        protected int SelectedStudentId = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Read selected student from query string, default to 1
            SelectedStudentId = 1;
            if (!string.IsNullOrEmpty(Request.QueryString["sid"]))
            {
                int parsed;
                if (int.TryParse(Request.QueryString["sid"], out parsed))
                    SelectedStudentId = parsed;
            }

            AllStudentsJson = GetAllStudents();
            StudentMetaJson = GetStudentMeta(SelectedStudentId);
            StudentJsonData = GetSemesterData(SelectedStudentId);
        }

        // ── NEW: returns all active students for the picker ──────────
        private string GetAllStudents()
        {
            string connStr = GetConnectionString();
            var entries = new List<string>();

            string sql = @"
                SELECT student_id, student_name
                FROM   [Student]
                WHERE  student_isactive = 'Active'
                ORDER  BY student_name";

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        entries.Add(string.Format("{{\"id\":{0},\"name\":\"{1}\"}}",
                            r["student_id"],
                            Escape(r["student_name"].ToString())));
                    }
                }
            }
            return "[" + string.Join(",", entries) + "]";
        }

        private string GetStudentMeta(int studentId)
        {
            string connStr = GetConnectionString();
            string name = "", email = "", programme = "";
            int currentSem = 1;
            int actualID = 0;

            string sql = @"
                SELECT s.student_id, s.student_name, s.student_email, s.student_sem, p.program_name
                FROM   [Student]  s
                JOIN   [Program]  p ON p.program_id = s.Program_id
                WHERE  s.student_id = @sid";

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sid", studentId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        actualID = Convert.ToInt32(r["student_id"]);
                        name = r["student_name"].ToString();
                        email = r["student_email"].ToString();
                        currentSem = r["student_sem"] != DBNull.Value ? Convert.ToInt32(r["student_sem"]) : 1;
                        programme = r["program_name"].ToString();
                    }
                }
            }

            return string.Format(
                "{{\"name\":\"{0}\",\"email\":\"{1}\",\"programme\":\"{2}\",\"currentSem\":{3},\"id\":{4}}}",
                Escape(name), Escape(email), Escape(programme), currentSem, actualID
            );
        }

        private string GetSemesterData(int studentId)
        {
            string connStr = GetConnectionString();
            var semMap = new Dictionary<int, List<CourseRow>>();

            string sql = @"
                SELECT e.semester, c.course_name, c.credit_hours, cg.letter_grade, cg.grade_point, cg.total_hours, cg.attended_hours
                FROM   [Enrollment]  e
                JOIN   [Course]      c  ON c.course_id      = e.Course_id
                JOIN   [CourseGrade] cg ON cg.Enrollment_id = e.enrollment_id
                WHERE  e.Student_id = @sid
                ORDER  BY e.semester, c.course_name";

            using (var conn = new SqlConnection(connStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@sid", studentId);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        int sem = Convert.ToInt32(r["semester"]);
                        if (!semMap.ContainsKey(sem)) semMap[sem] = new List<CourseRow>();
                        semMap[sem].Add(new CourseRow
                        {
                            CourseName = r["course_name"].ToString(),
                            CreditHours = Convert.ToInt32(r["credit_hours"]),
                            LetterGrade = r["letter_grade"].ToString(),
                            GradePoint = Convert.ToDouble(r["grade_point"]),
                            TotalHours = Convert.ToInt32(r["total_hours"]),
                            AttendedHours = Convert.ToInt32(r["attended_hours"])
                        });
                    }
                }
            }

            var sb = new StringBuilder("{");
            bool first = true;
            foreach (var kvp in semMap)
            {
                if (!first) sb.Append(","); first = false;
                var courses = new List<string>(); var credits = new List<string>();
                var totals = new List<string>(); var attended = new List<string>();
                var grades = new List<string>(); var gpas = new List<string>();

                foreach (var row in kvp.Value)
                {
                    courses.Add("\"" + Escape(row.CourseName) + "\"");
                    credits.Add(row.CreditHours.ToString());
                    totals.Add(row.TotalHours.ToString());
                    attended.Add(row.AttendedHours.ToString());
                    grades.Add("\"" + Escape(row.LetterGrade) + "\"");
                    gpas.Add(row.GradePoint.ToString("F1"));
                }
                sb.AppendFormat(
                    "\"{0}\":{{\"courses\":[{1}],\"credits\":[{2}],\"total\":[{3}],\"attended\":[{4}],\"grades\":[{5}],\"gpa\":[{6}]}}",
                    kvp.Key,
                    string.Join(",", courses), string.Join(",", credits),
                    string.Join(",", totals), string.Join(",", attended),
                    string.Join(",", grades), string.Join(",", gpas));
            }
            sb.Append("}");
            return sb.ToString();
        }

        private string GetConnectionString() =>
            System.Configuration.ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        private string Escape(string s) =>
            s?.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "") ?? "";

        private class CourseRow
        {
            public string CourseName { get; set; }
            public int CreditHours { get; set; }
            public string LetterGrade { get; set; }
            public double GradePoint { get; set; }
            public int TotalHours { get; set; }
            public int AttendedHours { get; set; }
        }
    }
}