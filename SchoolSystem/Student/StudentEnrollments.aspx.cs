using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentEnrollment : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int currentStudentId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");
            currentStudentId = GetStudentId();

            if (!IsPostBack)
            {
                // Check if they are graduated FIRST
                if (CheckIfGraduated())
                {
                    // Lock the screen
                    pnlActiveStudent.Visible = false;
                    pnlGraduated.Visible = true;
                }
                else
                {
                    // Normal active student, load the courses
                    LoadCurrentSemester(); // <-- ADDED HERE
                    LoadMyStatus();
                    LoadAvailableCourses();
                    LoadPendingQueue();
                }
            }
        }

        private void LoadMyStatus()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT c.course_code, c.course_name, e.status, e.enrolled_semester 
                    FROM Enrollment e
                    JOIN Course c ON e.course_id = c.course_id
                    WHERE e.student_id = @sid
                    ORDER BY e.enrolled_semester DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvMyStatus.DataSource = dt;
                    gvMyStatus.DataBind();
                }
            }
        }

        private void LoadAvailableCourses()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Gets courses from the student's program that they HAVEN'T enrolled in yet
                string sql = @"
                    SELECT c.course_id, c.course_code, c.course_name, ISNULL(c.course_fee, 0) as course_fee
                    FROM Course c
                    JOIN Student s ON c.program_id = s.program_id
                    WHERE s.student_id = @sid
                    AND c.course_id NOT IN (
                        SELECT course_id FROM Enrollment WHERE student_id = @sid
                    )";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptAvailableCourses.DataSource = dt;
                    rptAvailableCourses.DataBind();

                    // ADD THIS LINE: Show or hide the empty state message
                    divNoAvailable.Visible = (dt.Rows.Count == 0);
                }
            }
        }

        private void LoadCurrentSemester()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT student_sem FROM Student WHERE student_id = @sid", con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        litCurrentSem.Text = result.ToString();
                    }
                }
            }
        }

        protected void rptAvailableCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Enroll")
            {
                int courseId = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // Inserts the Pending request into the Enrollment table!
                    string sql = @"
                        INSERT INTO Enrollment (student_id, course_id, status, enrolled_semester) 
                        SELECT @sid, @cid, 'Pending', student_sem 
                        FROM Student WHERE student_id = @sid";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", currentStudentId);
                        cmd.Parameters.AddWithValue("@cid", courseId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadMyStatus();
                LoadAvailableCourses();
                LoadPendingQueue();
                ScriptManager.RegisterStartupScript(this, GetType(), "success", "Swal.fire('Requested!', 'Your enrollment request has been sent to the Admin for approval.', 'success');", true);
            }
        }

        private void LoadPendingQueue()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT c.course_code, c.course_name 
                    FROM Enrollment e
                    JOIN Course c ON e.course_id = c.course_id
                    WHERE e.student_id = @sid AND e.status = 'Pending'";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptPendingQueue.DataSource = dt;
                    rptPendingQueue.DataBind();

                    // Show or hide the empty state message
                    divNoPending.Visible = (dt.Rows.Count == 0);
                }
            }
        }

        private bool CheckIfGraduated()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT student_isactive FROM Student WHERE student_id = @sid", con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    con.Open();
                    object result = cmd.ExecuteScalar();

                    // If the database marks them as Graduated, return true!
                    if (result != null && result.ToString() == "Graduated")
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        private int GetStudentId()
        {
            if (Session["StudentID"] != null) return Convert.ToInt32(Session["StudentID"]);
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT student_id FROM Student WHERE student_email = @email", con))
                {
                    cmd.Parameters.AddWithValue("@email", Session["UserEmail"].ToString());
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) return Convert.ToInt32(result);
                }
            }
            return 0;
        }
    }
}