using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentCourses : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            ((StudentMaster)this.Master).PageTitle = "Courses";

            EnsureFavouriteTableExists();

            if (!IsPostBack)
            {
                LoadSessionDropdown();
                LoadCourses(ddlSemester.SelectedValue);
            }
        }

        private void EnsureFavouriteTableExists()
        {
            string sql = @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'StudentCourseFavourite')
                BEGIN
                    CREATE TABLE [StudentCourseFavourite] (
                        [fav_id]     INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
                        [student_id] INT      NOT NULL,
                        [course_id]  INT      NOT NULL,
                        [created_at] DATETIME DEFAULT GETDATE(),
                        CONSTRAINT [UQ_StuFav]         UNIQUE      ([student_id], [course_id]),
                        CONSTRAINT [FK_StuFav_Student] FOREIGN KEY ([student_id])
                            REFERENCES [Student] ([student_id]),
                        CONSTRAINT [FK_StuFav_Course]  FOREIGN KEY ([course_id])
                            REFERENCES [Course]  ([course_id])
                    );
                END";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                new SqlCommand(sql, conn).ExecuteNonQuery();
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

        private void LoadSessionDropdown()
        {
            int studentId = GetStudentId();

            ddlSemester.Items.Clear();
            ddlSemester.Items.Add(new ListItem("All Sessions", ""));

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT DISTINCT e.academic_session
                    FROM Enrollment e
                    WHERE e.student_id = @StudentId
                      AND e.academic_session IS NOT NULL
                      AND e.academic_session <> ''
                    ORDER BY e.academic_session DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    conn.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                    while (rdr.Read())
                    {
                        string s = rdr["academic_session"].ToString();
                        ddlSemester.Items.Add(new ListItem(s, s));
                    }
                }
            }

            ddlSemester.SelectedIndex = 0;
        }

        private void LoadCourses(string session)
        {
            int studentId = GetStudentId();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT
                        c.course_id,
                        c.course_code,
                        c.course_name,
                        c.credit_hours,
                        e.status,
                        e.academic_session,
                        l.lecturer_name,
                        CASE WHEN f.fav_id IS NOT NULL THEN 1 ELSE 0 END AS is_favourite
                    FROM Enrollment e
                    INNER JOIN Course c ON e.course_id = c.course_id
                    LEFT JOIN CourseAssignment_Session cas
                           ON cas.course_id        = c.course_id
                          AND cas.academic_session = e.academic_session
                    LEFT JOIN Lecturer l ON cas.lecturer_id = l.lecturer_id
                    LEFT JOIN StudentCourseFavourite f
                           ON f.course_id  = c.course_id
                          AND f.student_id = @StudentId
                    WHERE e.student_id = @StudentId
                      AND (@Session = '' OR e.academic_session = @Session)
                    ORDER BY e.academic_session DESC, c.course_name ASC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@Session", session ?? "");

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    bool hasRows = dt.Rows.Count > 0;
                    pnlEmpty.Visible = !hasRows;
                    pnlTable.Visible = hasRows;

                    if (hasRows)
                    {
                        rptCourses.DataSource = dt;
                        rptCourses.DataBind();

                        int totalCredits = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            if (row["credit_hours"] != DBNull.Value)
                                totalCredits += Convert.ToInt32(row["credit_hours"]);
                        }
                        litTotalCredits.Text = totalCredits.ToString();
                    }
                }
            }
        }

        protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourses(ddlSemester.SelectedValue);
        }

        public string GetStatusClass(string status)
        {
            switch (status)
            {
                case "Approved": return "status-approved";
                case "Pending": return "status-pending";
                case "Rejected": return "status-rejected";
                default: return "status-approved";
            }
        }

        [WebMethod]
        public static string ToggleFavourite(int courseId, string email)
        {
            string connStr = System.Configuration.ConfigurationManager
                                .ConnectionStrings["SchoolSystemDB"].ConnectionString;

            string sqlGetStudent = "SELECT student_id FROM [Student] WHERE student_email = @Email";
            string sqlCheck = "SELECT COUNT(1) FROM [StudentCourseFavourite] WHERE student_id = @StuId AND course_id = @CourseId";
            string sqlInsert = "INSERT INTO [StudentCourseFavourite] (student_id, course_id) VALUES (@StuId, @CourseId)";
            string sqlDelete = "DELETE FROM [StudentCourseFavourite] WHERE student_id = @StuId AND course_id = @CourseId";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand stuCmd = new SqlCommand(sqlGetStudent, conn);
                stuCmd.Parameters.AddWithValue("@Email", email);
                object stuObj = stuCmd.ExecuteScalar();
                if (stuObj == null) return "error";
                int studentId = Convert.ToInt32(stuObj);

                SqlCommand chk = new SqlCommand(sqlCheck, conn);
                chk.Parameters.AddWithValue("@StuId", studentId);
                chk.Parameters.AddWithValue("@CourseId", courseId);
                bool isFav = (int)chk.ExecuteScalar() > 0;

                SqlCommand tog = new SqlCommand(isFav ? sqlDelete : sqlInsert, conn);
                tog.Parameters.AddWithValue("@StuId", studentId);
                tog.Parameters.AddWithValue("@CourseId", courseId);
                tog.ExecuteNonQuery();

                return isFav ? "removed" : "added";
            }
        }
    }
}
