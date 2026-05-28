using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class LecturerMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        public string PageTitle
        {
            get { return litPageTitle.Text; }
            set { litPageTitle.Text = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");
            if (!IsPostBack)
            {
                LoadSidebarProfile();
                HighlightActiveSideBar();
                LoadNotifications();
            }
        }

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT lecturer_name, lecturer_img FROM [Lecturer] WHERE lecturer_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litSidebarName.Text = rdr["lecturer_name"].ToString();
                    if (rdr["lecturer_img"] != DBNull.Value)
                    {
                        byte[] bytes = (rdr["lecturer_img"] as byte[]);
                        imgSidebar.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(bytes);
                    }
                }
            }
        }

        private void LoadNotifications()
        {
            DataTable dtNotifs = new DataTable();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // SQL query updated to ONLY fetch Admin Announcements, 
                // completely removing the "Low Marks" union section.
                string sql = @"
            SELECT 'Admin Announcement' as Type, 
                   N'📢 [Posted by Admin] ' + title as Message,
                   'info' as CssClass
            FROM Announcement
            WHERE admin_id IS NOT NULL";

                SqlCommand cmd = new SqlCommand(sql, conn);

                // If your original code had parameters for other things, they are no longer needed here 
                // since we are only fetching global admin announcements.

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtNotifs);

                litNotifCount.Text = dtNotifs.Rows.Count.ToString();
                if (dtNotifs.Rows.Count > 0)
                {
                    noNotifs.Visible = false;
                    rptNotifications.DataSource = dtNotifs;
                    rptNotifications.DataBind();
                }
                else
                {
                    noNotifs.Visible = true;
                }
            }
        }

        private void HighlightActiveSideBar()
        {
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
            if (currentPage.Contains("dashboard")) linkDashboard.Attributes["class"] += " active";
            else if (currentPage.Contains("calendar")) linkCalendar.Attributes["class"] += " active";
            else if (currentPage.Contains("course")) linkCourses.Attributes["class"] += " active";
        }
    }
}