using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace SchoolSystem
{
    public partial class LecturerCourses : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) return;

            ((LecturerMaster)Master).PageTitle = "Courses";

            EnsureFavouriteTableExists();

            if (!IsPostBack)
            {
                BindCourseData();
            }
        }

        private void EnsureFavouriteTableExists()
        {
            string sql = @"
                IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LecturerCourseFavourite')
                BEGIN
                    CREATE TABLE [LecturerCourseFavourite] (
                        [fav_id]      INT      NOT NULL IDENTITY(1,1) PRIMARY KEY,
                        [lecturer_id] INT      NOT NULL,
                        [course_id]   INT      NOT NULL,
                        [created_at]  DATETIME DEFAULT GETDATE(),
                        CONSTRAINT [UQ_LecFav]          UNIQUE      ([lecturer_id], [course_id]),
                        CONSTRAINT [FK_LecFav_Lecturer] FOREIGN KEY ([lecturer_id])
                            REFERENCES [Lecturer] ([lecturer_id]),
                        CONSTRAINT [FK_LecFav_Course]   FOREIGN KEY ([course_id])
                            REFERENCES [Course]   ([course_id])
                    );
                END";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                new SqlCommand(sql, conn).ExecuteNonQuery();
            }
        }

        private void BindCourseData()
        {
            if (Session["UserEmail"] == null) return;

            // Query updated to count all approved enrollments, removing the current semester filter
            string sql = @"
        SELECT
            c.course_id,
            c.course_name,
            c.course_code,
            c.course_img,
            ISNULL(p.program_semester, 0)  AS sem_num,
            CASE
                WHEN p.program_semester IS NOT NULL
                THEN 'Sem ' + CAST(p.program_semester AS NVARCHAR(5))
                ELSE 'N/A'
            END AS semester_label,
            (SELECT COUNT(DISTINCT e.student_id)
             FROM Enrollment e
             WHERE e.course_id = c.course_id 
               AND e.status = 'Approved') AS student_count,
            CASE WHEN f.fav_id IS NOT NULL THEN 1 ELSE 0 END AS is_favourite
        FROM [Course] c
        INNER JOIN [Lecturer] l ON c.Lecturer_id = l.lecturer_id
        INNER JOIN [Program]  p ON c.Program_id  = p.program_id
        LEFT  JOIN [LecturerCourseFavourite] f
               ON f.course_id   = c.course_id
              AND f.lecturer_id = l.lecturer_id
        WHERE l.lecturer_email = @Email
        ORDER BY c.course_name ASC";

            var list = new List<object>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                while (rdr.Read())
                {
                    bool published = true; // Or false, depending on your new default preference

                    string imgSrc = "";
                    if (rdr["course_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["course_img"];
                        imgSrc = "data:image/png;base64," + Convert.ToBase64String(bytes);
                    }

                    list.Add(new
                    {
                        id = Convert.ToInt32(rdr["course_id"]),
                        name = rdr["course_name"].ToString(),
                        code = rdr["course_code"].ToString(),
                        sem = rdr["semester_label"].ToString(),
                        semNum = Convert.ToInt32(rdr["sem_num"]),
                        students = Convert.ToInt32(rdr["student_count"]),
                        published = published,
                        fav = Convert.ToInt32(rdr["is_favourite"]) == 1,
                        img = imgSrc
                    });
                }
            }

            var serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = Int32.MaxValue;
            hfCourseData.Value = serializer.Serialize(list);
        }

        [WebMethod]
        public static string ToggleFavourite(int courseId, string email)
        {
            string connStr = System.Configuration.ConfigurationManager
                                .ConnectionStrings["SchoolSystemDB"].ConnectionString;

            string sqlGetLec = "SELECT lecturer_id FROM [Lecturer] WHERE lecturer_email = @Email";
            string sqlCheck = "SELECT COUNT(1) FROM [LecturerCourseFavourite] WHERE lecturer_id = @LecId AND course_id = @CourseId";
            string sqlInsert = "INSERT INTO [LecturerCourseFavourite] (lecturer_id, course_id) VALUES (@LecId, @CourseId)";
            string sqlDelete = "DELETE FROM [LecturerCourseFavourite] WHERE lecturer_id = @LecId AND course_id = @CourseId";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                SqlCommand lecCmd = new SqlCommand(sqlGetLec, conn);
                lecCmd.Parameters.AddWithValue("@Email", email);
                object lecObj = lecCmd.ExecuteScalar();
                if (lecObj == null) return "error";
                int lecturerId = Convert.ToInt32(lecObj);

                SqlCommand chk = new SqlCommand(sqlCheck, conn);
                chk.Parameters.AddWithValue("@LecId", lecturerId);
                chk.Parameters.AddWithValue("@CourseId", courseId);
                bool isFav = (int)chk.ExecuteScalar() > 0;

                SqlCommand tog = new SqlCommand(isFav ? sqlDelete : sqlInsert, conn);
                tog.Parameters.AddWithValue("@LecId", lecturerId);
                tog.Parameters.AddWithValue("@CourseId", courseId);
                tog.ExecuteNonQuery();

                return isFav ? "removed" : "added";
            }
        }
    }
}