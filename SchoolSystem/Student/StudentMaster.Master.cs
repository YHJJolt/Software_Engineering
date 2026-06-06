using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;

namespace SchoolSystem
{
    public partial class StudentMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        public string PageTitle
        {
            get { return Page.Title; }
            set { Page.Title = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            // Explicitly map the button as an Async trigger
            ScriptManager.GetCurrent(Page)?.RegisterAsyncPostBackControl(btnMarkRead);

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                LoadNotifications();
                HighlightActiveSideBar();
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
                        string base64String = Convert.ToBase64String(bytes);
                        imgSidebar.ImageUrl = "data:image/png;base64," + base64String;
                    }
                }
            }
        }

        private void LoadNotifications()
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            DECLARE @StudentId INT;
            SELECT @StudentId = student_id FROM Student WHERE student_email = @Email;

            DECLARE @LastRead DATETIME;
            SELECT @LastRead = last_read_at FROM StudentNotifRead WHERE student_id = @StudentId;

            WITH AllNotifs AS (
                SELECT 'Admin Announcement' AS Type, N'📢 [Admin] ' + title AS Message, 'info' AS CssClass, CAST('~/Student/StudentCalendar.aspx' AS NVARCHAR(255)) AS Link, created_at AS SortDate FROM Announcement WHERE Admin_id IS NOT NULL
                UNION ALL
                SELECT 'Lecturer Update' AS Type, N'👨‍🏫 ' + a.title AS Message, 'info' AS CssClass, CAST(CASE WHEN a.Course_id IS NOT NULL THEN '~/Student/StudentAnnouncementDetail.aspx?id=' + CAST(a.announcement_id AS VARCHAR) + '&course_id=' + CAST(a.Course_id AS VARCHAR) ELSE '~/Student/StudentAnnouncements.aspx' END AS NVARCHAR(255)) AS Link, a.created_at AS SortDate FROM Announcement a WHERE a.Lecturer_id IS NOT NULL AND (EXISTS (SELECT 1 FROM Enrollment e WHERE e.course_id = a.Course_id AND e.student_id = @StudentId AND e.status = 'Approved') OR (a.Course_id IS NULL AND EXISTS (SELECT 1 FROM Enrollment e INNER JOIN Course c ON e.course_id = c.course_id WHERE c.Lecturer_id = a.Lecturer_id AND e.student_id = @StudentId AND e.status = 'Approved')))
                UNION ALL
                SELECT 'Assignment Graded' AS Type, N'✅ ' + CHAR(39) + ca.title + CHAR(39) + N' graded: ' + CAST(CAST(sub.marks_awarded AS FLOAT) AS NVARCHAR(20)) + N'/' + CAST(ca.max_marks AS NVARCHAR(20)) AS Message, 'alert' AS CssClass, CAST('~/Student/StudentIndivGrades.aspx?id=' + CAST(ca.Course_id AS VARCHAR(10)) AS NVARCHAR(255)) AS Link, COALESCE(sub.graded_date, GETDATE()) AS SortDate FROM AssignmentSubmission sub INNER JOIN CourseAssignment ca ON sub.assignment_id = ca.assignment_id WHERE sub.student_id = @StudentId AND sub.marks_awarded IS NOT NULL
                UNION ALL
                SELECT 'New Event' AS Type, N'📅 [New Event] ' + event_title + N' on ' + CONVERT(NVARCHAR, start_date, 106) AS Message, 'info' AS CssClass, CAST('~/Student/StudentCalendar.aspx' AS NVARCHAR(255)) AS Link, CAST(start_date AS DATETIME) AS SortDate FROM Calendar WHERE start_date >= DATEADD(DAY, -30, GETDATE())
            )
            SELECT TOP 10 *, 
                CASE 
                    WHEN Type = 'New Event' THEN 0 
                    WHEN @LastRead IS NULL THEN 1 
                    WHEN SortDate > @LastRead THEN 1 
                    ELSE 0 
                END AS IsUnread,
                CASE
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
                // Date buffer prevents milliseconds bug
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
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
            if (currentPage.Contains("dashboard")) linkDashboard.Attributes["class"] += " active";
            else if (currentPage.Contains("course") && !currentPage.Contains("enrolment")) linkCourses.Attributes["class"] += " active";
            else if (currentPage.Contains("attendance")) linkAttendance.Attributes["class"] += " active";
            else if (currentPage.Contains("grade")) linkGrades.Attributes["class"] += " active";
            else if (currentPage.Contains("calendar")) linkCalendar.Attributes["class"] += " active";
            else if (currentPage.Contains("enrolment")) linkEnrollment.Attributes["class"] += " active";
            else if (currentPage.Contains("payment")) linkPayment.Attributes["class"] += " active";
        }
    }
}