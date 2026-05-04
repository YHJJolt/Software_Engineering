using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.HtmlControls;

namespace SchoolSystem
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");
            if (!IsPostBack)
            {
                LoadSidebarProfile();
                HighlightActiveSideBar();
            }
        }

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Fetching from [Admin (HoP)] as defined in the technical project structure
                string sql = "SELECT admin_name, admin_img FROM [Admin (HoP)] WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litSidebarName.Text = rdr["admin_name"].ToString();
                    if (rdr["admin_img"] != DBNull.Value)
                    {
                        imgSidebar.ImageUrl = "data:image/png;base64," + Convert.ToBase64String((byte[])rdr["admin_img"]);
                    }
                }
            }
        }

        private void HighlightActiveSideBar()
        {
            string currentPage = Request.Url.AbsolutePath.ToLowerInvariant();
            HtmlAnchor[] links = { linkDashboard, linkUsers, linkPayment, linkCourses, linkEnrolment, linkPerformance, linkAnnouncements, linkCalendar };

            foreach (var link in links)
            {
                if (link != null)
                {
                    if (link.Attributes["class"].Contains("sub-link"))
                        link.Attributes["class"] = "nav-link sub-link";
                    else
                        link.Attributes["class"] = "nav-link";
                }
            }

            if (currentPage.Contains("admindashboard") && linkDashboard != null) linkDashboard.Attributes["class"] += " active";
            else if (currentPage.Contains("usermanagement") && linkUsers != null) linkUsers.Attributes["class"] += " active";
            else if (currentPage.Contains("payments") && linkPayment != null) linkPayment.Attributes["class"] += " active";
            else if (currentPage.Contains("coursemanagement") && linkCourses != null) linkCourses.Attributes["class"] += " active";
            else if (currentPage.Contains("enrolment") && linkEnrolment != null) linkEnrolment.Attributes["class"] += " active";
            else if (currentPage.Contains("studentperformance") && linkPerformance != null) linkPerformance.Attributes["class"] += " active";
            else if (currentPage.Contains("announcement") && linkAnnouncements != null) linkAnnouncements.Attributes["class"] += " active";
            else if (currentPage.Contains("calendar") && linkCalendar != null) linkCalendar.Attributes["class"] += " active";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("RoleSelect.aspx");
        }
    }
}