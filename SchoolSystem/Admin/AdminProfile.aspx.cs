using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;

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
                string sql = "SELECT admin_name, admin_email, admin_bio, admin_img FROM [Admin (HoP)] WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litFullName.Text = rdr["admin_name"].ToString();
                    litEmail.Text = rdr["admin_email"].ToString();
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
                string sql = "UPDATE [Admin (HoP)] SET admin_bio = @Bio WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            // Optional: Reload data to confirm save
            LoadUserData();
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