using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;

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
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            // Required to allow the bell click to update the DB asynchronously 
            ScriptManager.GetCurrent(Page)?.RegisterAsyncPostBackControl(btnMarkRead);

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                LoadNotifications();
                LoadCourseDetails();
                HighlightActiveSideBar();
            }

            // Fallback replication for safety trigger
            string eventTarget = Request.Form["__EVENTTARGET"];
            if (eventTarget == "markReadTrigger")
            {
                MarkAllNotificationsRead();
                LoadNotifications();
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

                        linkHome.HRef = "~/Student/StudentCourseHome.aspx?id=" + cid;
                        linkPeople.HRef = "~/Student/StudentCoursePeople.aspx?id=" + cid;
                        linkModules.HRef = "~/Student/StudentCourseModules.aspx?id=" + cid;
                        linkAssignments.HRef = "~/Student/StudentCourseAssignments.aspx?id=" + cid;
                        linkGrades.HRef = "~/Student/StudentIndivGrades.aspx?id=" + cid;
                        linkAnnouncements.HRef = "~/Student/StudentAnnouncements.aspx?id=" + cid;
                        linkSidebarProfile.HRef = "~/Student/StudentProfile.aspx?course_id=" + cid;
                    }
                }
            }
        }

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
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
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Exact logic from StudentMaster to prevent future date bugs
                string sql = @"
            DECLARE @StudentId INT;
            SELECT @StudentId = student_id FROM Student WHERE student_email = @Email;

            DECLARE @LastRead DATETIME;
            SELECT @LastRead = last_read_at FROM StudentNotifRead WHERE student_id = @StudentId;

            WITH AllNotifs AS (
                SELECT 'Admin' as Source, N'📢 [Admin] ' + title as Message, created_at as SortDate, '~/Student/StudentCalendar.aspx' as Link FROM Announcement WHERE Admin_id IS NOT NULL
                UNION ALL
                SELECT 'Lecturer' as Source, N'👨‍🏫 ' + title as Message, created_at as SortDate, '~/Student/StudentAnnouncements.aspx' as Link FROM Announcement WHERE Lecturer_id IS NOT NULL
                UNION ALL
                SELECT 'Grade' as Source, N'✅ Assignment Graded' as Message, graded_date as SortDate, '~/Student/StudentIndivGrades.aspx' as Link FROM AssignmentSubmission WHERE marks_awarded IS NOT NULL AND student_id = @StudentId
                UNION ALL
                SELECT 'Rejected' as Source, N'❌ [Enrolment] Your request for ' + c.course_code + N' - ' + c.course_name + N' was rejected' as Message, ISNULL(e.status_updated_at, e.enrollment_date) as SortDate, '~/Student/StudentEnrollments.aspx' as Link FROM Enrollment e INNER JOIN Course c ON e.course_id = c.course_id WHERE e.student_id = @StudentId AND e.status = 'Rejected'
                UNION ALL
                SELECT 'Reminder' as Source, N'⏰ [Reminder] ' + event_title + N' is coming up on ' + CONVERT(NVARCHAR, start_date, 106) as Message, CAST(start_date AS DATETIME) as SortDate, '~/Student/StudentCalendar.aspx' as Link FROM Calendar WHERE start_date >= CAST(GETDATE() AS DATE) AND start_date <= DATEADD(DAY, 3, GETDATE())
                UNION ALL
                SELECT 'Reminder' as Source, N'⏰ [Reminder] ' + event_title + N' is coming up on ' + CONVERT(NVARCHAR, start_date, 106) as Message, CAST(start_date AS DATETIME) as SortDate, '~/Student/StudentCalendar.aspx' as Link FROM StudentCalendar WHERE student_id = @StudentId AND start_date >= CAST(GETDATE() AS DATE) AND start_date <= DATEADD(DAY, 3, GETDATE())
            )
            SELECT TOP 10 *,
                CASE
                    WHEN Source = 'Reminder' THEN CASE WHEN @LastRead IS NULL OR DATEADD(DAY, -3, SortDate) > @LastRead THEN 1 ELSE 0 END
                    WHEN @LastRead IS NULL THEN 1
                    WHEN SortDate > @LastRead THEN 1
                    ELSE 0
                END AS IsUnread,
                CASE
                    WHEN Source = 'Reminder' THEN 'Upcoming'
                    WHEN SortDate > GETDATE() THEN 'Upcoming'
                    WHEN DATEDIFF(MINUTE, SortDate, GETDATE()) < 60 THEN CAST(DATEDIFF(MINUTE, SortDate, GETDATE()) AS VARCHAR) + 'm ago'
                    WHEN DATEDIFF(HOUR, SortDate, GETDATE()) < 24 THEN CAST(DATEDIFF(HOUR, SortDate, GETDATE()) AS VARCHAR) + 'h ago'
                    ELSE CAST(DATEDIFF(DAY, SortDate, GETDATE()) AS VARCHAR) + 'd ago'
                END AS TimeAgo
            FROM AllNotifs 
            ORDER BY SortDate DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                int unreadCount = dt.AsEnumerable().Count(r => r.Field<int>("IsUnread") == 1);
                litNotifCount.Text = (unreadCount > 0) ? $"<span class=\"notif-badge\">{unreadCount}</span>" : "";

                rptNotifications.DataSource = dt;
                rptNotifications.DataBind();
                noNotifs.Visible = (dt.Rows.Count == 0);
            }
        }

        private void MarkAllNotificationsRead()
        {
            if (Session["UserEmail"] == null) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    DECLARE @StudentId INT;
                    SELECT @StudentId = student_id FROM Student WHERE student_email = @Email;

                    MERGE INTO StudentNotifRead AS target
                    USING (SELECT @StudentId AS student_id) AS source
                        ON target.student_id = source.student_id
                    WHEN MATCHED THEN
                        UPDATE SET last_read_at = DATEADD(MINUTE, 1, GETDATE())
                    WHEN NOT MATCHED THEN
                        INSERT (student_id, last_read_at) VALUES (@StudentId, DATEADD(MINUTE, 1, GETDATE()));";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        protected void btnMarkRead_Click(object sender, EventArgs e)
        {
            MarkAllNotificationsRead();
            LoadNotifications();
        }

        private void HighlightActiveSideBar()
        {
            string p = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
            if (p.Contains("coursehome")) linkHome.Attributes["class"] += " active";
            if (p.Contains("coursepeople")) linkPeople.Attributes["class"] += " active";
            if (p.Contains("module")) linkModules.Attributes["class"] += " active";
            if (p.Contains("assignment")) linkAssignments.Attributes["class"] += " active";
            if (p.Contains("grade")) linkGrades.Attributes["class"] += " active";
            if (p.Contains("announcement")) linkAnnouncements.Attributes["class"] += " active";
        }
    }
}