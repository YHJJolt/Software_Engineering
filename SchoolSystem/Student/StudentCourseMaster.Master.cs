using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class StudentCourseMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        public string PageTitle
        {
            get { return litPageTitle.Text; }
            set { litPageTitle.Text = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // The tilde safely kicks out logged-out users to the root directory
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                LoadNotifications();
                LoadCourseDetails();
                HighlightActiveSideBar();
            }
        }

        private void LoadCourseDetails()
        {
            string cid = Request.QueryString["id"] ?? Request.QueryString["course_id"];

            if (!string.IsNullOrEmpty(cid))
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT course_code, course_name FROM Course WHERE course_id = @CourseID";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@CourseID", cid);
                    conn.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                    if (rdr.Read())
                    {
                        litCourseCode.Text = rdr["course_code"].ToString();

                        // Bulletproof routing using the tilde and new Student folder
                        linkHome.HRef = "~/Student/StudentCourseHome.aspx?id=" + cid;
                        linkPeople.HRef = "~/Student/StudentCoursePeople.aspx?id=" + cid;
                        linkModules.HRef = "~/Student/StudentCourseModules.aspx?id=" + cid;
                        linkAssignments.HRef = "~/Student/StudentCourseAssignments.aspx?id=" + cid;
                        linkGrades.HRef = "~/Student/StudentCourseGrades.aspx?id=" + cid;
                        linkAnnouncements.HRef = "~/Student/StudentCourseAnnouncements.aspx?id=" + cid;

                        // Assigning course_id to the profile button
                        linkSidebarProfile.HRef = "~/Student/StudentProfile.aspx?course_id=" + cid;
                    }
                }
            }
        }

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Querying the Student table instead of Lecturer
                string sql = "SELECT student_name, student_img FROM [Student] WHERE student_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litSidebarName.Text = rdr["student_name"].ToString();
                    if (rdr["student_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["student_img"];
                        imgSidebar.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(bytes);
                    }
                }
            }
        }

        private void LoadNotifications()
        {
            DataTable dtNotifs = new DataTable();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Fetches global Admin Announcements exactly like the Lecturer side
                string sql = @"
            SELECT 'Admin Announcement' as Type, 
                   N'📢 [Posted by Admin] ' + title as Message,
                   'info' as CssClass
            FROM Announcement
            WHERE admin_id IS NOT NULL";

                SqlCommand cmd = new SqlCommand(sql, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtNotifs);

                litNotifCount.Text = dtNotifs.Rows.Count.ToString();
                if (dtNotifs.Rows.Count > 0)
                {
                    noNotifs.Visible = false;
                    rptNotifications.DataSource = dtNotifs;
                    rptNotifications.DataBind();
                }
                else
                {
                    noNotifs.Visible = true;
                }
            }
        }

        private void HighlightActiveSideBar()
        {
            string p = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();

            // Missing the attendance link since students do not manage it
            if (p.Contains("coursehome")) linkHome.Attributes["class"] += " active";
            if (p.Contains("coursepeople")) linkPeople.Attributes["class"] += " active";
            if (p.Contains("module")) linkModules.Attributes["class"] += " active";
            if (p.Contains("assignment")) linkAssignments.Attributes["class"] += " active";
            if (p.Contains("grade")) linkGrades.Attributes["class"] += " active";
            if (p.Contains("announcement")) linkAnnouncements.Attributes["class"] += " active";
        }
    }
}