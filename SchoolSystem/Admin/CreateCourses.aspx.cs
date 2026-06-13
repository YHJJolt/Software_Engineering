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
                    // 2. Added course_img to the INSERT statement
                    string sql = @"INSERT INTO Course (course_code, course_name, credit_hours, course_fee, Program_id, Calendar_id, course_img) 
                                   VALUES (@Code, @Name, @Credits, @Fee, @ProgID, 1, @Image)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());

                        int credits = 0;
                        int.TryParse(txtCreditHours.Text, out credits);
                        cmd.Parameters.AddWithValue("@Credits", credits);

                        decimal fee = 0;
                        decimal.TryParse(txtCourseFee.Text, out fee);
                        cmd.Parameters.AddWithValue("@Fee", fee);

                        cmd.Parameters.AddWithValue("@ProgID", ddlProgram.SelectedValue);

                        // 3. Handle the Image Parameter
                        if (imageBytes != null)
                        {
                            cmd.Parameters.Add("@Image", SqlDbType.VarBinary, -1).Value = imageBytes;
                        }
                        else
                        {
                            // If no file uploaded, insert NULL into the DB
                            cmd.Parameters.Add("@Image", System.Data.SqlDbType.VarBinary, -1).Value = DBNull.Value;
                        }

                        conn.Open();
                        cmd.ExecuteNonQuery();

                        // Link the new course to its initial program via the junction table
                        int newCourseId;
                        using (SqlCommand idCmd = new SqlCommand("SELECT CAST(SCOPE_IDENTITY() AS INT)", conn))
                        {
                            newCourseId = (int)idCmd.ExecuteScalar();
                        }

                        using (SqlCommand cpCmd = new SqlCommand(
                            "INSERT INTO CourseProgram (course_id, program_id) VALUES (@CourseId, @ProgramId)", conn))
                        {
                            cpCmd.Parameters.AddWithValue("@CourseId", newCourseId);
                            cpCmd.Parameters.AddWithValue("@ProgramId", ddlProgram.SelectedValue);
                            cpCmd.ExecuteNonQuery();
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "Swal.fire('Success', 'Course created successfully!', 'success').then(() => window.location = 'Courses.aspx');", true);
            }
            catch (SqlException ex)
            {
                string errorMessage = "An error occurred while saving the course.";
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
    }
}