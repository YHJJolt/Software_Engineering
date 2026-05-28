using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class LecturerCourseMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        public string PageTitle
        {
            get { return litPageTitle.Text; }
            set { litPageTitle.Text = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
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
                        linkHome.HRef = "CourseHome.aspx?id=" + cid;
                        linkPeople.HRef = "CoursePeople.aspx?id=" + cid;
                        linkAttendance.HRef = "ManageAttendance.aspx?id=" + cid;
                        linkGrades.HRef = "LecturerGrades.aspx?id=" + cid;
                        linkModules.HRef = "CourseModules.aspx?id=" + cid;
                        linkAssignments.HRef = "CourseAssignments.aspx?id=" + cid;
                        linkAnnouncements.HRef = "LecturerAnnouncement.aspx?id=" + cid;
                        linkSidebarProfile.HRef = "LecturerProfile.aspx?course_id=" + cid;
                    }
                }
            }
        }

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT lecturer_name, lecturer_img FROM [Lecturer] WHERE lecturer_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litSidebarName.Text = rdr["lecturer_name"].ToString();
                    if (rdr["lecturer_img"] != DBNull.Value)
                    {
                        byte[] bytes = (byte[])rdr["lecturer_img"];
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
                // SQL query updated to ONLY fetch Admin Announcements, 
                // completely removing the "Low Marks" union section.
                string sql = @"
            SELECT 'Admin Announcement' as Type, 
                   N'📢 [Posted by Admin] ' + title as Message,
                   'info' as CssClass
            FROM Announcement
            WHERE admin_id IS NOT NULL";

                SqlCommand cmd = new SqlCommand(sql, conn);

                // If your original code had parameters for other things, they are no longer needed here 
                // since we are only fetching global admin announcements.

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

            if (p.Contains("coursehome")) linkHome.Attributes["class"] += " active";
            if (p.Contains("coursepeople")) linkPeople.Attributes["class"] += " active";
            if (p.Contains("attendance")) linkAttendance.Attributes["class"] += " active";
            if (p.Contains("grade")) linkGrades.Attributes["class"] += " active";
            if (p.Contains("module")) linkModules.Attributes["class"] += " active";
            if (p.Contains("assignment")) linkAssignments.Attributes["class"] += " active";
            if (p.Contains("announcement")) linkAnnouncements.Attributes["class"] += " active";
        }
    }
}
