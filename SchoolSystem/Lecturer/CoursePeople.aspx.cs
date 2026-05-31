using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class CoursePeople : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int courseId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!int.TryParse(Request.QueryString["id"], out courseId))
            {
                Response.Redirect("~/Lecturer/LecturerDashboard.aspx");
                return;
            }

            ((LecturerCourseMaster)this.Master).PageTitle = "People";

            if (!IsPostBack) LoadPeople();
        }

        private void LoadPeople()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
            SELECT
                s.student_code,
                s.student_name,
                s.student_email,
                s.student_sem,
                p.program_name
            FROM [Enrollment] e
            JOIN [Student] s      ON e.student_id  = s.student_id
            LEFT JOIN [Program] p ON s.Program_id  = p.program_id
            WHERE e.course_id = @id
              AND e.status = 'Approved'
              AND e.enrolled_semester = s.student_sem -- <--- Filters to ONLY current semester students
            ORDER BY s.student_name", conn);
                cmd.Parameters.AddWithValue("@id", courseId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlEmpty.Visible = true;
                }
                else
                {
                    rptPeople.DataSource = dt;
                    rptPeople.DataBind();
                }
            }
        }

    }
}