using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;

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

            // Required to allow the bell click to update the DB asynchronously
            ScriptManager.GetCurrent(Page)?.RegisterAsyncPostBackControl(btnMarkRead);

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
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // Lecturers see Admin Announcements and Calendar Events only.
                // Tracks unread state via LecturerNotifRead table (same pattern as StudentNotifRead).
                string sql = @"
            DECLARE @LecturerId INT;
            SELECT @LecturerId = lecturer_id FROM Lecturer WHERE lecturer_email = @Email;

            DECLARE @LastRead DATETIME;
            SELECT @LastRead = last_read_at FROM LecturerNotifRead WHERE lecturer_id = @LecturerId;

            WITH AllNotifs AS (
                SELECT 'Admin Announcement' AS Type,
                       N'📢 [Admin] ' + title AS Message,
                       CAST('~/Lecturer/LecturerCalendar.aspx' AS NVARCHAR(255)) AS Link,
                       created_at AS SortDate
                FROM Announcement
                WHERE admin_id IS NOT NULL

                UNION ALL

                SELECT 'New Event' AS Type,
                       N'📅 [New Event] ' + event_title + N' on ' + CONVERT(NVARCHAR, start_date, 106) AS Message,
                       CAST('~/Lecturer/LecturerCalendar.aspx' AS NVARCHAR(255)) AS Link,
                       CAST(start_date AS DATETIME) AS SortDate
                FROM Calendar
                WHERE start_date >= DATEADD(DAY, -30, GETDATE())

                UNION ALL

                SELECT 'New Event' AS Type,
                       N'📅 [My Event] ' + event_title + N' on ' + CONVERT(NVARCHAR, start_date, 106) AS Message,
                       CAST('~/Lecturer/LecturerCalendar.aspx' AS NVARCHAR(255)) AS Link,
                       CAST(start_date AS DATETIME) AS SortDate
                FROM LecturerCalendar
                WHERE lecturer_id = @LecturerId AND start_date >= DATEADD(DAY, -30, GETDATE())

                UNION ALL

                SELECT 'Event Reminder' AS Type,
                       N'⏰ [Reminder] ' + event_title + N' is coming up on ' + CONVERT(NVARCHAR, start_date, 106) AS Message,
                       CAST('~/Lecturer/LecturerCalendar.aspx' AS NVARCHAR(255)) AS Link,
                       CAST(start_date AS DATETIME) AS SortDate
                FROM Calendar
                WHERE start_date >= CAST(GETDATE() AS DATE) AND start_date <= DATEADD(DAY, 3, GETDATE())

                UNION ALL

                SELECT 'Event Reminder' AS Type,
                       N'⏰ [Reminder] ' + event_title + N' is coming up on ' + CONVERT(NVARCHAR, start_date, 106) AS Message,
                       CAST('~/Lecturer/LecturerCalendar.aspx' AS NVARCHAR(255)) AS Link,
                       CAST(start_date AS DATETIME) AS SortDate
                FROM LecturerCalendar
                WHERE lecturer_id = @LecturerId AND start_date >= CAST(GETDATE() AS DATE) AND start_date <= DATEADD(DAY, 3, GETDATE())
            )
            SELECT TOP 10 *,
                CASE
                    WHEN Type = 'Event Reminder' THEN CASE WHEN @LastRead IS NULL OR DATEADD(DAY, -3, SortDate) > @LastRead THEN 1 ELSE 0 END
                    WHEN Type = 'New Event' THEN 0
                    WHEN @LastRead IS NULL THEN 1
                    WHEN SortDate > @LastRead THEN 1
                    ELSE 0
                END AS IsUnread,
                CASE
                    WHEN Type = 'Event Reminder' THEN 'Upcoming'
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
                // Date buffer prevents milliseconds bug (same pattern as StudentMaster)
                string sql = @"
                    DECLARE @LecturerId INT;
                    SELECT @LecturerId = lecturer_id FROM Lecturer WHERE lecturer_email = @Email;

                    MERGE INTO LecturerNotifRead AS target
                    USING (SELECT @LecturerId AS lecturer_id) AS source
                        ON target.lecturer_id = source.lecturer_id
                    WHEN MATCHED THEN
                        UPDATE SET last_read_at = DATEADD(MINUTE, 1, GETDATE())
                    WHEN NOT MATCHED THEN
                        INSERT (lecturer_id, last_read_at) VALUES (@LecturerId, DATEADD(MINUTE, 1, GETDATE()));";

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
            if (p.Contains("attendance")) linkAttendance.Attributes["class"] += " active";
            if (p.Contains("grade")) linkGrades.Attributes["class"] += " active";
            if (p.Contains("module")) linkModules.Attributes["class"] += " active";
            if (p.Contains("assignment")) linkAssignments.Attributes["class"] += " active";
            if (p.Contains("announcement")) linkAnnouncements.Attributes["class"] += " active";
        }
    }
}