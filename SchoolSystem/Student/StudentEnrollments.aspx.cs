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

        // 1. Added property to fetch the global session from the database
        protected string CurrentSessionLabel { get; set; } = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");
            currentStudentId = GetStudentId();

            if (!IsPostBack)
            {
                // Check their exact database status
                string status = GetStudentStatus();

                if (status == "Graduated")
                {
                    // Alumni screen
                    pnlActiveStudent.Visible = false;
                    pnlInactive.Visible = false;
                    pnlGraduated.Visible = true;
                }
                else if (status == "Inactive")
                {
                    // Locked out for unpaid fees
                    pnlActiveStudent.Visible = false;
                    pnlGraduated.Visible = false;
                    pnlInactive.Visible = true;
                }
                else
                {
                    // Normal Active Student
                    pnlGraduated.Visible = false;
                    pnlInactive.Visible = false;
                    pnlActiveStudent.Visible = true;

                    // 2. Fetch the global session instead of the student's semester
                    LoadCurrentSession();
                    LoadMyStatus();
                    LoadAvailableCourses();
                    LoadPendingQueue();
                }
            }
        }

        private void LoadCurrentSession()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session'", conn))
            {
                conn.Open();
                CurrentSessionLabel = cmd.ExecuteScalar()?.ToString() ?? "N/A";
            }
        }

        private void LoadMyStatus()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT c.course_code, c.course_name, e.status, e.academic_session,
                           cg.letter_grade
                    FROM Enrollment e
                    JOIN Course c ON e.course_id = c.course_id
                    LEFT JOIN CourseGrade cg ON cg.Enrollment_id = e.enrollment_id
                    WHERE e.student_id = @sid
                    ORDER BY e.academic_session DESC, c.course_code ASC";
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
                // Gets courses from the student's program that are Active in the current session
                // and haven't been enrolled yet by this student this session, excluding any
                // course already passed in a previous session (only failed courses re-appear for retake)
                string sql = @"
                    SELECT c.course_id, c.course_code, c.course_name, ISNULL(c.course_fee, 0) as course_fee
                    FROM Course c
                    JOIN CourseProgram cp ON cp.course_id = c.course_id
                    JOIN Student s ON cp.program_id = s.program_id
                    JOIN CourseAssignment_Session ca ON ca.course_id = c.course_id
                    JOIN SystemSettings ss ON ss.setting_key = 'current_session'
                    WHERE s.student_id = @sid
                      AND ca.academic_session = ss.setting_value
                      AND ca.assign_status = 'Active'
                      AND c.course_id NOT IN (
                          SELECT course_id FROM Enrollment
                          WHERE student_id = @sid
                            AND academic_session = ss.setting_value
                      )
                      AND c.course_id NOT IN (
                          SELECT e2.course_id
                          FROM Enrollment e2
                          JOIN CourseGrade cg2 ON cg2.Enrollment_id = e2.enrollment_id
                          WHERE e2.student_id = @sid
                            AND cg2.letter_grade IS NOT NULL
                            AND cg2.letter_grade <> 'F'
                      )";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptAvailableCourses.DataSource = dt;
                    rptAvailableCourses.DataBind();

                    // Show or hide the empty state message
                    divNoAvailable.Visible = (dt.Rows.Count == 0);
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
                        INSERT INTO Enrollment (student_id, course_id, status, enrolled_semester, academic_session) 
                        SELECT @sid, @cid, 'Pending', student_sem, (SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session')
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
                    WHERE e.student_id = @sid AND e.status = 'Pending'
                      AND e.academic_session = (SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session')";

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

        private string GetStudentStatus()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT student_isactive FROM Student WHERE student_id = @sid", con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    con.Open();
                    object result = cmd.ExecuteScalar();

                    // Returns 'Active', 'Inactive', or 'Graduated' exactly as Goh's triggers set them
                    return result != null ? result.ToString() : "Active";
                }
            }
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