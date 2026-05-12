using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CreateCourses : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulatePrograms();
                PopulateLecturers();
            }
        }

        // Populate Program dropdown with unique values from database
        private void PopulatePrograms()
        {
            try
            {
                ddlProgram.Items.Clear();   // Clear existing items to avoid duplicates

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    // Ask the database for the Name and ID of every Program
                    string query = @"SELECT DISTINCT program_id, program_name 
                             FROM Program 
                             ORDER BY program_name ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            // Tell the dropdown list to use this data
                            ddlProgram.DataSource = reader;
                            ddlProgram.DataTextField = "program_name"; //Appear in the dropdown
                            ddlProgram.DataValueField = "program_id";  //Only save in background 
                            ddlProgram.DataBind();
                        }
                    }
                }

                // Ensure default item is at the top
                if (ddlProgram.Items.FindByValue("0") == null)
                    ddlProgram.Items.Insert(0, new ListItem("-- Select Program --", "0"));
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'Failed to load programs', 'error');", true);
            }
        }

        // Populate Lecturer dropdown with unique values from database
        private void PopulateLecturers()
        {
            try
            {
                ddlLecturer.Items.Clear();   // Extra safety

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"SELECT DISTINCT lecturer_id, lecturer_name 
                             FROM Lecturer 
                             ORDER BY lecturer_name ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            ddlLecturer.DataSource = reader;
                            ddlLecturer.DataTextField = "lecturer_name";
                            ddlLecturer.DataValueField = "lecturer_id";
                            ddlLecturer.DataBind();
                        }
                    }
                }

                if (ddlLecturer.Items.FindByValue("0") == null)
                    ddlLecturer.Items.Insert(0, new ListItem("-- Select Lecturer --", "0"));
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'Failed to load lecturers', 'error');", true);
            }
        }

        // Handle course creation
        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            // Stop if any required fields are empty 
            if (!Page.IsValid) return;

            // Make sure the fee entered is actually a number
            decimal newCourseFee = 0;
            if (!decimal.TryParse(txtCourseFee.Text.Trim(), out newCourseFee))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "invalidFee",
                    "Swal.fire('Error', 'Please enter a valid numeric fee.', 'error');", true);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open(); // Door for entering the database 

                    // --- 1. SAFE FEE VALIDATION ---
                    decimal programLimit = 0;
                    decimal currentTotal = 0;

                    // Get Program Fee Limit safely
                    string progQuery = "SELECT program_fee FROM Program WHERE program_id = @ProgID";
                    using (SqlCommand cmdProg = new SqlCommand(progQuery, conn))
                    {
                        cmdProg.Parameters.AddWithValue("@ProgID", ddlProgram.SelectedValue);
                        object result = cmdProg.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            // Strip any text like "RM" or commas so C# can safely convert it
                            string feeStr = result.ToString().Replace("RM", "").Replace(",", "").Trim();
                            decimal.TryParse(feeStr, out programLimit);
                        }
                    }

                    // Get Sum of existing Course Fees safely
                    string courseQuery = "SELECT course_fee FROM Course WHERE program_id = @ProgID";
                    using (SqlCommand cmdCourse = new SqlCommand(courseQuery, conn))
                    {
                        cmdCourse.Parameters.AddWithValue("@ProgID", ddlProgram.SelectedValue);
                        using (SqlDataReader reader = cmdCourse.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string cFeeStr = reader["course_fee"].ToString().Replace("RM", "").Replace(",", "").Trim();
                                if (decimal.TryParse(cFeeStr, out decimal cFee))
                                {
                                    currentTotal += cFee;
                                }
                            }
                        }
                    }

                    // Check if adding this new course goes over the limit
                    if ((currentTotal + newCourseFee) > programLimit)
                    {
                        decimal remaining = programLimit - currentTotal;
                        string warnMsg = $"Total fees exceed the Program Limit of RM {programLimit}. Current total is RM {currentTotal}. You can only add up to RM {remaining} more.";

                        // Uses your EXACT original Swal structure
                        string limitScript = $@"Swal.fire({{
                            title: 'Limit Exceeded!',
                            text: '{warnMsg}',
                            icon: 'warning',
                            confirmButtonColor: '#d33'
                        }});";

                        ScriptManager.RegisterStartupScript(this, GetType(), "limitAlert", limitScript, true);
                        return; // Stop execution, do not insert into database
                    }

                    // --- 2. INSERT COURSE (If validation passes) ---
                    string sql = @"INSERT INTO Course 
                           (course_code, course_name, course_fee, credit_hours, course_status, 
                            program_id, lecturer_id, calendar_id) 
                           VALUES (@Code, @Name, @Fee, @Credits, @Status, @ProgID, @LecID, 1)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtSubjectCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtSubjectName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Fee", newCourseFee.ToString()); // Added fee param
                        cmd.Parameters.AddWithValue("@Credits", CreditHours.SelectedValue);
                        cmd.Parameters.AddWithValue("@Status", Status.SelectedValue);
                        cmd.Parameters.AddWithValue("@ProgID", ddlProgram.SelectedValue);
                        cmd.Parameters.AddWithValue("@LecID", ddlLecturer.SelectedValue);

                        cmd.ExecuteNonQuery(); // Send data
                    }
                }

                // Pop out notification (Your exact original script)
                ScriptManager.RegisterStartupScript(this, GetType(), "success",
                    "Swal.fire('Success', 'Course created successfully!', 'success').then(() => window.location = 'Courses.aspx');", true);
            }
            catch (SqlException ex)
            {
                string errorMessage = "An error occurred while saving the course.";

                if (ex.Number == 2627) // Unique constraint violation
                    errorMessage = "This Course Code already exists.";

                // Your exact original script
                string script = $@"Swal.fire({{
                    title: 'Error!',
                    text: '{errorMessage}',
                    icon: 'error',
                    confirmButtonColor: '#d33'
                }});";

                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", script, true);
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert",
                    "Swal.fire('Error', 'An unexpected error occurred.', 'error');", true);
            }
        }

        // Return back to Courses page
        protected void BtnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Courses.aspx");
        }

    }
}