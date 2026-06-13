using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace SchoolSystem
{
    public partial class StudentIndivGrades : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        private int courseId;
        private int studentId;
        private string academicSession;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!int.TryParse(Request.QueryString["id"], out courseId))
            {
                Response.Redirect("~/Student/StudentDashboard.aspx"); return;
            }

            academicSession = Request.QueryString["session"] ?? "";

            ((StudentCourseMaster)this.Master).PageTitle = "Grades";

            if (!IsPostBack)
            {
                studentId = GetStudentId();
                if (studentId == 0) { Response.Redirect("~/Student/StudentDashboard.aspx"); return; }
                LoadGrades();
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

        private void LoadGrades()
        {
            string sql = @"
                SELECT
                    ca.assignment_id,
                    ca.title,
                    ca.assignment_type      AS type,
                    ca.due_date             AS due_date_raw,
                    ca.max_marks,
                    sub.submitted_at,
                    sub.marks_awarded,
                    ISNULL(sub.is_published, 0) AS is_published
                FROM [CourseAssignment] ca
                LEFT JOIN [AssignmentSubmission] sub
                    ON  ca.assignment_id = sub.assignment_id
                    AND sub.student_id   = @StudentId
                WHERE ca.course_id = @CourseId
                  AND (@Session = '' OR ca.academic_session = @Session)
                ORDER BY ca.due_date ASC";

            var list = new List<object>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@Session", academicSession);
                conn.Open();

                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        bool isPublished = Convert.ToBoolean(rdr["is_published"]);

                        string score = null;
                        if (isPublished && rdr["marks_awarded"] != DBNull.Value)
                            score = rdr["marks_awarded"].ToString();

                        string dueRaw = rdr["due_date_raw"] != DBNull.Value
                            ? Convert.ToDateTime(rdr["due_date_raw"]).ToString("o") : null;
                        string dueFmt = rdr["due_date_raw"] != DBNull.Value
                            ? Convert.ToDateTime(rdr["due_date_raw"]).ToString("MMM dd, yyyy 'at' h:mmtt") : null;
                        string submittedRaw = rdr["submitted_at"] != DBNull.Value
                            ? Convert.ToDateTime(rdr["submitted_at"]).ToString("o") : null;
                        string submittedFmt = rdr["submitted_at"] != DBNull.Value
                            ? Convert.ToDateTime(rdr["submitted_at"]).ToString("MMM dd, yyyy 'at' h:mmtt") : null;

                        list.Add(new
                        {
                            title = rdr["title"].ToString(),
                            type = rdr["type"].ToString(),
                            due = dueFmt,
                            dueRaw = dueRaw,
                            submittedAt = submittedFmt,
                            submittedRaw = submittedRaw,
                            score = score,
                            maxScore = rdr["max_marks"].ToString(),
                            published = isPublished
                        });
                    }
                }
            }

            hfGradeData.Value = new JavaScriptSerializer().Serialize(list);
        }
    }
}
