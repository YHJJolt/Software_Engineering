using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web;

namespace SchoolSystem.Student
{
    [ScriptService]
    public partial class StudentCalendar : System.Web.UI.Page
    {
        private static int GetStudentId()
        {
            string[] possibleKeys = {
                "StudentID", "StudentId", "student_id", "UserID", "UserId"
            };

            foreach (var key in possibleKeys)
            {
                var val = HttpContext.Current.Session[key];
                if (val != null)
                    return Convert.ToInt32(val);
            }

            throw new Exception("Student ID not found in session.");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                StudentMaster master = (StudentMaster)this.Master;
                master.PageTitle = "Calendar";
            }
        }

        [WebMethod]
        public static object AddEvent(string title, string desc, string start, string end, string type)
        {
            try
            {
                int studentId = GetStudentId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"
                        INSERT INTO StudentCalendar 
                        (event_title, event_desc, start_date, end_date, event_type, 
                         visibility, student_id)
                        VALUES (@title, @desc, @start, @end, @type, 'Private', @studentId)";

                    cmd.Parameters.AddWithValue("@title", title);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? DBNull.Value : (object)desc);
                    cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                    cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? DBNull.Value : (object)DateTime.Parse(end));
                    cmd.Parameters.AddWithValue("@type", type);
                    cmd.Parameters.AddWithValue("@studentId", studentId);

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
        public static object GetEvents()
        {
            var events = new List<object>();
            try
            {
                int studentId = GetStudentId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT calendar_id, event_title, event_desc, start_date, end_date, 
                           event_type, visibility, student_id
                    FROM StudentCalendar
                    WHERE student_id = @studentId", conn))
                {
                    cmd.Parameters.AddWithValue("@studentId", studentId);
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

        [WebMethod]
        public static object UpdateEvent(int id, string title, string desc, string start,
                                         string end, string type, string visibility)
        {
            try
            {
                int studentId = GetStudentId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"UPDATE StudentCalendar
                                     SET    event_title = @title,
                                            event_desc  = @desc,
                                            start_date  = @start,
                                            end_date    = @end,
                                            event_type  = @type,
                                            visibility  = @visibility
                                     WHERE  calendar_id = @id
                                       AND  student_id  = @studentId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@title", title);
                        cmd.Parameters.AddWithValue("@desc", string.IsNullOrWhiteSpace(desc) ? (object)DBNull.Value : (object)desc);
                        cmd.Parameters.AddWithValue("@start", DateTime.Parse(start));
                        cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(end) ? (object)DBNull.Value : (object)DateTime.Parse(end));
                        cmd.Parameters.AddWithValue("@type", type);
                        cmd.Parameters.AddWithValue("@visibility", visibility);
                        cmd.Parameters.AddWithValue("@studentId", studentId);
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

        [WebMethod]
        public static object DeleteEvent(int id)
        {
            try
            {
                int studentId = GetStudentId();
                string connString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"DELETE FROM StudentCalendar 
                                     WHERE calendar_id = @id 
                                       AND student_id  = @studentId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.Parameters.AddWithValue("@studentId", studentId);
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