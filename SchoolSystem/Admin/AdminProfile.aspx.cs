using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace SchoolSystem
{
    // UPDATED CLASS NAME HERE
    public partial class AdminProfile : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
            {
                LoadUserData();
            }

            // Handle Image Upload immediately when file is selected
            if (fileUploadImg.HasFile)
            {
                UploadImage();
            }
        }

        private void LoadUserData()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Matches the project schema using [Admin (HoP)]
                string sql = "SELECT admin_name, admin_email, admin_contact, admin_bio, admin_img FROM [Admin (HoP)] WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litFullName.Text = rdr["admin_name"].ToString();
                    litEmail.Text = rdr["admin_email"].ToString();
                    txtContact.Text = rdr["admin_contact"] != DBNull.Value ? rdr["admin_contact"].ToString() : "";
                    txtBio.Text = rdr["admin_bio"].ToString();

                    if (rdr["admin_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["admin_img"];
                        string base64 = Convert.ToBase64String(bytes);
                        imgBigProfile.ImageUrl = "data:image/png;base64," + base64;
                    }
                }
            }
        }

        protected void btnSaveBio_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Admin (HoP)] SET admin_bio = @Bio, admin_contact = @Contact WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text);
                cmd.Parameters.AddWithValue("@Contact", txtContact.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            // Optional: Reload data to confirm save
            LoadUserData();
            ScriptManager.RegisterStartupScript(this, GetType(), "showalert", "alert('Profile saved successfully!');", true);
        }

        protected void btnChangePw_Click(object sender, EventArgs e)
        {
            string currentPw = txtCurrentPw.Text;
            string newPw = txtNewPw.Text;
            string confirmPw = txtConfirmPw.Text;

            if (string.IsNullOrWhiteSpace(currentPw) || string.IsNullOrWhiteSpace(newPw) || string.IsNullOrWhiteSpace(confirmPw))
            {
                ShowAlert("Please fill in all password fields.");
                return;
            }
            if (newPw != confirmPw)
            {
                ShowAlert("New password and confirmation do not match.");
                return;
            }
            if (newPw.Length < 6)
            {
                ShowAlert("New password must be at least 6 characters long.");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string sql = "SELECT admin_pw FROM [Admin (HoP)] WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                object result = cmd.ExecuteScalar();
                if (result == null)
                {
                    ShowAlert("Account not found.");
                    return;
                }

                // Stored password may still be plaintext (pre-migration) or already SHA256 hashed
                string storedPw = result.ToString();
                if (storedPw != currentPw && storedPw != HashPassword(currentPw))
                {
                    ShowAlert("Current password is incorrect.");
                    return;
                }

                string updateSql = "UPDATE [Admin (HoP)] SET admin_pw = @NewPw WHERE admin_email = @Email";
                SqlCommand updateCmd = new SqlCommand(updateSql, conn);
                updateCmd.Parameters.AddWithValue("@NewPw", HashPassword(newPw));
                updateCmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                updateCmd.ExecuteNonQuery();
            }

            ShowAlert("Password changed successfully!");
        }

        private void ShowAlert(string message)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "pwalert", "alert('" + message.Replace("'", "\\'") + "');", true);
        }

        // Same SHA256 hashing as Login.aspx.cs so the new password works at login
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

        private void UploadImage()
        {
            byte[] imgBytes = fileUploadImg.FileBytes;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Admin (HoP)] SET admin_img = @Img WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Img", imgBytes);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            // UPDATED REDIRECT HERE
            Response.Redirect("~/Admin/AdminProfile.aspx");
        }

        // NEW: Handles the Log Out action from the profile page
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/RoleSelect.aspx");
        }
    }
}