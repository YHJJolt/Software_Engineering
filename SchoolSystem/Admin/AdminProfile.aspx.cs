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

        // Validates that the uploaded file is genuinely an image by checking BOTH
        // the file extension and the actual file-signature ("magic") bytes.
        private bool IsValidImage(System.Web.HttpPostedFile file, out string error)
        {
            error = null;

            if (file.ContentLength <= 0)
            {
                error = "The selected file is empty.";
                return false;
            }
            if (file.ContentLength > 5 * 1024 * 1024)
            {
                error = "Image must be 5 MB or smaller.";
                return false;
            }

            string ext = System.IO.Path.GetExtension(file.FileName)?.ToLowerInvariant() ?? "";
            string[] allowedExt = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };
            if (System.Array.IndexOf(allowedExt, ext) < 0)
            {
                error = "Only image files (JPG, PNG, GIF, BMP, WEBP) are allowed.";
                return false;
            }

            byte[] header = new byte[12];
            int read = file.InputStream.Read(header, 0, header.Length);
            file.InputStream.Position = 0;
            if (read < 4 || !HasImageSignature(header))
            {
                error = "That file is not a valid image.";
                return false;
            }

            return true;
        }

        private bool HasImageSignature(byte[] h)
        {
            if (h[0] == 0xFF && h[1] == 0xD8 && h[2] == 0xFF) return true;                       // JPEG
            if (h[0] == 0x89 && h[1] == 0x50 && h[2] == 0x4E && h[3] == 0x47) return true;       // PNG
            if (h[0] == 0x47 && h[1] == 0x49 && h[2] == 0x46 && h[3] == 0x38) return true;       // GIF
            if (h[0] == 0x42 && h[1] == 0x4D) return true;                                        // BMP
            if (h[0] == 0x52 && h[1] == 0x49 && h[2] == 0x46 && h[3] == 0x46 &&
                h.Length >= 12 && h[8] == 0x57 && h[9] == 0x45 && h[10] == 0x42 && h[11] == 0x50) return true; // WEBP
            return false;
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
            string error;
            if (!IsValidImage(fileUploadImg.PostedFile, out error))
            {
                ShowAlert(error);
                return;
            }

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