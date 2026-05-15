using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CreatePrograms : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateLecturers();
                PopulateAdmins();
            }
        }

        // Load all lecturers into Program Coordinator dropdown
        private void PopulateLecturers()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = "SELECT lecturer_id, lecturer_name FROM Lecturer ORDER BY lecturer_name ASC";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();
                    ddlLecturer.DataSource = cmd.ExecuteReader();
                    ddlLecturer.DataTextField = "lecturer_name";
                    ddlLecturer.DataValueField = "lecturer_id";
                    ddlLecturer.DataBind();
                }
                // Add default "Select" option at the top
                ddlLecturer.Items.Insert(0, new ListItem("-- Select Coordinator --", "0"));
            }
            catch (Exception ex)
            {
                ShowError("Error loading lecturers: " + ex.Message);
            }
        }

        // Load Admin (HoP) into the Dropdown
        private void PopulateAdmins()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = "SELECT admin_id, admin_name FROM [Admin (HoP)] ORDER BY admin_name ASC";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();
                    ddlAdmin.DataSource = cmd.ExecuteReader();
                    ddlAdmin.DataTextField = "admin_name";
                    ddlAdmin.DataValueField = "admin_id";
                    ddlAdmin.DataBind();
                }
                ddlAdmin.Items.Insert(0, new ListItem("-- Select Head of Program --", "0"));
            }
            catch (Exception ex)
            {
                ShowError("Error loading admins: " + ex.Message);
            }
        }

        protected void BtnSubmit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"INSERT INTO Program (program_code, program_name, program_level, program_fee, 
                                                        program_semester, program_credits, program_isactive, 
                                                        Lecturer_id, Admin_admin_id) 
                                   VALUES (@Code, @Name, @Level, @Fee, @Sem, @Cred, @IsActive, @LecID, @AdmID)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Level", ddlLevel.SelectedValue);
                        cmd.Parameters.AddWithValue("@Fee", Convert.ToDecimal(txtFee.Text));

                        object semValue = string.IsNullOrEmpty(txtSemester.Text) ? DBNull.Value : (object)Convert.ToInt32(txtSemester.Text);
                        cmd.Parameters.AddWithValue("@Sem", semValue);

                        object credValue = string.IsNullOrEmpty(txtCredits.Text) ? DBNull.Value : (object)Convert.ToInt32(txtCredits.Text);
                        cmd.Parameters.AddWithValue("@Cred", credValue);

                        cmd.Parameters.AddWithValue("@IsActive", ddlStatus.SelectedValue == "1");
                        cmd.Parameters.AddWithValue("@LecID", int.Parse(ddlLecturer.SelectedValue));
                        cmd.Parameters.AddWithValue("@AdmID", int.Parse(ddlAdmin.SelectedValue));

                        conn.Open();
                        // FIXED: Use ExecuteNonQuery instead of ExecuteScalar to ensure proper flow
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Show success message and redirect to Program list 
                            ScriptManager.RegisterStartupScript(this, GetType(), "success",
                                "Swal.fire('Success', 'Program created successfully!', 'success').then(() => { window.location = 'Program.aspx'; });", true);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                ShowError("Database Error: " + ex.Message);
            }
            catch (Exception ex)
            {
                ShowError("Error: " + ex.Message);
            }
        }

        // Return back to Program List
        protected void BtnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("Program.aspx");
        }

        // Helper method to show error message using SweetAlert
        private void ShowError(string msg)
        {
            string safeMsg = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "errorMsg",
                $"Swal.fire('Error', '{safeMsg}', 'error');", true);
        }
    }
}