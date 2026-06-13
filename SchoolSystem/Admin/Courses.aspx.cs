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
                        ISNULL(
                            STUFF((SELECT DISTINCT ', ' + p2.program_name
                                   FROM CourseProgram cp2
                                   JOIN Program p2 ON cp2.program_id = p2.program_id
                                   WHERE cp2.course_id = c.course_id
                                   FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)'), 1, 2, ''),
                            'N/A') AS program_name
                    FROM Course c
                    WHERE 1=1 ";

                // Apply text search if provided
                if (!string.IsNullOrWhiteSpace(search))
                {
                    query += " AND (c.course_code LIKE @Search OR c.course_name LIKE @Search)";
                }

                // Apply program filter if a specific program is selected
                if (!string.IsNullOrWhiteSpace(programId))
                {
                    query += @" AND EXISTS (SELECT 1 FROM CourseProgram cp JOIN Program p ON cp.program_id = p.program_id WHERE cp.course_id = c.course_id AND p.program_id = @ProgramId)";
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
                    conn.Open();

                    // Load course fields
                    string sql = "SELECT course_code, course_name, course_fee, course_img FROM Course WHERE course_id = @Id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", courseId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtEditCode.Text = reader["course_code"].ToString();
                                txtEditName.Text = reader["course_name"].ToString();
                                txtEditFee.Text = reader["course_fee"].ToString();

                                if (reader["course_img"] != DBNull.Value)
                                {
                                    byte[] bytes = (byte[])reader["course_img"];
                                    imgEditPreview.ImageUrl = "data:image/jpeg;base64," + Convert.ToBase64String(bytes);
                                }
                                else
                                {
                                    imgEditPreview.ImageUrl = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";
                                }
                            }
                        }
                    }

                    // Populate program checkboxes
                    string sqlPrograms = "SELECT program_id, program_name FROM Program ORDER BY program_name";
                    using (SqlCommand cmd = new SqlCommand(sqlPrograms, conn))
                    {
                        DataTable dtPrograms = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dtPrograms);
                        cblEditPrograms.DataSource = dtPrograms;
                        cblEditPrograms.DataTextField = "program_name";
                        cblEditPrograms.DataValueField = "program_id";
                        cblEditPrograms.DataBind();
                    }

                    // Pre-check programs already linked to this course
                    string sqlLinked = "SELECT program_id FROM CourseProgram WHERE course_id = @Id";
                    using (SqlCommand cmd = new SqlCommand(sqlLinked, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", courseId);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                string pid = rdr["program_id"].ToString();
                                var item = cblEditPrograms.Items.FindByValue(pid);
                                if (item != null) item.Selected = true;
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

        private bool CourseCodeExists(string code, int excludeId = 0)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string q = "SELECT COUNT(1) FROM Course WHERE course_code = @code AND course_id <> @id";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@code", code);
                    cmd.Parameters.AddWithValue("@id", excludeId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }

        private void ShowEditError(string msg)
        {
            pnlEditModal.Visible = true;
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "err",
                $"Swal.fire('Error', '{safe}', 'error');", true);
        }

        private void ShowError(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "err",
                $"Swal.fire('Error', '{safe}', 'error');", true);
        }
        protected void BtnSaveUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                string code = txtEditCode.Text.Trim();
                int courseId = int.TryParse(hdnEditCourseId.Value, out int cidTmp) ? cidTmp : 0;

                if (!decimal.TryParse(txtEditFee.Text.Trim(), out decimal feeVal) || feeVal <= 0)
                { ShowEditError("Course Fee must be greater than 0."); return; }

                if (CourseCodeExists(code, courseId))
                { ShowEditError("Course Code '" + code + "' already exists."); return; }

                if (fuEditCourseImage.HasFile)
                {
                    string ext = System.IO.Path.GetExtension(fuEditCourseImage.FileName).ToLowerInvariant();
                    string[] allowed = { ".jpg", ".jpeg", ".png" };
                    if (Array.IndexOf(allowed, ext) < 0)
                    { ShowEditError("Cover image must be .jpg, .jpeg or .png."); return; }
                    if (fuEditCourseImage.PostedFile.ContentLength > 5 * 1024 * 1024)
                    { ShowEditError("Cover image must be 5MB or smaller."); return; }
                }

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

                    // Save program associations: delete old, insert selected
                    int cid = int.Parse(hdnEditCourseId.Value);
                    new SqlCommand("DELETE FROM CourseProgram WHERE course_id = @Id",
                        conn)
                    { Parameters = { new SqlParameter("@Id", cid) } }.ExecuteNonQuery();

                    foreach (System.Web.UI.WebControls.ListItem item in cblEditPrograms.Items)
                    {
                        if (item.Selected)
                        {
                            var ins = new SqlCommand(
                                "INSERT INTO CourseProgram (course_id, program_id) VALUES (@Cid, @Pid)", conn);
                            ins.Parameters.AddWithValue("@Cid", cid);
                            ins.Parameters.AddWithValue("@Pid", int.Parse(item.Value));
                            ins.ExecuteNonQuery();
                        }
                    }
                }

                // Hide modal and show success alert
                pnlEditModal.Visible = false;

                // IMPORTANT: Rebind your GridView here so the UI updates
                // BindGridView(); // Or whatever your method to load courses is named

                LoadAllCourses(txtSearch.Text.Trim(), ddlProgramFilter.SelectedValue);

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
                        DELETE FROM AttendanceRecord WHERE enrollment_id IN (SELECT enrollment_id FROM Enrollment WHERE course_id = @ID);
                        DELETE FROM CourseGrade WHERE Enrollment_id IN (SELECT enrollment_id FROM Enrollment WHERE course_id = @ID);
                        DELETE FROM PaymentDetail WHERE enrollment_id IN (SELECT enrollment_id FROM Enrollment WHERE course_id = @ID);
                        DELETE FROM Enrollment WHERE course_id = @ID;
                        DELETE FROM Announcement WHERE Course_id = @ID;
                        DELETE FROM AssignmentSubmission WHERE assignment_id IN (SELECT assignment_id FROM CourseAssignment WHERE course_id = @ID);
                        DELETE FROM CourseAssignment WHERE course_id = @ID;
                        DELETE FROM ModuleFile WHERE module_id IN (SELECT module_id FROM CourseModule WHERE course_id = @ID);
                        DELETE FROM CourseModule WHERE course_id = @ID;
                        DELETE FROM CourseProgram WHERE course_id = @ID;
                        DELETE FROM CourseAssignment_Session WHERE course_id = @ID;
                        DELETE FROM LecturerCourseFavourite WHERE course_id = @ID;
                        DELETE FROM StudentCourseFavourite WHERE course_id = @ID;
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