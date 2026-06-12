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