using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace SchoolSystem
{
    public partial class StudentProfile : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        // Must be done in PreInit — it is the only event early enough to swap the MasterPage.
        // If course_id is in the querystring the student arrived from inside a course sidebar,
        // so we keep them inside StudentCourseMaster instead of dropping them back to StudentMaster.
        protected void Page_PreInit(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(Request.QueryString["course_id"]))
            {
                MasterPageFile = "~/Student/StudentCourseMaster.Master";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            // Set the page title on whichever master is active
            if (Master is StudentCourseMaster courseMaster)
                courseMaster.PageTitle = "My Profile";
            else if (Master is StudentMaster)
                Page.Title = "My Profile";

            if (!IsPostBack)
            {
                LoadUserData();
            }

            if (fileUploadImg.HasFile)
            {
                UploadImage();
            }
        }

        // Validates that the uploaded file is genuinely an image by checking BOTH
        // the file extension and the actual file-signature ("magic") bytes.
        // A non-image (or a non-image renamed with an image extension) returns false,
        // so it can never be written into the image column.
        private bool IsValidImage(System.Web.HttpPostedFile file, out string error)
        {
            error = null;

            // 1. Size guard (reject empty and oversized files; 5 MB cap here)
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

            // 2. Extension allow-list
            string ext = System.IO.Path.GetExtension(file.FileName)?.ToLowerInvariant() ?? "";
            string[] allowedExt = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };
            if (System.Array.IndexOf(allowedExt, ext) < 0)
            {
                error = "Only image files (JPG, PNG, GIF, BMP, WEBP) are allowed.";
                return false;
            }

            // 3. Magic-byte check on the real content, so a renamed file is still caught
            byte[] header = new byte[12];
            int read = file.InputStream.Read(header, 0, header.Length);
            file.InputStream.Position = 0; // rewind so the later save reads the whole file
            if (read < 4 || !HasImageSignature(header))
            {
                error = "That file is not a valid image.";
                return false;
            }

            return true;
        }

        private bool HasImageSignature(byte[] h)
        {
            // JPEG: FF D8 FF
            if (h[0] == 0xFF && h[1] == 0xD8 && h[2] == 0xFF) return true;
            // PNG: 89 50 4E 47 0D 0A 1A 0A
            if (h[0] == 0x89 && h[1] == 0x50 && h[2] == 0x4E && h[3] == 0x47) return true;
            // GIF: "GIF8"
            if (h[0] == 0x47 && h[1] == 0x49 && h[2] == 0x46 && h[3] == 0x38) return true;
            // BMP: "BM"
            if (h[0] == 0x42 && h[1] == 0x4D) return true;
            // WEBP: "RIFF"...."WEBP"
            if (h[0] == 0x52 && h[1] == 0x49 && h[2] == 0x46 && h[3] == 0x46 &&
                h.Length >= 12 && h[8] == 0x57 && h[9] == 0x45 && h[10] == 0x42 && h[11] == 0x50) return true;
            return false;
        }

        private void LoadUserData()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT student_name, student_email, student_contact, student_bio, student_img FROM [Student] WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litFullName.Text = rdr["student_name"].ToString();
                    litEmail.Text = rdr["student_email"].ToString();
                    txtContact.Text = rdr["student_contact"] != DBNull.Value ? rdr["student_contact"].ToString() : "";
                    txtBio.Text = rdr["student_bio"] != DBNull.Value ? rdr["student_bio"].ToString() : "";

                    if (rdr["student_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["student_img"];
                        string base64String = Convert.ToBase64String(bytes);
                        imgBigProfile.ImageUrl = "data:image/png;base64," + base64String;
                    }
                }
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Student] SET student_bio = @Bio, student_contact = @Contact WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text);
                cmd.Parameters.AddWithValue("@Contact", txtContact.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

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

                string sql = "SELECT student_pw FROM [Student] WHERE student_email = @Email";
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

                string updateSql = "UPDATE [Student] SET student_pw = @NewPw WHERE student_email = @Email";
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
            // Reject anything that is not a genuine image. On failure we show an
            // alert and return WITHOUT touching the database at all — no other
            // column (especially student_pw) is ever affected by a bad upload.
            string error;
            if (!IsValidImage(fileUploadImg.PostedFile, out error))
            {
                ShowAlert(error);
                return;
            }

            byte[] imgBytes = fileUploadImg.FileBytes;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Student] SET student_img = @Img WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Img", imgBytes);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            // Preserve course_id on redirect so the master stays correct after image upload
            string courseId = Request.QueryString["course_id"];
            string redirectUrl = "~/Student/StudentProfile.aspx";
            if (!string.IsNullOrEmpty(courseId))
                redirectUrl += "?course_id=" + courseId;

            Response.Redirect(redirectUrl);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/RoleSelect.aspx");
        }
    }
}