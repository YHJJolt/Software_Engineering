using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;

namespace SchoolSystem.Student
{
    public partial class StudentAnnouncement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                StudentCourseMaster master = (StudentCourseMaster)this.Master;
                master.PageTitle = "Announcements";
            }
        }

        [WebMethod]
        public static List<Announcement> GetAnnouncements(int courseId)
        {
            List<Announcement> list = new List<Announcement>();
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            SELECT a.announcement_id, a.title, a.content, a.category,
                   a.created_at,
                   ISNULL(l.lecturer_name, 'Admin') AS lecturer_name
            FROM Announcement a
            LEFT JOIN Lecturer l ON a.Lecturer_id = l.lecturer_id
            WHERE a.Course_id = @CourseID
            ORDER BY a.created_at DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CourseID", courseId);
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
        }
    }
}