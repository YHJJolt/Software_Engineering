using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;

namespace SchoolSystem
{
    public partial class LecturerAnnouncement : System.Web.UI.Page
    {
        // Effective academic session for this page: the URL value if present, otherwise the
        // current global session. This lets the page work whether reached from the course
        // dashboard (no session in URL) or the courses list (session in URL).
        protected string EffectiveSession = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            EffectiveSession = Request.QueryString["session"];
            if (string.IsNullOrEmpty(EffectiveSession))
                EffectiveSession = GetCurrentSession();

            if (!IsPostBack)
            {
                LecturerCourseMaster master = (LecturerCourseMaster)this.Master;
                master.PageTitle = "Announcements";
                EnsureAnnouncementSessionColumn();
            }
        }

        private static string GetCurrentSession()
        {
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session'", conn))
            {
                conn.Open();
                return cmd.ExecuteScalar()?.ToString() ?? "";
            }
        }

        private static void EnsureAnnouncementSessionColumn()
        {
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            string sql = @"IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Announcement') AND name = 'academic_session')
                           ALTER TABLE Announcement ADD academic_session VARCHAR(7) NULL";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                new SqlCommand(sql, conn).ExecuteNonQuery();
            }
        }

        [WebMethod]
        public static List<Announcement> GetAnnouncements(int courseId, string session)
        {
            List<Announcement> list = new List<Announcement>();
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT a.announcement_id, a.title, a.content, a.category,
                      a.created_at,
                      ISNULL(l.lecturer_name, 'Admin') as lecturer_name
                   FROM Announcement a
                   LEFT JOIN Lecturer l ON a.Lecturer_id = l.lecturer_id
                   WHERE a.Course_id = @CourseID
                     AND (@Session = '' OR a.academic_session = @Session)
                   ORDER BY a.created_at DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseID", courseId);
                cmd.Parameters.AddWithValue("@Session", session ?? "");
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                while (dr.Read())
                {
                    list.Add(new Announcement
                    {
                        Announcement_id = Convert.ToInt32(dr["announcement_id"]),
                        Title = dr["title"].ToString(),
                        Content = dr["content"].ToString(),
                        Category = dr["category"].ToString(),
                        Created_at = Convert.ToDateTime(dr["created_at"]).ToString("dd MMM yyyy"),
                        Created_time = Convert.ToDateTime(dr["created_at"]).ToString("hh:mm tt"),
                        Lecturer_name = dr["lecturer_name"].ToString(),
                        Lecturer_img = ""
                    });
                }
            }
            return list;
        }

        [WebMethod]
        public static bool SaveAnnouncement(int id, string title, string content, string category, int courseId, string session)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(session))
                    return false;

                string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "";
                    if (id == 0)
                    {
                        // ✅ Guard: session must exist for INSERT
                        if (HttpContext.Current.Session["UserEmail"] == null)
                            return false;

                        sql = @"INSERT INTO Announcement
                        (title, content, category, Lecturer_id, Course_id, academic_session, created_at)
                        VALUES (@title, @content, @category,
                                (SELECT lecturer_id FROM Lecturer WHERE lecturer_email = @Email),
                                @CourseID,
                                @Session,
                                GETDATE())";
                    }
                    else
                    {
                        sql = @"UPDATE Announcement
                        SET title=@title, content=@content, category=@category
                        WHERE announcement_id=@id AND Course_id=@CourseID
                          AND academic_session = @Session";
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        if (id != 0)
                            cmd.Parameters.AddWithValue("@id", id);

                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@content", content);
                        cmd.Parameters.AddWithValue("@category", category);
                        cmd.Parameters.AddWithValue("@CourseID", courseId);
                        cmd.Parameters.AddWithValue("@Session", session);

                        // ✅ Always add @Email for INSERT (session already validated above)
                        if (id == 0)
                            cmd.Parameters.AddWithValue("@Email", HttpContext.Current.Session["UserEmail"].ToString());

                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();
                        return rows > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Save Error: " + ex.Message);
                return false;
            }
        }

        [WebMethod]
        public static bool DeleteAnnouncement(int id, int courseId, string session)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"DELETE FROM Announcement WHERE announcement_id=@id AND Course_id=@CourseID
                                    AND academic_session = @Session";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    cmd.Parameters.AddWithValue("@Session", session ?? "");
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        public class Announcement
        {
            public int Announcement_id { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string Category { get; set; }
            public string Created_at { get; set; }
            public string Created_time { get; set; }
            public string Lecturer_name { get; set; }
            public string Lecturer_img { get; set; }
            public string Admin_id { get; set; }
        }
    }
}