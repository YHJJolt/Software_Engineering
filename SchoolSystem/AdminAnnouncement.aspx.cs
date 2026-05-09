using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;

namespace SchoolSystem
{
    public partial class AdminAnnouncement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Usually empty as we use AJAX WebMethods for data
        }

        [WebMethod]
        public static List<Announcement> GetAnnouncements()
        {
            List<Announcement> list = new List<Announcement>();
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Note: Ensure your column names match your SQL Table exactly
                string sql = "SELECT announcement_id, title, content, category, created_at, admin_id FROM Announcement ORDER BY created_at DESC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    list.Add(new Announcement
                    {
                        announcement_id = Convert.ToInt32(dr["announcement_id"]),
                        title = dr["title"].ToString(),
                        content = dr["content"].ToString(),
                        category = dr["category"].ToString(),
                        created_at = Convert.ToDateTime(dr["created_at"]).ToString("dd MMM yyyy"),
                        admin_id = dr["admin_id"].ToString()
                    });
                }
            }
            return list;
        }

        [WebMethod]
        public static bool SaveAnnouncement(int id, string title, string content, string category)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "";
                    if (id == 0)
                    {
                        // Ensure column names match your Announcement table exactly
                        sql = "INSERT INTO Announcement (title, content, category, created_at, admin_id) " +
                              "VALUES (@title, @content, @category, GETDATE(), '1')";
                    }
                    else
                    {
                        sql = "UPDATE Announcement SET title=@title, content=@content, category=@category " +
                              "WHERE announcement_id=@id";
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        // Handle the ID for Updates
                        if (id != 0)
                            cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;

                        // Use NVarChar for text to handle special characters correctly
                        cmd.Parameters.Add("@title", SqlDbType.NVarChar, 255).Value = title ?? (object)DBNull.Value;
                        cmd.Parameters.Add("@content", SqlDbType.NVarChar, -1).Value = content ?? (object)DBNull.Value;
                        cmd.Parameters.Add("@category", SqlDbType.NVarChar, 50).Value = category ?? (object)DBNull.Value;

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                // Throwing the exception allows the AJAX 'error' function to catch the actual SQL error
                throw new Exception("Database Error: " + ex.Message);
            }
        }

        [WebMethod]
        public static bool DeleteAnnouncement(int id)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "DELETE FROM Announcement WHERE announcement_id=@id";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        // Data Model Class
        public class Announcement
        {
            public int announcement_id { get; set; }
            public string title { get; set; }
            public string content { get; set; }
            public string category { get; set; }
            public string created_at { get; set; }
            public string admin_id { get; set; }
        }
    }
}