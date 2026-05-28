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
                Response.Redirect("~/RoleSelect.aspx");
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

            // Mapping based on your Database Schema
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
                    passColumn = "lecturer_pw";
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

                            //  FIX: Dynamic extraction of Database IDs for each role
                            if (selectedRole == "HOP")
                            {
                                Session["AdminID"] = Convert.ToInt32(reader["admin_id"]);
                                Response.Redirect("~/Admin/AdminDashboard.aspx");
                            }
                            else if (selectedRole == "Lecturer")
                            {
                                // This key will match what LecturerCalender.aspx.cs expects!
                                Session["LecturerID"] = Convert.ToInt32(reader["lecturer_id"]);
                                Response.Redirect("~/Lecturer/LecturerDashboard.aspx");
                            }
                            else if (selectedRole == "Student")
                            {
                                Session["StudentID"] = Convert.ToInt32(reader["student_id"]);
                                // Keep your fallback or update when student dashboard is ready
                                ShowErrorMessage($"Login Successful! Welcome {Session["UserName"]}. {selectedRole} Dashboard is under maintenance.", false);
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
            // Use Antique Gold for success/info messages, standard Red for errors
            lblMessage.ForeColor = isError ? System.Drawing.Color.FromArgb(231, 76, 60) : System.Drawing.Color.FromArgb(197, 160, 89);
            lblMessage.Visible = true;
        }
    }
}