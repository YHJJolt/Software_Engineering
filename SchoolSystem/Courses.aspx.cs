using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class Courses : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateProgramFilter();
                LoadAllCourses();
            }
        }

        // ==========================================
        // FILTER & SEARCH LOGIC
        // ==========================================

        private void PopulateProgramFilter()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = "SELECT DISTINCT program_id, program_name FROM Program ORDER BY program_name ASC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlProgramFilter.DataSource = reader;
                            ddlProgramFilter.DataTextField = "program_name";
                            ddlProgramFilter.DataValueField = "program_id";
                            ddlProgramFilter.DataBind();
                        }
                    }
                }
                // Add the default option at the top
                ddlProgramFilter.Items.Insert(0, new ListItem("All Programs", ""));
            }
            catch (Exception ex)
            {
                string safeMessage = HttpUtility.JavaScriptStringEncode(ex.Message);
                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "error",
                    $"Swal.fire('Error loading programs', '{safeMessage}', 'error');", true);
            }
        }

        protected void ddlProgramFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAllCourses(txtSearch.Text.Trim(), ddlProgramFilter.SelectedValue);
        }

        protected void BtnApplyPageSize_Click(object sender, EventArgs e)
        {
            LoadAllCourses(txtSearch.Text.Trim(), ddlProgramFilter.SelectedValue);
        }

        private void LoadAllCourses(string search = "", string programId = "")
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT 
                        c.course_code,
                        c.course_id,
                        c.course_name,
                        c.course_fee,
                        ISNULL(l.lecturer_name, 'N/A') AS lecturer_name,
                        ISNULL(l.lecturer_email, 'N/A') AS lecturer_email,
                        ISNULL(p.program_name, 'N/A') AS program_name
                    FROM Course c
                    LEFT JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
                    LEFT JOIN Program p ON c.Program_id = p.program_id
                    WHERE 1=1 ";

                // Apply text search if provided
                if (!string.IsNullOrWhiteSpace(search))
                {
                    query += " AND (c.course_code LIKE @Search OR c.course_name LIKE @Search)";
                }

                // Apply program filter if a specific program is selected
                if (!string.IsNullOrWhiteSpace(programId))
                {
                    query += " AND c.Program_id = @ProgramId";
                }

                query += " ORDER BY c.course_code ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                        cmd.Parameters.AddWithValue("@Search", "%" + search + "%");

                    if (!string.IsNullOrWhiteSpace(programId))
                        cmd.Parameters.AddWithValue("@ProgramId", programId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvCourses.DataSource = dt;
                    gvCourses.DataBind();
                }
            }
        }

        // ==========================================
        // EDIT / UPDATE LOGIC
        // ==========================================
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCourse")
            {
                int courseId = Convert.ToInt32(e.CommandArgument);
                LoadCourseDetailsForEdit(courseId);
            }
        }

        private void LoadCourseDetailsForEdit(int courseId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT course_id, course_code, course_name, course_fee FROM Course WHERE course_id = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", courseId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnEditCourseId.Value = reader["course_id"].ToString();
                            txtEditCode.Text = reader["course_code"].ToString();
                            txtEditName.Text = reader["course_name"].ToString();
                            txtEditFee.Text = Convert.ToDecimal(reader["course_fee"]).ToString("F2");

                            // Show the modal
                            pnlEditModal.Visible = true;
                        }
                    }
                }
            }
        }

        protected void BtnSaveUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"UPDATE Course 
                                   SET course_code = @Code, course_name = @Name, course_fee = @Fee 
                                   WHERE course_id = @ID";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtEditCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtEditName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Fee", Convert.ToDecimal(txtEditFee.Text));
                        cmd.Parameters.AddWithValue("@ID", hdnEditCourseId.Value);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                // Hide modal and refresh grid
                pnlEditModal.Visible = false;
                LoadAllCourses(txtSearch.Text.Trim(), ddlProgramFilter.SelectedValue);

                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "updated",
                    "Swal.fire('Success', 'Course updated successfully!', 'success');", true);
            }
            catch (Exception ex)
            {
                string safeMessage = HttpUtility.JavaScriptStringEncode(ex.Message);
                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "error",
                    $"Swal.fire('Error', '{safeMessage}', 'error');", true);
            }
        }

        protected void BtnCancelEdit_Click(object sender, EventArgs e)
        {
            pnlEditModal.Visible = false;
        }

        // ==========================================
        // DELETE LOGIC
        // ==========================================
        protected void BtnDeleteCourse_Click(object sender, EventArgs e)
        {
            string rawId = hdnCourseId.Value;
            if (!int.TryParse(rawId, out int courseId) || courseId <= 0) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Cascading Delete to handle Foreign Key Constraints
                    string sql = @"
                        DELETE FROM CourseGrade WHERE Enrollment_id IN (SELECT enrollment_id FROM Enrollment WHERE course_id = @ID);
                        DELETE FROM Enrollment WHERE course_id = @ID;
                        DELETE FROM LecturerEnrollment WHERE course_id = @ID;
                        DELETE FROM Course WHERE course_id = @ID;";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", courseId);
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadAllCourses(txtSearch.Text.Trim(), ddlProgramFilter.SelectedValue);
                upGridView.Update();

                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "deleted",
                    "Swal.fire({ title: 'Deleted!', text: 'Course has been deleted.', icon: 'success', timer: 1500, showConfirmButton: false });", true);
            }
            catch (SqlException ex)
            {
                string safeMessage = HttpUtility.JavaScriptStringEncode(ex.Message);
                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "error",
                    $"Swal.fire('Database Error', '{safeMessage}', 'error');", true);
            }
            catch (Exception ex)
            {
                string safeMessage = HttpUtility.JavaScriptStringEncode(ex.Message);
                ScriptManager.RegisterStartupScript(upGridView, upGridView.GetType(), "error",
                    $"Swal.fire('System Error', '{safeMessage}', 'error');", true);
            }
        }
    }
}