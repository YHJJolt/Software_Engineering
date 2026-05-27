using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web;

namespace SchoolSystem
{
    [ScriptService]
    public partial class LecturerCalendar : System.Web.UI.Page
    {
        private static int GetLecturerId()
        {
            string[] possibleKeys = {
                "LecturerID", "LecturerId", "lecturer_id", "UserID", "UserId"
            };

            foreach (var key in possibleKeys)
            {
                var val = HttpContext.Current.Session[key];
                if (val != null)
                    return Convert.ToInt32(val);
            }

            throw new Exception("Lecturer ID not found in session.");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LecturerMaster master = (LecturerMaster)this.Master;
                master.PageTitle = "Calendar";
            }
        }

        [WebMethod]
        public static object AddEvent(string title, string desc, string start, string end, string type)
        {
            try
            {
                int lecturerId = GetLecturerId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"
                        INSERT INTO LecturerCalendar 
                        (event_title, event_desc, start_date, end_date, event_type, 
                         visibility, lecturer_id)
                        VALUES (@title, @desc, @start, @end, @type, 'Private', @lecturerId)";

                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? DBNull.Value : (object)desc);
                    cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                    cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? DBNull.Value : (object)DateTime.Parse(end));
                    cmd.Parameters.AddWithValue("@type", type);
                    cmd.Parameters.AddWithValue("@lecturerId", lecturerId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return new { status = "success" };
            }
            catch (Exception ex)
            {
                return new { status = "error", message = ex.Message };
            }
        }


        [WebMethod]
        // GET LECTURER EVENTS - Only own Private events
        public static object GetEvents()
        {
            var events = new List<object>();
            try
            {
                int lecturerId = GetLecturerId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(@"
            SELECT calendar_id, event_title, event_desc, start_date, end_date, 
                   event_type, visibility, lecturer_id
            FROM LecturerCalendar
            WHERE lecturer_id = @lecturerId", conn))   // Only own events for lecturer
                {
                    cmd.Parameters.AddWithValue("@lecturerId", lecturerId);
                    conn.Open();

                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        while (sdr.Read())
                        {
                            events.Add(new
                            {
                                id = sdr["calendar_id"].ToString(),
                                title = sdr["event_title"].ToString(),
                                description = sdr["event_desc"] == DBNull.Value ? "" : sdr["event_desc"].ToString(),
                                start = Convert.ToDateTime(sdr["start_date"]).ToString("yyyy-MM-dd"),
                                end = sdr["end_date"] == DBNull.Value
                                    ? null
                                    : Convert.ToDateTime(sdr["end_date"]).ToString("yyyy-MM-dd"),
                                type = sdr["event_type"].ToString(),
                                visibility = sdr["visibility"].ToString(),
                                isOwner = true
                            });
                        }
                    }
                }
            }
            catch { /* Fail silently */ }
            return events;
        }

        // ---------------------------------------------------------------
        // GET ADMIN EVENTS  — read-only, pulled from the admin Calendar table
        // ---------------------------------------------------------------
        [WebMethod]
        public static object GetAdminEvents()
        {
            var events = new List<object>();
            try
            {
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(@"
            SELECT calendar_id, event_title, event_desc, start_date, end_date, event_type
            FROM Calendar", conn))
                {
                    conn.Open();
                    using (SqlDataReader sdr = cmd.ExecuteReader())
                    {
                        while (sdr.Read())
                        {
                            events.Add(new
                            {
                                id = "admin-" + sdr["calendar_id"].ToString(),
                                title = sdr["event_title"].ToString(),
                                description = sdr["event_desc"] == DBNull.Value ? "" : sdr["event_desc"].ToString(),
                                start = Convert.ToDateTime(sdr["start_date"]).ToString("yyyy-MM-dd"),
                                end = sdr["end_date"] == DBNull.Value ? null : Convert.ToDateTime(sdr["end_date"]).ToString("yyyy-MM-dd"),
                                type = sdr["event_type"].ToString(),
                                source = "admin"
                            });
                        }
                    }
                }
            }
            catch { }
            return events;
        }

        // ---------------------------------------------------------------
        // UPDATE  — lecturer can only update their own events
        // ---------------------------------------------------------------
        [WebMethod]
        public static object UpdateEvent(int id, string title, string desc, string start,
                                         string end, string type, string visibility)
        {
            try
            {
                int lecturerId = GetLecturerId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"UPDATE LecturerCalendar
                                     SET    event_title = @title,
                                            event_desc  = @desc,
                                            start_date  = @start,
                                            end_date    = @end,
                                            event_type  = @type,
                                            visibility  = @visibility
                                     WHERE  calendar_id = @id
                                       AND  lecturer_id = @lecturerId";  // ownership check
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : (object)desc);
                        cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                        cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? (object)DBNull.Value : (object)DateTime.Parse(end));
                        cmd.Parameters.AddWithValue("@type", type);
                        cmd.Parameters.AddWithValue("@visibility", visibility);
                        cmd.Parameters.AddWithValue("@lecturerId", lecturerId);
                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();
                        if (rows == 0)
                            return new { status = "error", message = "Event not found or you do not have permission to edit it." };
                    }
                }
                return new { status = "success" };
            }
            catch (Exception ex) { return new { status = "error", message = ex.Message }; }
        }

        // ---------------------------------------------------------------
        // DELETE  — lecturer can only delete their own events
        // ---------------------------------------------------------------
        [WebMethod]
        public static object DeleteEvent(int id)
        {
            try
            {
                int lecturerId = GetLecturerId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"DELETE FROM LecturerCalendar 
                                     WHERE calendar_id = @id 
                                       AND lecturer_id = @lecturerId";   // ownership check
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@lecturerId", lecturerId);
                        conn.Open();
                        int rows = cmd.ExecuteNonQuery();
                        if (rows == 0)
                            return new { status = "error", message = "Event not found or you do not have permission to delete it." };
                    }
                }
                return new { status = "success" };
            }
            catch (Exception ex) { return new { status = "error", message = ex.Message }; }
        }
    }
}