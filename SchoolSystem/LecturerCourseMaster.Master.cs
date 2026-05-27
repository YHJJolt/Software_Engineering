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
            if (Session["UserEmail"] == null) Response.Redirect("Login.aspx");

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
                        linkAttendance.HRef = "ManageAttendance.aspx?id=" + cid;
                        linkAnnouncements.HRef = "LecturerAnnouncement.aspx?id=" + cid; // ✅ ADD THIS
                        linkGrades.HRef = "LecturerGrades.aspx?id=" + cid;
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
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                DataTable dtNotifs = new DataTable();

                string sql = @"
            -- 1. Failing Student Alerts
            SELECT 'Failing Student' as Type, 
                   s.student_name + ' is failing ' + c.course_name + ' (Grade: ' + cg.letter_grade + ')' as Message, 
                   'alert' as CssClass
            FROM Enrollment e
            JOIN Student s ON e.student_id = s.student_id
            JOIN Course c ON e.course_id = c.course_id
            JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
            JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
            WHERE l.lecturer_email = @Email AND cg.letter_grade = 'F'
            
            UNION ALL
            
            -- 2. Admin Announcements
            SELECT 'Admin Announcement' as Type, 
                   N'📢 [Posted by Admin] ' + title as Message,  -- CHANGE 'title' to your actual column name if it is different
                   'info' as CssClass
            FROM Announcement
            WHERE admin_id IS NOT NULL"; 
        
        SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

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
            // Get the current page name in lowercase to make matching easier
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();

            // Check the URL and highlight the matching sidebar link
            if (currentPage.Contains("attendance"))
            {
                linkAttendance.Attributes["class"] += " active";
            }
            else if (currentPage.Contains("module"))
            {
                linkModules.Attributes["class"] += " active";
            }
            else if (currentPage.Contains("assignment"))
            {
                linkAssignments.Attributes["class"] += " active";
            }
            else if (currentPage.Contains("grade"))
            {
                linkGrades.Attributes["class"] += " active";
            }
            else if (currentPage.Contains("announcement"))
            {
                linkAnnouncements.Attributes["class"] += " active";
            }
        }
    }
}