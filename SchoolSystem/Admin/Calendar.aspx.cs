using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Services;
using System.Collections.Generic;
using System.Web.Services;

namespace SchoolSystem
{
    [ScriptService]
    public partial class Calendar : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        [WebMethod]
        public static object AddEvent(string title, string desc, string start, string end, string type)
        {
            try
            {
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                DateTime startDt = DateTime.Parse(start);
                DateTime? endDt = string.IsNullOrWhiteSpace(end) ? (DateTime?)null : DateTime.Parse(end);

                // Time logic: end cannot be before start
                if (endDt.HasValue && endDt.Value < startDt)
                    return new { status = "error", message = "End date cannot be earlier than the start date." };

                // Duplicate: same title on same start date
                using (SqlConnection vconn = new SqlConnection(connString))
                using (SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(1) FROM Calendar WHERE event_title = @t AND CAST(start_date AS DATE) = @d", vconn))
                {
                    chk.Parameters.AddWithValue("@t", title);
                    chk.Parameters.AddWithValue("@d", startDt.Date);
                    vconn.Open();
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return new { status = "error", message = "An event with this name already exists on that date." };
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"INSERT INTO Calendar (event_title, event_desc, start_date, end_date, event_type, admin_id) 
                                     VALUES (@title, @desc, @start, @end, @type, @adminId)";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : desc);
                        cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                        cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? (object)DBNull.Value : DateTime.Parse(end));
                        cmd.Parameters.AddWithValue("@type", type);
                        cmd.Parameters.AddWithValue("@adminId", 1);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                return new { status = "success" };
            }
            catch (Exception ex) { return new { status = "error", message = ex.Message }; }
        }

        [WebMethod]
        public static object GetEvents()
        {
            List<object> events = new List<object>();
            string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT calendar_id, event_title, event_desc, start_date, end_date, event_type FROM Calendar";
                SqlCommand cmd = new SqlCommand(query, conn);
                conn.Open();
                SqlDataReader sdr = cmd.ExecuteReader();
                while (sdr.Read())
                {
                    events.Add(new
                    {
                        id = sdr["calendar_id"].ToString(),
                        title = sdr["event_title"].ToString(),
                        description = sdr["event_desc"] == DBNull.Value ? "" : sdr["event_desc"].ToString(),
                        start = Convert.ToDateTime(sdr["start_date"]).ToString("yyyy-MM-dd"),
                        end = sdr["end_date"] == DBNull.Value ? (string)null : Convert.ToDateTime(sdr["end_date"]).ToString("yyyy-MM-dd"),
                        type = sdr["event_type"].ToString()
                    });
                }
            }
            return events;
        }

        [WebMethod]
        public static object UpdateEvent(int id, string title, string desc, string start, string end, string type)
        {
            try
            {
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                DateTime startDt = DateTime.Parse(start);
                DateTime? endDt = string.IsNullOrWhiteSpace(end) ? (DateTime?)null : DateTime.Parse(end);

                if (endDt.HasValue && endDt.Value < startDt)
                    return new { status = "error", message = "End date cannot be earlier than the start date." };

                using (SqlConnection vconn = new SqlConnection(connString))
                using (SqlCommand chk = new SqlCommand(
                    "SELECT COUNT(1) FROM Calendar WHERE event_title = @t AND CAST(start_date AS DATE) = @d AND calendar_id <> @id", vconn))
                {
                    chk.Parameters.AddWithValue("@t", title);
                    chk.Parameters.AddWithValue("@d", startDt.Date);
                    chk.Parameters.AddWithValue("@id", id);
                    vconn.Open();
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return new { status = "error", message = "An event with this name already exists on that date." };
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"UPDATE Calendar SET event_title=@title, event_desc=@desc, 
                                     start_date=@start, end_date=@end, event_type=@type 
                                     WHERE calendar_id=@id";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : desc);
                        cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                        cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? (object)DBNull.Value : DateTime.Parse(end));
                        cmd.Parameters.AddWithValue("@type", type);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                return new { status = "success" };
            }
            catch (Exception ex) { return new { status = "error", message = ex.Message }; }
        }

        [WebMethod]
        public static object DeleteEvent(int id)
        {
            try
            {
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Calendar WHERE calendar_id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                return new { status = "success" };
            }
            catch (Exception ex) { return new { status = "error", message = ex.Message }; }
        }
    }
}