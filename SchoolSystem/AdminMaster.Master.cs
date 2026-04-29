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
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("RoleSelect.aspx");
        }
    }
}