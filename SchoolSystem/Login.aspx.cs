using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

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
            string idColumn = "";

            switch (selectedRole)
            {
                case "HOP":
                    tableName = "[Admin (HoP)]";
                    emailColumn = "admin_email";
                    passColumn = "admin_pw";
                    nameColumn = "admin_name";
                    idColumn = "admin_id";
                    break;
                case "Lecturer":
                    tableName = "[Lecturer]";
                    emailColumn = "lecturer_email";
                    passColumn = "lecturer_pw";
                    nameColumn = "lecturer_name";
                    idColumn = "lecturer_id";
                    break;
                case "Student":
                    tableName = "[Student]";
                    emailColumn = "student_email";
                    passColumn = "student_pw";
                    nameColumn = "student_name";
                    idColumn = "student_id";
                    break;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Fetch the user by email only first
                string fetchSql = $"SELECT * FROM {tableName} WHERE {emailColumn} = @Email";
                using (SqlCommand cmd = new SqlCommand(fetchSql, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", inputEmail);
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (!reader.Read())
                    {
                        ShowErrorMessage("Invalid email or password.");
                        return;
                    }

                    string storedPassword = reader[passColumn].ToString();
                    int userId = Convert.ToInt32(reader[idColumn]);
                    string userName = reader[nameColumn].ToString();
                    reader.Close();

                    string hashedInput = HashPassword(inputPassword);
                    bool isPlainText = (storedPassword == inputPassword);   // still unhashed
                    bool isHashed = (storedPassword == hashedInput);     // already hashed

                    if (!isPlainText && !isHashed)
                    {
                        // Wrong password
                        ShowErrorMessage("Invalid email or password.");
                        return;
                    }

                    // If plain text matched — auto-migrate to hash now
                    if (isPlainText)
                    {
                        string updateSql = $"UPDATE {tableName} SET {passColumn} = @Hash WHERE {idColumn} = @Id";
                        using (SqlCommand updateCmd = new SqlCommand(updateSql, conn))
                        {
                            updateCmd.Parameters.AddWithValue("@Hash", hashedInput);
                            updateCmd.Parameters.AddWithValue("@Id", userId);
                            updateCmd.ExecuteNonQuery();
                        }
                    }

                    // Login success
                    Session["UserEmail"] = inputEmail;
                    Session["UserName"] = userName;
                    Session["UserRole"] = selectedRole;

                    if (selectedRole == "HOP")
                    {
                        Session["AdminID"] = userId;
                        Response.Redirect("~/Admin/AdminDashboard.aspx");
                    }
                    else if (selectedRole == "Lecturer")
                    {
                        Session["LecturerID"] = userId;
                        Response.Redirect("~/Lecturer/LecturerDashboard.aspx");
                    }
                    else if (selectedRole == "Student")
                    {
                        Session["StudentID"] = userId;
                        Response.Redirect("~/Student/StudentDashboard.aspx");
                    }
                }
            }
        }
        // Hashing password using SHA256
        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("X2"));
                return sb.ToString();
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