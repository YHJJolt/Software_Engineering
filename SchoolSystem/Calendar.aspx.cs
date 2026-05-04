using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;

namespace SchoolSystem
{
    public partial class Calendar : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // 🔥 GET EVENTS (for calendar + list)
        [WebMethod]
        public static List<object> GetEvents()
        {
            List<object> events = new List<object>();

            using (SqlConnection conn = new SqlConnection(
                ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString))
            {
                conn.Open();
                string query = "SELECT * FROM Calendar";

                SqlCommand cmd = new SqlCommand(query, conn);
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    string type = reader["event_type"].ToString();

                    // 🎨 Color mapping
                    string color = "#3498db"; // default
                    if (type == "Exam") color = "#e74c3c";
                    else if (type == "Holiday") color = "#2ecc71";
                    else if (type == "Enrollment") color = "#f39c12";

                    events.Add(new
                    {
                        id = reader["calendar_id"],
                        title = reader["event_title"].ToString(),
                        start = Convert.ToDateTime(reader["start_date"]).ToString("yyyy-MM-dd"),
                        end = reader["end_date"] == DBNull.Value
                                ? null
                                : Convert.ToDateTime(reader["end_date"]).ToString("yyyy-MM-dd"),
                        description = reader["event_desc"]?.ToString(),
                        color = color
                    });
                }
            }

            return events;
        }

        // 🔥 ADD EVENT (from modal)
        [WebMethod]
        public static void AddEvent(string title, string desc, string start, string end, string type)
        {
            using (SqlConnection conn = new SqlConnection(
                ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString))
            {
                conn.Open();

                string query = @"INSERT INTO Calendar
                    (event_title, event_desc, start_date, end_date, event_type, Admin_id)
                    VALUES (@title, @desc, @start, @end, @type, 1)";

                SqlCommand cmd = new SqlCommand(query, conn);

                cmd.Parameters.AddWithValue("@title", title);
                cmd.Parameters.AddWithValue("@desc", desc);
                cmd.Parameters.AddWithValue("@start", start);

                // handle NULL end date
                if (string.IsNullOrEmpty(end))
                    cmd.Parameters.AddWithValue("@end", DBNull.Value);
                else
                    cmd.Parameters.AddWithValue("@end", end);

                cmd.Parameters.AddWithValue("@type", type);

                cmd.ExecuteNonQuery();
            }
        }
    }
}