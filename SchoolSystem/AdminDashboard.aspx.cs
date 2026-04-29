using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace SchoolSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        public string ChartLabels = "[]";
        public string ChartData = "[]";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                try
                {
                    LoadStats();
                    LoadAnnouncements();
                    LoadCalendarSchedule();
                    LoadProgramDistribution();
                }
                catch (Exception ex)
                {
                    // Log the error to the Output window if something fails
                    System.Diagnostics.Debug.WriteLine("Dashboard Error: " + ex.Message);
                }
            }
        }

        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // These counts stay the same regardless of how many columns are in the tables
                litStudents.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Student]", conn).ExecuteScalar());
                litLecturers.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Lecturer]", conn).ExecuteScalar());
                litCourses.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Course]", conn).ExecuteScalar());
            }
        }

        private void LoadAnnouncements()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT TOP 4 title, created_at FROM [Announcement] ORDER BY created_at DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
            }
        }

        private void LoadCalendarSchedule()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Pulling from our new flexible start_date column
                string sql = "SELECT TOP 4 event_title, start_date FROM [Calendar] WHERE start_date >= GETDATE() ORDER BY start_date ASC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptSchedule.DataSource = dt;
                rptSchedule.DataBind();
            }
        }

        private void LoadProgramDistribution()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT p.program_name, COUNT(s.student_id) as Total 
                             FROM [Program] p 
                             LEFT JOIN [Student] s ON p.program_id = s.Program_id 
                             GROUP BY p.program_name";

                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();

                List<string> labels = new List<string>();
                List<int> data = new List<int>();

                while (rdr.Read())
                {
                    labels.Add(rdr["program_name"].ToString());
                    data.Add(Convert.ToInt32(rdr["Total"]));
                }

                JavaScriptSerializer js = new JavaScriptSerializer();
                ChartLabels = js.Serialize(labels);
                ChartData = js.Serialize(data);
            }
        }
    }
}