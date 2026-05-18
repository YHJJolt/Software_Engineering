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
            // Required to allow file uploads on the page
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

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

        // -------------------------------------------------------------
        // LOADING THE MODAL (Fetching Base64 Image)
        // -------------------------------------------------------------
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCourse")
            {
                string courseId = e.CommandArgument.ToString();
                hdnEditCourseId.Value = courseId;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = "SELECT course_code, course_name, course_fee, course_img FROM Course WHERE course_id = @Id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", courseId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtEditCode.Text = reader["course_code"].ToString();
                                txtEditName.Text = reader["course_name"].ToString();
                                txtEditFee.Text = reader["course_fee"].ToString();

                                // Convert VARBINARY back to an image preview string
                                if (reader["course_img"] != DBNull.Value)
                                {
                                    byte[] bytes = (byte[])reader["course_img"];
                                    string base64String = Convert.ToBase64String(bytes, 0, bytes.Length);
                                    imgEditPreview.ImageUrl = "data:image/jpeg;base64," + base64String;
                                }
                                else
                                {
                                    // Reset to transparent if no image exists in DB
                                    imgEditPreview.ImageUrl = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";
                                }
                            }
                        }
                    }
                }

                pnlEditModal.Visible = true;
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
                    string sql = "";

                    // 1. Determine the correct SQL String based on whether a file exists
                    if (fuEditCourseImage.HasFile)
                    {
                        // User uploaded a new image: Update everything INCLUDING course_img
                        sql = @"UPDATE Course 
                        SET course_code = @Code, 
                            course_name = @Name, 
                            course_fee = @Fee, 
                            course_img = @Image 
                        WHERE course_id = @Id";
                    }
                    else
                    {
                        // No new image: Update everything EXCEPT course_img
                        sql = @"UPDATE Course 
                        SET course_code = @Code, 
                            course_name = @Name, 
                            course_fee = @Fee 
                        WHERE course_id = @Id";
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        // 2. Add the standard parameters that ALWAYS exist
                        cmd.Parameters.AddWithValue("@Code", txtEditCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtEditName.Text.Trim());

                        decimal fee = 0;
                        decimal.TryParse(txtEditFee.Text, out fee);
                        cmd.Parameters.AddWithValue("@Fee", fee);

                        cmd.Parameters.AddWithValue("@Id", hdnEditCourseId.Value);

                        // 3. Add the @Image parameter ONLY if we declared it in the SQL string above
                        if (fuEditCourseImage.HasFile)
                        {
                            cmd.Parameters.AddWithValue("@Image", fuEditCourseImage.FileBytes);
                        }

                        // Execute the update
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                // Hide modal and show success alert
                pnlEditModal.Visible = false;

                // IMPORTANT: Rebind your GridView here so the UI updates
                // BindGridView(); // Or whatever your method to load courses is named

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "Swal.fire('Updated', 'Course updated successfully!', 'success');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert",
                    $"Swal.fire('Error', '{ex.Message.Replace("'", "\\'")}', 'error');", true);
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