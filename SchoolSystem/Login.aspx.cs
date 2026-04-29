using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class Login : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // If someone tries to access Login without picking a role, send them back
            if (!IsPostBack && Session["SelectedRole"] == null)
            {
                Response.Redirect("RoleSelect.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string inputEmail = txtEmail.Text.Trim();
            string inputPassword = txtPassword.Text.Trim();
            string selectedRole = Session["SelectedRole"]?.ToString();

            lblMessage.Visible = false;

            if (string.IsNullOrEmpty(inputEmail) || string.IsNullOrEmpty(inputPassword))
            {
                ShowErrorMessage("Please enter both email and password.");
                return;
            }

            string tableName = "";
            string emailColumn = "";
            string passColumn = "";
            string nameColumn = "";

            // Identify which table to check based on the role selected in RoleSelect.aspx
            switch (selectedRole)
            {
                case "HOP":
                    tableName = "[Admin (HoP)]";
                    emailColumn = "admin_email";
                    passColumn = "admin_pw";
                    nameColumn = "admin_name";
                    break;
                case "Lecturer":
                    tableName = "[Lecturer]";
                    emailColumn = "lecturer_email";
                    passColumn = "lecture_pw";
                    nameColumn = "lecturer_name";
                    break;
                case "Student":
                    tableName = "[Student]";
                    emailColumn = "student_email";
                    passColumn = "student_pw";
                    nameColumn = "student_name";
                    break;
            }

            string sqlQuery = $"SELECT * FROM {tableName} WHERE {emailColumn} = @Email AND {passColumn} = @Password";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sqlQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", inputEmail);
                    cmd.Parameters.AddWithValue("@Password", inputPassword);

                    try
                    {
                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            // SUCCESS: Store user data in Session
                            Session["UserEmail"] = reader[emailColumn].ToString();
                            Session["UserName"] = reader[nameColumn].ToString();
                            Session["UserRole"] = selectedRole;

                            // REDIRECT LOGIC
                            if (selectedRole == "HOP")
                            {
                                Response.Redirect("AdminDashboard.aspx");
                            }
                            else
                            {
                                // Placeholder for other roles if their dashboards aren't ready yet
                                ShowErrorMessage($"Login Successful! Welcome {Session["UserName"]}. Dashboard for {selectedRole} coming soon.", false);
                            }
                        }
                        else
                        {
                            ShowErrorMessage("Invalid email or password.");
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowErrorMessage("Database Error: " + ex.Message);
                    }
                }
            }
        }

        private void ShowErrorMessage(string message, bool isError = true)
        {
            lblMessage.Text = message;
            lblMessage.ForeColor = isError ? System.Drawing.Color.Red : System.Drawing.Color.Green;
            lblMessage.Visible = true;
        }
    }
}