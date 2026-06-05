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
                        linkGrades.HRef = "~/Student/StudentIndivGrades.aspx?id=" + cid;
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
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            -- 1. Identify the logged-in student
            DECLARE @StudentId INT;
            SELECT @StudentId = student_id FROM Student WHERE student_email = @Email;

            -- 2. Pull the top 10 most recent notifications across all categories
            SELECT TOP 10 Type, Message, CssClass
            FROM (
                
                -- ==========================================
                -- CATEGORY 1: Admin Announcements
                -- ==========================================
                SELECT 
                    'Admin Announcement' AS Type, 
                    N'📢 [Admin] ' + title AS Message,
                    'info' AS CssClass,
                    created_at AS SortDate
                FROM Announcement
                WHERE Admin_id IS NOT NULL

                UNION ALL

                -- ==========================================
                -- CATEGORY 2: Lecturer Announcements
                -- ==========================================
                SELECT 
                    'Lecturer Update' AS Type, 
                    N'👨‍🏫 ' + a.title AS Message,
                    'info' AS CssClass,
                    a.created_at AS SortDate
                FROM Announcement a
                WHERE a.Lecturer_id IS NOT NULL 
                  AND (
                      -- Matches if the announcement is tied to a specific course the student is taking
                      EXISTS (
                          SELECT 1 FROM Enrollment e 
                          WHERE e.course_id = a.Course_id 
                            AND e.student_id = @StudentId 
                            AND e.status = 'Approved'
                      )
                      OR 
                      -- Matches if there is NO course_id, but the student takes ANY course from this lecturer
                      (a.Course_id IS NULL AND EXISTS (
                          SELECT 1 FROM Enrollment e
                          INNER JOIN Course c ON e.course_id = c.course_id
                          WHERE c.Lecturer_id = a.Lecturer_id 
                            AND e.student_id = @StudentId 
                            AND e.status = 'Approved'
                      ))
                  )

                UNION ALL

                -- ==========================================
                -- CATEGORY 3: Graded Assignments
                -- ==========================================
                SELECT 
                    'Assignment Graded' AS Type, 
                    N'✅ ""' + ca.title + '"" graded: ' + 
                    CAST(CAST(sub.marks_awarded AS FLOAT) AS VARCHAR) + '/' + CAST(ca.max_marks AS VARCHAR) AS Message,
                    'alert' AS CssClass,
                    COALESCE(sub.graded_date, GETDATE()) AS SortDate
                FROM AssignmentSubmission sub
                INNER JOIN CourseAssignment ca ON sub.assignment_id = ca.assignment_id
                WHERE sub.student_id = @StudentId 
                  AND sub.marks_awarded IS NOT NULL

            ) AS CombinedNotifs
            ORDER BY SortDate DESC;";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dtNotifs = new DataTable();
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