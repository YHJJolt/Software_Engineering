using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        public string ChartLabels = "[]";
        public string ChartData = "[]";

        public string ActiveTab
        {
            get { return ViewState["ActiveTab"]?.ToString() ?? "Announce"; }
            set { ViewState["ActiveTab"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadStats();
            LoadProgramDistribution();

            if (!IsPostBack) LoadHubData();
        }

        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // Counts current students only (Active + Inactive), excluding graduated alumni
                litStudents.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Student] WHERE student_isactive <> 'Graduated'", conn).ExecuteScalar());
                litLecturers.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Lecturer]", conn).ExecuteScalar());
                litCourses.Text = Convert.ToString(new SqlCommand("SELECT COUNT(*) FROM [Course]", conn).ExecuteScalar());
            }
        }

        private void LoadProgramDistribution()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Excludes graduated alumni so the chart total matches the Students stat card
                string sql = "SELECT p.program_name, COUNT(s.student_id) as Total FROM [Program] p LEFT JOIN [Student] s " +
                    "ON p.program_id = s.Program_id AND s.student_isactive <> 'Graduated' GROUP BY p.program_name";
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

        private void LoadHubData()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sortDir = ddlSort.SelectedValue;

                // FIXED: Changed 'event_id' to 'calendar_id' to match your database schema!
                string sql = (ActiveTab == "Announce")
                    ? $"SELECT TOP 5 announcement_id as ID, title as Title, created_at as DisplayDate, content as Content, 'Announce' as Type FROM [Announcement] ORDER BY created_at {sortDir}"
                    : $"SELECT TOP 5 calendar_id as ID, event_title as Title, start_date as DisplayDate, event_desc as Content, event_type as Type FROM [Calendar] ORDER BY start_date {sortDir}";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptHub.DataSource = dt;
                rptHub.DataBind();
            }
        }

        protected void btnShowAnnounce_Click(object sender, EventArgs e)
        {
            ActiveTab = "Announce";
            btnShowAnnounce.CssClass = "tab-btn active";
            btnShowCalendar.CssClass = "tab-btn";
            LoadHubData();
        }

        protected void btnShowCalendar_Click(object sender, EventArgs e)
        {
            ActiveTab = "Calendar";
            btnShowAnnounce.CssClass = "tab-btn";
            btnShowCalendar.CssClass = "tab-btn active";
            LoadHubData();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadHubData();
        }
    }
}