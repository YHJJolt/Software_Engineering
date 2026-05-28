using System;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class RoleSelect : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Simple redirection check can be added here if needed
        }

        protected void btnRole_Click(object sender, EventArgs e)
        {
            // Get the role from the CommandArgument of the button that was clicked
            LinkButton btn = (LinkButton)sender;
            string selectedRole = btn.CommandArgument;

            // Store the role in the Session to pass to the next page
            Session["SelectedRole"] = selectedRole;

            // Redirect to the universal Login page
            Response.Redirect("~/Login.aspx");
        }
    }
}