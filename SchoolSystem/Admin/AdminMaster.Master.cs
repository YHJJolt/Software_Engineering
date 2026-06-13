using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace SchoolSystem
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            ScriptManager.GetCurrent(Page)?.RegisterAsyncPostBackControl(btnMarkRead);

            if (!IsPostBack)
            {
                LoadSidebarProfile();
                LoadNotifications();
                HighlightActiveSideBar();
            }
        }

        private void LoadNotifications()
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            DECLARE @AdminId INT;
            SELECT @AdminId = admin_id FROM [Admin (HoP)] WHERE admin_email = @Email;

            DECLARE @LastRead DATETIME;
            SELECT @LastRead = last_read_at FROM AdminNotifRead WHERE admin_id = @AdminId;

            SELECT TOP 10
                'Event Reminder' AS Type,
                N'⏰ [Reminder] ' + event_title + N' is coming up on ' + CONVERT(NVARCHAR, start_date, 106) AS Message,
                CAST('~/Admin/Calendar.aspx' AS NVARCHAR(255)) AS Link,
                CAST(start_date AS DATETIME) AS SortDate,
                CASE WHEN @LastRead IS NULL OR DATEADD(DAY, -3, CAST(start_date AS DATETIME)) > @LastRead THEN 1 ELSE 0 END AS IsUnread,
                'Upcoming' AS TimeAgo
            FROM Calendar
            WHERE start_date >= CAST(GETDATE() AS DATE) AND start_date <= DATEADD(DAY, 3, GETDATE())
            ORDER BY start_date ASC";

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
                    DECLARE @AdminId INT;
                    SELECT @AdminId = admin_id FROM [Admin (HoP)] WHERE admin_email = @Email;

                    MERGE INTO AdminNotifRead AS target
                    USING (SELECT @AdminId AS admin_id) AS source
                        ON target.admin_id = source.admin_id
                    WHEN MATCHED THEN
                        UPDATE SET last_read_at = DATEADD(MINUTE, 1, GETDATE())
                    WHEN NOT MATCHED THEN
                        INSERT (admin_id, last_read_at) VALUES (@AdminId, DATEADD(MINUTE, 1, GETDATE()));";

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

        private void LoadSidebarProfile()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT admin_name, admin_img FROM [Admin (HoP)] WHERE admin_email = @Email";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                conn.Open();
                SqlDataReader rdr = cmd.ExecuteReader();
                if (rdr.Read())
                {
                    litSidebarName.Text = rdr["admin_name"].ToString();
                    if (rdr["admin_img"] != DBNull.Value)
                    {
                        imgSidebar.ImageUrl = "data:image/png;base64," + Convert.ToBase64String((byte[])rdr["admin_img"]);
                    }
                }
            }
        }

        private void HighlightActiveSideBar()
        {
            string currentPage = Request.Url.AbsolutePath.ToLowerInvariant();

            // linkCourseAllocation included so it resets correctly alongside the others
            HtmlAnchor[] links = { linkDashboard, linkPrograms, linkUsers, linkPayment, linkCourses, linkCourseAllocation, linkEnrollment, linkPerformance, linkAnnouncements, linkCalendar };

            foreach (var link in links)
            {
                if (link == null) continue;
                link.Attributes["class"] = link.Attributes["class"].Contains("sub-link")
                    ? "nav-link sub-link"
                    : "nav-link";
            }

            // "courseallocation" MUST be checked before "course" — otherwise "course" swallows it
            if (currentPage.Contains("admindashboard") && linkDashboard != null) linkDashboard.Attributes["class"] += " active";
            else if (currentPage.Contains("program") && linkPrograms != null) linkPrograms.Attributes["class"] += " active";
            else if (currentPage.Contains("usermanagement") && linkUsers != null) linkUsers.Attributes["class"] += " active";
            else if (currentPage.Contains("payments") && linkPayment != null) linkPayment.Attributes["class"] += " active";
            else if (currentPage.Contains("courseallocation") && linkCourseAllocation != null) linkCourseAllocation.Attributes["class"] += " active";
            else if (currentPage.Contains("course") && linkCourses != null) linkCourses.Attributes["class"] += " active";
            else if (currentPage.Contains("enrollment") && linkEnrollment != null) linkEnrollment.Attributes["class"] += " active";
            else if (currentPage.Contains("performance") && linkPerformance != null) linkPerformance.Attributes["class"] += " active";
            else if (currentPage.Contains("announcement") && linkAnnouncements != null) linkAnnouncements.Attributes["class"] += " active";
            else if (currentPage.Contains("calendar") && linkCalendar != null) linkCalendar.Attributes["class"] += " active";
        }
    }
}
