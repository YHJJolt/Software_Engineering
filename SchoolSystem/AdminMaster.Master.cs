using System;

namespace SchoolSystem
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: Security check to ensure only Admins are here
            if (Session["SelectedRole"] == null || Session["SelectedRole"].ToString() != "HOP")
            {
                Response.Redirect("RoleSelect.aspx");
            }
            highlightActiveSideBar(); //Changes made here new method for active sidebar highlighting
        }

        private void highlightActiveSideBar()
        {
            string currentPage = Request.Url.AbsolutePath.ToLowerInvariant();

            // Reset all links first
            linkDashboard.Attributes["class"] = "nav-link";
            linkUsers.Attributes["class"] = "nav-link";
            linkCourses.Attributes["class"] = "nav-link";
            linkAnnouncements.Attributes["class"] = "nav-link";

            // Set active on current page
            if (currentPage.Contains("admindashboard"))
                linkDashboard.Attributes["class"] = "nav-link active";
            else if (currentPage.Contains("courses"))
                linkCourses.Attributes["class"] = "nav-link active";
            else if (currentPage.Contains("user"))
                linkUsers.Attributes["class"] = "nav-link active";
            else if (currentPage.Contains("announcement"))
                linkAnnouncements.Attributes["class"] = "nav-link active";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("RoleSelect.aspx");
        }
    }
}
