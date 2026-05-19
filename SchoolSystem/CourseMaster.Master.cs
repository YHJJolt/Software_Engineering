using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class CourseMaster : System.Web.UI.MasterPage
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
            if (Request.QueryString["id"] != null)
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT course_code, course_name FROM Course WHERE course_id = @CourseID";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@CourseID", Request.QueryString["id"]);
                    conn.Open();
                    SqlDataReader rdr = cmd.ExecuteReader();
                    if (rdr.Read())
                    {
                        litCourseCode.Text = rdr["course_code"].ToString();
                        // Optional: Append course ID to all side links so they stay in this course
                        string cid = Request.QueryString["id"];
                        linkAttendance.HRef = "ManageAttendance.aspx?id=" + cid;
                        // Example for others when ready: linkGrades.HRef = "Grades.aspx?id=" + cid;
                    }
                }
            }
        }

        // Identical backend functions to LecturerMaster
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
            dtNotifs.Columns.Add("Type");
            dtNotifs.Columns.Add("Message");
            dtNotifs.Columns.Add("CssClass");

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT 'Announcement' as Type, title + ' - ' + content as Message, 'announcement' as CssClass 
                    FROM Announcement 
                    UNION ALL 
                    SELECT 'Alert' as Type, 
                           s.student_name + ' is failing ' + c.course_name + ' (Grade: ' + cg.letter_grade + ')' as Message, 
                           'alert' as CssClass
                    FROM Enrollment e
                    JOIN Student s ON e.student_id = s.student_id
                    JOIN Course c ON e.course_id = c.course_id
                    JOIN LecturerEnrollment le ON c.course_id = le.course_id
                    JOIN Lecturer l ON le.lecturer_id = l.lecturer_id
                    JOIN CourseGrade cg ON e.Enrollment_id = cg.Enrollment_id
                    WHERE l.lecturer_email = @Email AND cg.letter_grade = 'F'";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Email", Session["UserEmail"].ToString());
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dtNotifs);
            }

            litNotifCount.Text = dtNotifs.Rows.Count.ToString();
            if (dtNotifs.Rows.Count > 0)
            {
                rptNotifications.DataSource = dtNotifs;
                rptNotifications.DataBind();
            }
            else noNotifs.Visible = true;
        }

        private void HighlightActiveSideBar()
        {
            string currentPage = System.IO.Path.GetFileName(Request.Url.AbsolutePath).ToLower();
            if (currentPage.Contains("attendance")) linkAttendance.Attributes["class"] += " active";
        }
    }
}