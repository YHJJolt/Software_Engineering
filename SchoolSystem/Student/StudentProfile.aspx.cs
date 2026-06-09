using System;
using System.Configuration;
using System.Data.SqlClient;
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
                string sql = "SELECT student_name, student_email, student_bio, student_img FROM [Student] WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litFullName.Text = rdr["student_name"].ToString();
                    litEmail.Text = rdr["student_email"].ToString();
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
                string sql = "UPDATE [Student] SET student_bio = @Bio WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Bio", txtBio.Text);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "showalert", "alert('Biography saved successfully!');", true);
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