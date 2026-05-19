using System;
using System.Configuration;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class LecturerProfile : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_PreInit(object sender, EventArgs e)
        {
            if (Request.QueryString["course_id"] != null)
            {
                // Updated to point to the renamed Master File
                this.MasterPageFile = "~/LecturerCourseMaster.Master";
            }
            else
            {
                this.MasterPageFile = "~/LecturerMaster.Master";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");

            if (this.Master is LecturerMaster)
                ((LecturerMaster)this.Master).PageTitle = "My Profile";
            // Updated casting
            else if (this.Master is LecturerCourseMaster)
                ((LecturerCourseMaster)this.Master).PageTitle = "My Profile";

            if (!IsPostBack) LoadUserData();
            if (fileUploadImg.HasFile) UploadImage();
        }

        private void LoadUserData()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT lecturer_name, lecturer_email, lecturer_bio, lecturer_img FROM [Lecturer] WHERE lecturer_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litFullName.Text = rdr["lecturer_name"].ToString();
                    litEmail.Text = rdr["lecturer_email"].ToString();
                    txtBio.Text = rdr["lecturer_bio"] != DBNull.Value ? rdr["lecturer_bio"].ToString() : "";

                    if (rdr["lecturer_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["lecturer_img"];
                        imgBigProfile.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(bytes);
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Lecturer] SET lecturer_bio = @Bio WHERE lecturer_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void UploadImage()
        {
            byte[] imgBytes = fileUploadImg.FileBytes;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "UPDATE [Lecturer] SET lecturer_img = @Img WHERE lecturer_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Img", imgBytes);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            string redirectUrl = "LecturerProfile.aspx";
            if (Request.QueryString["course_id"] != null)
            {
                redirectUrl += "?course_id=" + Request.QueryString["course_id"];
            }
            Response.Redirect(redirectUrl);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("RoleSelect.aspx");
        }
    }
}