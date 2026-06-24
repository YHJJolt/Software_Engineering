using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CreateCourses : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        protected global::System.Web.UI.WebControls.FileUpload fuCourseImage;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Ensures the form allows file uploads when inside a Master Page
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            if (!IsPostBack)
            {
                PopulatePrograms();
            }
        }

        private void PopulatePrograms()
        {
            try
            {
                ddlProgram.Items.Clear();
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = "SELECT DISTINCT program_id, program_name FROM Program ORDER BY program_name ASC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlProgram.DataSource = reader;
                            ddlProgram.DataTextField = "program_name";
                            ddlProgram.DataValueField = "program_id";
                            ddlProgram.DataBind();
                        }
                    }
                }
                ddlProgram.Items.Insert(0, new ListItem("-- Select Program --", "0"));
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"Swal.fire('Error', 'Failed to load programs: {ex.Message}', 'error');", true);
            }
        }

        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string code = txtCode.Text.Trim();
            string name = txtName.Text.Trim();

            if (string.IsNullOrWhiteSpace(code))
            { ShowError("Course Code is required."); return; }

            if (string.IsNullOrWhiteSpace(name))
            { ShowError("Course Name is required."); return; }

            if (!int.TryParse(txtCreditHours.Text.Trim(), out int credits) || credits <= 0)
            { ShowError("Credit Hours must be a whole number greater than 0."); return; }

            if (!decimal.TryParse(txtCourseFee.Text.Trim(), out decimal fee) || fee <= 0)
            { ShowError("Course Fee must be 0 or a positive number."); return; }

            if (CourseCodeExists(code))
            { ShowError("Course Code '" + code + "' already exists."); return; }

            if (fuCourseImage.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fuCourseImage.FileName).ToLowerInvariant();
                string[] allowed = { ".jpg", ".jpeg", ".png" };
                if (Array.IndexOf(allowed, ext) < 0)
                { ShowError("Cover image must be a .jpg, .jpeg or .png file."); return; }
                if (fuCourseImage.PostedFile.ContentLength > 5 * 1024 * 1024)
                { ShowError("Cover image must be 5MB or smaller."); return; }
            }

            try
            {
                // 1. Process the Image Upload
                byte[] imageBytes = null;
                if (fuCourseImage.HasFile)
                {
                    // Extracts the file directly into a byte array
                    imageBytes = fuCourseImage.FileBytes;
                }

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Course.Calendar_id is a required FK, but the Calendar table is just the
                    // admin's general events calendar, so any seeded row referenced by id can be
                    // deleted later. Resolve a valid id at insert time instead of hardcoding one.
                    int calendarId = GetOrCreateDefaultCalendarId(conn);

                    string sql = @"INSERT INTO Course (course_code, course_name, credit_hours, course_fee, Calendar_id, course_img)
                                   VALUES (@Code, @Name, @Credits, @Fee, @CalendarId, @Image);
                                   SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    int newCourseId;

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@CalendarId", calendarId);
                        cmd.Parameters.AddWithValue("@Credits", credits);
                        cmd.Parameters.AddWithValue("@Fee", fee);

                        // 3. Handle the Image Parameter
                        if (imageBytes != null)
                        {
                            cmd.Parameters.Add("@Image", SqlDbType.VarBinary, -1).Value = imageBytes;
                        }
                        else
                        {
                            // If no file uploaded, insert NULL into the DB
                            cmd.Parameters.Add("@Image", SqlDbType.VarBinary, -1).Value = DBNull.Value;
                        }

                        // Execute and grab the new ID immediately
                        newCourseId = (int)cmd.ExecuteScalar();
                    }

                    // 4. Link the new course to its initial program via the junction table
                    using (SqlCommand cpCmd = new SqlCommand(
                        "INSERT INTO CourseProgram (course_id, program_id) VALUES (@CourseId, @ProgramId)", conn))
                    {
                        cpCmd.Parameters.AddWithValue("@CourseId", newCourseId);
                        cpCmd.Parameters.AddWithValue("@ProgramId", ddlProgram.SelectedValue);
                        cpCmd.ExecuteNonQuery();
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "Swal.fire('Success', 'Course created successfully!', 'success').then(() => window.location = 'Courses.aspx');", true);
            }
            catch (SqlException ex)
            {
                string errorMessage = "An error occurred while saving the course: " + ex.Message.Replace("'", "\\'");
                if (ex.Number == 2627)
                    errorMessage = "This Course Code already exists.";

                string script = $@"Swal.fire({{
                    title: 'Error!',
                    text: '{errorMessage}',
                    icon: 'error',
                    confirmButtonColor: '#d33'
                }});";

                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", script, true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert",
                    $"Swal.fire('Error', 'An unexpected error occurred: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        protected void BtnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin/Courses.aspx");
        }

        private int GetOrCreateDefaultCalendarId(SqlConnection conn)
        {
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 calendar_id FROM Calendar ORDER BY calendar_id ASC", conn))
            {
                object result = cmd.ExecuteScalar();
                if (result != null) return Convert.ToInt32(result);
            }

            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO Calendar (event_title, event_desc, start_date, end_date, event_type, Admin_id)
                  VALUES ('Course Catalog', 'Auto-generated calendar entry for course records', GETDATE(), GETDATE(), 'General', 1);
                  SELECT CAST(SCOPE_IDENTITY() AS INT);", conn))
            {
                return (int)cmd.ExecuteScalar();
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

        private void ShowError(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "err",
                $"Swal.fire('Error', '{safe}', 'error');", true);
        }
    }
}