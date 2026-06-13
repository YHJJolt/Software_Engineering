using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class Program : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLevels();
                LoadAllPrograms();
            }
        }

        private void LoadAllPrograms(string search = "", string status = "", string level = "")
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                    SELECT 
                        p.program_id,
                        p.program_code,
                        ISNULL(p.program_name, 'N/A') AS program_name,
                        p.program_level,
                        p.program_fee,
                        p.program_semester,
                        p.program_credits,
                        ISNULL(l.lecturer_name, 'N/A') AS lecturer_name,
                        ISNULL(a.admin_name, 'N/A') AS hop_name,
                        ISNULL((
                            SELECT COUNT(DISTINCT e.student_id)
                            FROM Enrollment e
                            JOIN CourseProgram cp ON e.course_id = cp.course_id
                            WHERE cp.program_id = p.program_id
                        ), 0) AS student_count,

                        CASE WHEN p.program_isactive = 1 THEN 'Active' 
                                ELSE 'Discontinued' END AS program_status
                    FROM Program p
                    LEFT JOIN Lecturer l ON p.Lecturer_id = l.lecturer_id
                    LEFT JOIN [Admin (HoP)] a ON p.Admin_admin_id = a.admin_id
                    WHERE (@Search = '' 
                        OR p.program_name  LIKE '%' + @Search + '%'
                        OR p.program_code  LIKE '%' + @Search + '%'
                        OR p.program_level LIKE '%' + @Search + '%'
                        OR ISNULL(l.lecturer_name, '') LIKE '%' + @Search + '%'
                        OR ISNULL(a.admin_name, '')    LIKE '%' + @Search + '%'
                        OR (CASE WHEN p.program_isactive = 1 THEN 'Active' ELSE 'Discontinued' END)
                            LIKE '%' + @Search + '%')
                    AND (@status = '' OR p.program_isactive = @status)
                    AND (@level  = '' OR p.program_level    = @level)
                    ORDER BY p.program_name;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Search", search ?? "");
                        cmd.Parameters.AddWithValue("@status", status ?? "");
                        cmd.Parameters.AddWithValue("@level", level ?? "");

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Show total count 
                        if (TotalRows != null)
                            TotalRows.Text = $"of {dt.Rows.Count} rows";

                        // Apply rows per page limit
                        int pageSize = int.TryParse(txtPageSize.Text.Trim(), out int ps) && ps > 0 ? ps : 10;
                        txtPageSize.Text = pageSize.ToString();

                        // Take first row only
                        DataTable sliced = dt.Rows.Count > 0
                            ? dt.AsEnumerable().Take(pageSize).CopyToDataTable()
                            : dt.Clone();

                        gvCourses.DataSource = sliced;
                        gvCourses.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                if (TotalRows != null) TotalRows.Text = "of 0 rows (Error)";
                ScriptManager.RegisterStartupScript(this, GetType(), "loadError",
                    $"Swal.fire('Load Error', '{ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }
        private void LoadLevels()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT DISTINCT program_level FROM Program WHERE program_level IS NOT NULL ORDER BY program_level", conn))
            {
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlLevelFilter.DataSource = dr;
                    ddlLevelFilter.DataTextField = "program_level";
                    ddlLevelFilter.DataValueField = "program_level";
                    ddlLevelFilter.DataBind();
                }
            }
            ddlLevelFilter.Items.Insert(0, new ListItem("All Levels", ""));
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAllPrograms(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlLevelFilter.SelectedValue);
            upGridView.Update();
        }

        protected void ddlLevelFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAllPrograms(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlLevelFilter.SelectedValue);
            upGridView.Update();
        }

        //Search
        protected void BtnSearchProgram_Click(object sender, EventArgs e)
        {
            LoadAllPrograms(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlLevelFilter.SelectedValue);
        }

        // Create
        protected void BtnCreateProgram_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin/CreateProgram.aspx");
        }

        // Export
        protected void BtnExport_Click(object sender, EventArgs e)
        {
            // Get selected checkboxes
            var selectedRows = gvCourses.Rows.Cast<GridViewRow>()
                .Where(row => (row.FindControl("checkRow") as CheckBox)?.Checked == true)
                .ToList();

            if (selectedRows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "noSelection",
                    @"Swal.fire({
                        title: 'No Selection',
                        text: 'Please select at least one program to export.',
                        icon: 'warning',
                        confirmButtonColor: '#C5A059'
                    });", true);
                return;
            }

            DataTable dt = new DataTable(); // Built DataTable for export 
            dt.Columns.Add("Program Code");
            dt.Columns.Add("Program Name");
            dt.Columns.Add("Level");
            dt.Columns.Add("Fee (RM)");
            dt.Columns.Add("Semester");
            dt.Columns.Add("Credits");
            dt.Columns.Add("Coordinator");
            dt.Columns.Add("Head of Program");
            dt.Columns.Add("No. of Students");

            foreach (GridViewRow row in selectedRows) // Fill in columns 
            {
                DataRow dr = dt.NewRow();
                // Cells: 0=checkbox, 1=code, 2=name, 3=level,
                //        4=fee, 5=semester, 6=credits, 7=coordinator,
                //        8=hop, 9=students, 
                dr[0] = row.Cells[1].Text.Trim();
                dr[1] = row.Cells[2].Text.Trim();
                dr[2] = row.Cells[3].Text.Trim();
                dr[3] = row.Cells[4].Text.Trim();
                dr[4] = row.Cells[5].Text.Trim();
                dr[5] = row.Cells[6].Text.Trim();
                dr[6] = row.Cells[7].Text.Trim();
                dr[7] = row.Cells[8].Text.Trim();
                dr[8] = row.Cells[9].Text.Trim();
                dt.Rows.Add(dr);
            }

            GridView tempGv = new GridView { DataSource = dt };
            tempGv.DataBind();
            ExportToExcel(tempGv);
        }

        private void ExportToExcel(GridView gv)
        {
            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", "attachment;filename=Programs.xls");
            Response.Charset = "";

            using (var sw = new System.IO.StringWriter())
            using (var hw = new System.Web.UI.HtmlTextWriter(sw))
            {
                gv.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        // Pagination 
        protected void BtnApplyPageSize_Click(object sender, EventArgs e)
        {
            LoadAllPrograms(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlLevelFilter.SelectedValue);
        }


        // Required when using Response.Write with GridView
        public override void VerifyRenderingInServerForm(Control control) { }

        // Edit Program Modal

        protected void EditCoursePopUpForm(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCourse")
            {
                int programId = Convert.ToInt32(e.CommandArgument);
                PopulateEditDropdowns();
                FetchProgramToEdit(programId);
                popUpForm.Visible = true;
                upModal.Update();
            }
        }

        // Load existing program data into edit form
        private void PopulateEditDropdowns()
        {
            ddlEditLecturer.Items.Clear();
            ddlEditHOP.Items.Clear();

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Lecturers
                    string lecQuery = "SELECT lecturer_id, lecturer_name FROM Lecturer ORDER BY lecturer_name";
                    using (SqlCommand cmd = new SqlCommand(lecQuery, conn))
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        ddlEditLecturer.DataSource = r;
                        ddlEditLecturer.DataTextField = "lecturer_name";
                        ddlEditLecturer.DataValueField = "lecturer_id";
                        ddlEditLecturer.DataBind();
                    }

                    // Head of Program
                    string hopQuery = "SELECT admin_id, admin_name FROM [Admin (HoP)] ORDER BY admin_name";
                    using (SqlCommand cmd = new SqlCommand(hopQuery, conn))
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        ddlEditHOP.DataSource = r;
                        ddlEditHOP.DataTextField = "admin_name";
                        ddlEditHOP.DataValueField = "admin_id";
                        ddlEditHOP.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "ddlError",
                    $"Swal.fire('Dropdown Error', '{ex.Message}', 'error');", true);
            }
        }

        // Populate lecturer and HOP dropdowns from DB 
        private void FetchProgramToEdit(int id)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"SELECT * FROM Program WHERE program_id = @ID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", id);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                hdnEditProgramId.Value = id.ToString();

                                txtEditCode.Text = reader["program_code"]?.ToString() ?? "";
                                txtEditName.Text = reader["program_name"]?.ToString() ?? "";
                                txtEditLevel.Text = reader["program_level"]?.ToString() ?? "";
                                txtEditFee.Text = reader["program_fee"]?.ToString() ?? "";
                                txtEditSemester.Text = reader["program_semester"]?.ToString() ?? "";
                                txtEditCreditHours.Text = reader["program_credits"]?.ToString() ?? "";

                                // Status
                                bool isActive = reader["program_isactive"] != DBNull.Value && Convert.ToBoolean(reader["program_isactive"]);
                                ddlEditStatus.SelectedValue = isActive ? "1" : "0";

                                // Lecturer
                                string lecId = reader["Lecturer_id"]?.ToString() ?? "";
                                var lecItem = ddlEditLecturer.Items.FindByValue(lecId);
                                if (lecItem != null) ddlEditLecturer.SelectedValue = lecId;

                                // Head of Program
                                string adminId = reader["Admin_admin_id"]?.ToString() ?? "";
                                var hopItem = ddlEditHOP.Items.FindByValue(adminId);
                                if (hopItem != null) ddlEditHOP.SelectedValue = adminId;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "fetchError",
                    $"Swal.fire('Fetch Error', '{ex.Message}', 'error');", true);
            }
        }

        // Updates program record in DB 

        protected void BtnSaveUpdate_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnEditProgramId.Value, out int programId) || programId <= 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "invalidId",
                    "Swal.fire('Error', 'Invalid program selected.', 'error');", true);
                return;
            }

            // --- INPUT VALIDATION ---
            if (!int.TryParse(txtEditSemester.Text.Trim(), out int semChk) || semChk <= 0)
            {
                popUpForm.Visible = true; upModal.Update();
                ScriptManager.RegisterStartupScript(this, GetType(), "semErr",
                    "Swal.fire('Invalid', 'Total Semesters must be greater than 0.', 'warning');", true);
                return;
            }

            if (!decimal.TryParse(txtEditFee.Text.Trim(), out decimal feeChk) || feeChk <= 0)
            {
                popUpForm.Visible = true; upModal.Update();
                ScriptManager.RegisterStartupScript(this, GetType(), "feeErr",
                    "Swal.fire('Invalid', 'Total Fees must be greater than 0.', 'warning');", true);
                return;
            }

            if (!int.TryParse(txtEditCreditHours.Text.Trim(), out int credChk) || credChk <= 0)
            {
                popUpForm.Visible = true; upModal.Update();
                ScriptManager.RegisterStartupScript(this, GetType(), "credErr",
                    "Swal.fire('Invalid', 'Total Credit Hours must be greater than 0.', 'warning');", true);
                return;
            }
            if (ProgramCodeExists(txtEditCode.Text.Trim(), programId))
            {
                popUpForm.Visible = true; upModal.Update();
                ScriptManager.RegisterStartupScript(this, GetType(), "codeErr",
                    "Swal.fire('Duplicate', 'That Program Code is already in use.', 'warning');", true);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = @"
                UPDATE Program 
                SET 
                    program_code        = @Code,
                    program_name        = @Name,
                    program_level       = @Level,
                    program_fee         = @Fee,
                    program_semester    = @Semester,
                    program_credits     = @Credits,
                    program_isactive    = @IsActive,
                    Lecturer_id         = @LecID,
                    Admin_admin_id      = @AdminID
                WHERE program_id = @ID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Code", txtEditCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtEditName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Level", txtEditLevel.Text.Trim());

                        object feeParam = decimal.TryParse(txtEditFee.Text.Trim(), out decimal fee)
                                          ? fee : (object)DBNull.Value;
                        cmd.Parameters.AddWithValue("@Fee", feeParam);

                        object semParam = int.TryParse(txtEditSemester.Text.Trim(), out int sem)
                                          ? sem : (object)DBNull.Value;
                        cmd.Parameters.AddWithValue("@Semester", semParam);

                        object creditsParam = int.TryParse(txtEditCreditHours.Text.Trim(), out int cr)
                                              ? cr : (object)DBNull.Value;
                        cmd.Parameters.AddWithValue("@Credits", creditsParam);

                        cmd.Parameters.AddWithValue("@IsActive", ddlEditStatus.SelectedValue == "1" ? 1 : 0);

                        object lecParam = string.IsNullOrEmpty(ddlEditLecturer.SelectedValue)
                                          ? DBNull.Value : (object)int.Parse(ddlEditLecturer.SelectedValue);
                        cmd.Parameters.AddWithValue("@LecID", lecParam);

                        object adminParam = string.IsNullOrEmpty(ddlEditHOP.SelectedValue)
                                            ? DBNull.Value : (object)int.Parse(ddlEditHOP.SelectedValue);
                        cmd.Parameters.AddWithValue("@AdminID", adminParam);

                        cmd.Parameters.AddWithValue("@ID", programId);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            popUpForm.Visible = false;
                            upModal.Update();
                            LoadAllPrograms(txtSearch.Text.Trim());
                            upGridView.Update();

                            ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                                "Swal.fire('Success', 'Program updated successfully.', 'success');", true);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, GetType(), "noUpdate",
                                "Swal.fire('Warning', 'No record was updated.', 'warning');", true);
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "sqlError",
                    $"Swal.fire('Database Error', 'Error while saving: {ex.Message}', 'error');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "genError",
                    $"Swal.fire('Error', 'Unexpected error: {ex.Message}', 'error');", true);
            }
        }
        protected void BtnCancelEdit_Click(object sender, EventArgs e)
        {
            popUpForm.Visible = false;
            upModal.Update();
        }

        private bool ProgramCodeExists(string code, int excludeId = 0)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string q = "SELECT COUNT(1) FROM Program WHERE program_code = @code AND program_id <> @id";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@code", code);
                    cmd.Parameters.AddWithValue("@id", excludeId);
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }
    }
}