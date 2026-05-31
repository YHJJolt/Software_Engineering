using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class Grades : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) return;

            ((LecturerCourseMaster)Master).PageTitle = "Grades";

            if (!IsPostBack)
            {
                LoadStudentDropdown();
            }
        }

        // ─────────────────────────────────────────────────────────────
        // Load students enrolled in this course into dropdown
        // ─────────────────────────────────────────────────────────────
        private void LoadStudentDropdown()
        {
            int courseId = GetCourseId();
            if (courseId == 0) return;

            // FIXED: The only change needed. Filters by Active Semester and Approved Status.
            string sql = @"
                SELECT s.student_id, s.student_name, s.student_code
                FROM Student s
                INNER JOIN Enrollment e ON s.student_id = e.student_id
                WHERE e.course_id = @CourseId
                  AND e.status = 'Approved'
                  AND e.enrolled_semester = s.student_sem
                ORDER BY s.student_name ASC";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                conn.Open();
                da.Fill(dt);

                ddlStudents.Items.Clear();
                ddlStudents.Items.Add(new ListItem("-- Select Student --", ""));

                foreach (DataRow row in dt.Rows)
                {
                    string label = row["student_name"].ToString()
                        + (row["student_code"] != DBNull.Value
                            ? " (" + row["student_code"].ToString() + ")"
                            : "");
                    ddlStudents.Items.Add(new ListItem(label, row["student_id"].ToString()));
                }
            }
        }

        // ─────────────────────────────────────────────────────────────
        // Student dropdown changed — load their grades
        // ─────────────────────────────────────────────────────────────
        protected void ddlStudents_Changed(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlStudents.SelectedValue))
            {
                hfGradeData.Value = "[]";
                return;
            }

            int studentId = Convert.ToInt32(ddlStudents.SelectedValue);
            int courseId = GetCourseId();
            if (courseId == 0) return;

            LoadGrades(studentId, courseId);
        }

        // ─────────────────────────────────────────────────────────────
        // Query assignments + submissions → serialise to JSON for JS
        // ─────────────────────────────────────────────────────────────
        private void LoadGrades(int studentId, int courseId)
        {
            string sql = @"
                SELECT
                    ca.assignment_id,
                    ca.title,
                    ca.assignment_type   AS type,
                    ca.due_date          AS due_date_raw,
                    ca.max_marks,
                    sub.submitted_at,
                    sub.marks_awarded,
                    sub.is_published
                FROM CourseAssignment ca
                LEFT JOIN AssignmentSubmission sub
                    ON ca.assignment_id = sub.assignment_id
                   AND sub.student_id   = @StudentId
                WHERE ca.course_id = @CourseId
                ORDER BY ca.due_date ASC";

            var list = new List<object>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();

                while (rdr.Read())
                {
                    bool isPublished = rdr["is_published"] != DBNull.Value
                                    && Convert.ToBoolean(rdr["is_published"]);

                    // Only show score if published
                    string score = null;
                    if (isPublished && rdr["marks_awarded"] != DBNull.Value)
                        score = rdr["marks_awarded"].ToString();

                    string dueRaw = rdr["due_date_raw"] != DBNull.Value
                        ? Convert.ToDateTime(rdr["due_date_raw"]).ToString("o")
                        : null;

                    string dueFmt = rdr["due_date_raw"] != DBNull.Value
                        ? Convert.ToDateTime(rdr["due_date_raw"]).ToString("MMM dd, yyyy 'at' h:mmtt")
                        : null;

                    string submittedFmt = rdr["submitted_at"] != DBNull.Value
                        ? Convert.ToDateTime(rdr["submitted_at"]).ToString("MMM dd, yyyy 'at' h:mmtt")
                        : null;

                    string submittedRaw = rdr["submitted_at"] != DBNull.Value
                        ? Convert.ToDateTime(rdr["submitted_at"]).ToString("o")
                        : null;

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

            hfGradeData.Value = new JavaScriptSerializer().Serialize(list);
        }

        private int GetCourseId()
        {
            string raw = Request.QueryString["id"] ?? Request.QueryString["course_id"];
            int id = 0;
            int.TryParse(raw, out id);
            return id;
        }
    }
}