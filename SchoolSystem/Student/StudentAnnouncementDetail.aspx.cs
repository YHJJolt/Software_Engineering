using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;

namespace SchoolSystem.Student
{
    public partial class StudentAnnouncementDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ((StudentCourseMaster)this.Master).PageTitle = "Announcement Detail";

                string aid = Request.QueryString["id"];
                string courseId = Request.QueryString["course_id"];
                string session = Request.QueryString["session"] ?? "";

                if (string.IsNullOrEmpty(aid) || string.IsNullOrEmpty(courseId))
                {
                    Response.Redirect("~/Student/StudentAnnouncements.aspx");
                    return;
                }

                if (!IsStudentEnrolled(courseId))
                {
                    Response.Redirect("~/Student/StudentAnnouncements.aspx");
                    return;
                }

                LoadAnnouncement(aid, courseId, session);
            }
        }

        private bool IsStudentEnrolled(string courseId)
        {
            try
            {
                int studentId = GetStudentId();
                string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"SELECT COUNT(1) FROM Enrollment
                                   WHERE student_id = @StudentID
                                     AND course_id  = @CourseID
                                     AND status     = 'Approved'";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    conn.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
            catch { return false; }
        }

        private void LoadAnnouncement(string aid, string courseId, string session)
        {
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT a.title, a.content, a.category, a.created_at,
                           ISNULL(l.lecturer_name, 'Admin') AS lecturer_name
                    FROM Announcement a
                    LEFT JOIN Lecturer l ON a.Lecturer_id = l.lecturer_id
                    WHERE a.announcement_id = @id
                      AND a.Course_id       = @CourseID
                      AND (@Session = '' OR a.academic_session = @Session)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", aid);
                cmd.Parameters.AddWithValue("@CourseID", courseId);
                cmd.Parameters.AddWithValue("@Session", session);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    string category = dr["category"].ToString();
                    DateTime dt = Convert.ToDateTime(dr["created_at"]);

                    lblTitle.InnerText = dr["title"].ToString();
                    lblContent.InnerText = dr["content"].ToString();
                    lblLecturerName.Text = dr["lecturer_name"].ToString();
                    lblDate.Text = dt.ToString("dd MMM yyyy");
                    lblTime.Text = dt.ToString("hh:mm tt");

                    string colour;
                    if (category == "Academic") colour = "background:#fce8e6;color:#d93025;";
                    else if (category == "Finance") colour = "background:#e6ffed;color:#1e8e3e;";
                    else if (category == "Co-curriculum") colour = "background:#f3e8fd;color:#9334e6;";
                    else colour = "background:#e8f0fe;color:#1967d2;";

                    lblCategory.Style.Value = colour;
                    lblCategory.InnerText = category;
                }
                else
                {
                    Response.Redirect("~/Student/StudentAnnouncements.aspx");
                }
            }
        }

        private static int GetStudentId()
        {
            string[] possibleKeys = { "StudentID", "StudentId", "student_id", "UserID", "UserId" };
            foreach (var key in possibleKeys)
            {
                var val = HttpContext.Current.Session[key];
                if (val != null) return Convert.ToInt32(val);
            }
            throw new Exception("Student ID not found in session.");
        }
    }
}
