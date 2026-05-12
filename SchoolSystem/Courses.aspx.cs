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
    public partial class Courses : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllCourses();
            }
        }

        // Load courses with search and pagination support
        protected void BtnApplyPageSize_Click(object sender, EventArgs e)
        {
            LoadAllCourses(txtSearch.Text.Trim());
        }

        // Load all courses from database
        private void LoadAllCourses(string search = "")
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
                        ISNULL(p.program_name, 'N/A') AS program_name,
                        c.credit_hours,
                        ISNULL(COUNT(e.student_id), 0) AS student_count,
                        c.course_status
                    FROM Course c
                    LEFT JOIN Lecturer l ON c.Lecturer_id = l.lecturer_id
                    LEFT JOIN Program p ON c.Program_id = p.program_id
                    LEFT JOIN Enrollment e ON c.course_id = e.course_id
                    WHERE (@Search = '' 
                            OR c.course_name     LIKE '%' + @Search + '%' 
                            OR c.course_code     LIKE '%' + @Search + '%'
                            OR c.course_fee      LIKE '%' + @Search + '%'
                            OR l.lecturer_name   LIKE '%' + @Search + '%'
                            OR l.lecturer_email  LIKE '%' + @Search + '%'
                            OR p.program_name    LIKE '%' + @Search + '%'
                            OR c.course_status   LIKE '%' + @Search + '%'
                            OR CAST(c.credit_hours AS NVARCHAR) LIKE '%' + @Search + '%'
                        )
                    GROUP BY 
                        c.course_code,
                        c.course_id,
                        c.course_name, 
                        c.course_fee,
                        l.lecturer_name, 
                        l.lecturer_email,
                        p.program_name, 
                        c.credit_hours, 
                        c.course_status
                    ORDER BY c.course_name";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Search", search.Trim());
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (TotalRows != null)
                        TotalRows.Text = $"of {dt.Rows.Count} rows";

                    // Parse typed value, fallback to 10 if invalid
                    int pageSize = 10;
                    if (int.TryParse(txtPageSize.Text.Trim(), out int parsed) && parsed > 0)
                        pageSize = parsed;
                    else
                        txtPageSize.Text = "10"; // Reset to default if bad input

                    DataTable sliced;
                    if (dt.Rows.Count > 0)
                    {
                        sliced = dt.AsEnumerable()
                                   .Take(pageSize)
                                   .CopyToDataTable();
                    }
                    else
                    {
                        sliced = dt.Clone(); // empty table with same columns, no crash
                    }

                    gvCourses.DataSource = sliced;
                    gvCourses.DataBind();
                }
            }
        }

        // Search and create button 
        protected void BtnSearchCourse_Click(object sender, EventArgs e)
        {
            LoadAllCourses(txtSearch.Text.Trim());
        }

        protected void BtnCreateCourse_Click(object sender, EventArgs e)
        {
            Response.Redirect("CreateCourses.aspx");
        }

        // Export selected rows to Excel
        protected void BtnExport_Click(object sender, EventArgs e)
        {
            var selectedRows = gvCourses.Rows.Cast<GridViewRow>()
                .Where(row => (row.FindControl("checkRow") as CheckBox)?.Checked == true)
                .ToList();

            if (selectedRows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "noSelection",
                    @"Swal.fire({
                title: 'No Selection',
                text: 'Please select at least one course to export.',
                icon: 'warning',
                confirmButtonColor: '#C5A059'
            });", true);
                return;
            }

            // Built DataTable for export 
            DataTable dt = new DataTable();
            dt.Columns.Add("Course Code");
            dt.Columns.Add("Course Name");
            dt.Columns.Add("Course Fee");
            dt.Columns.Add("Lecturer Name");
            dt.Columns.Add("Lecturer Email");
            dt.Columns.Add("Program Name");
            dt.Columns.Add("Credit Hours");

            foreach (GridViewRow row in selectedRows)
            {
                DataRow dr = dt.NewRow();
                dr[0] = row.Cells[1].Text.Trim();
                dr[1] = row.Cells[2].Text.Trim();
                dr[2] = row.Cells[6].Text.Trim(); // index 6 is course_fee
                dr[3] = row.Cells[3].Text.Trim();
                dr[4] = row.Cells[4].Text.Trim();
                dr[5] = row.Cells[5].Text.Trim();
                dr[6] = row.Cells[7].Text.Trim();
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
            Response.AddHeader("content-disposition", "attachment;filename=Courses.xls");
            Response.Charset = "";

            using (var sw = new System.IO.StringWriter())
            using (var hw = new System.Web.UI.HtmlTextWriter(sw))
            {
                gv.RenderControl(hw);
                Response.Write(sw.ToString());
                Response.End();
            }
        }

        // Required when using Response.Write with GridView
        public override void VerifyRenderingInServerForm(Control control) { }

        // ==================== EDIT COURSE POPUP ====================
        protected void EditCoursePopUpForm(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditCourse")
            {
                int courseId = Convert.ToInt32(e.CommandArgument);
                PopulateEditDropdowns();
                FetchCourseToEdit(courseId);
                popUpForm.Visible = true;
                upModal.Update();
            }
        }

        private void FetchCourseToEdit(int id)
        {

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "SELECT * FROM Course WHERE course_id = @ID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.Read())
                {
                    hdnEditCourseId.Value = id.ToString();
                    txtEditCode.Text = reader["course_code"].ToString();
                    txtEditName.Text = reader["course_name"].ToString();
                    txtEditFee.Text = reader["course_fee"].ToString();
                    txtEditCredits.Text = reader["credit_hours"].ToString();
                    ddlEditStatus.SelectedValue = reader["course_status"].ToString();
                    ddlEditLecturer.SelectedValue = reader["Lecturer_id"].ToString();
                    ddlEditProgram.SelectedValue = reader["Program_id"].ToString();
                }
            }
        }

        // Loads dropdowns with unique values only 
        private void PopulateEditDropdowns()
        {
            ddlEditLecturer.Items.Clear();
            ddlEditProgram.Items.Clear();

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Populate Lecturers with DISTINCT (prevents duplicates)
                    string lecQuery = @"SELECT DISTINCT lecturer_id, lecturer_name 
                                FROM Lecturer 
                                ORDER BY lecturer_name";

                    using (SqlCommand lecCmd = new SqlCommand(lecQuery, conn))
                    using (SqlDataReader lecReader = lecCmd.ExecuteReader())
                    {
                        ddlEditLecturer.DataSource = lecReader;
                        ddlEditLecturer.DataTextField = "lecturer_name";
                        ddlEditLecturer.DataValueField = "lecturer_id";
                        ddlEditLecturer.DataBind();
                    }

                    // Populate Programs with DISTINCT (prevents duplicates)
                    string progQuery = @"SELECT DISTINCT program_id, program_name 
                                 FROM Program 
                                 ORDER BY program_name";

                    using (SqlCommand progCmd = new SqlCommand(progQuery, conn))
                    using (SqlDataReader progReader = progCmd.ExecuteReader())
                    {
                        ddlEditProgram.DataSource = progReader;
                        ddlEditProgram.DataTextField = "program_name";
                        ddlEditProgram.DataValueField = "program_id";
                        ddlEditProgram.DataBind();
                    }
                }
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'Failed to load dropdown data', 'error');", true);
            }
        }

        // Save updated course information
        protected void BtnSaveUpdate_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"UPDATE Course SET 
                        course_code = @Code, course_name = @Name, course_fee = @Fee,
                        credit_hours = @Credits, course_status = @Status, 
                        Lecturer_id = @LecID, Program_id = @ProgID 
                        WHERE course_id = @ID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Code", txtEditCode.Text);
                cmd.Parameters.AddWithValue("@Name", txtEditName.Text);
                cmd.Parameters.AddWithValue("@Fee", txtEditFee.Text);
                cmd.Parameters.AddWithValue("@Credits", txtEditCredits.Text);
                cmd.Parameters.AddWithValue("@Status", ddlEditStatus.SelectedValue);
                cmd.Parameters.AddWithValue("@LecID", ddlEditLecturer.SelectedValue);
                cmd.Parameters.AddWithValue("@ProgID", ddlEditProgram.SelectedValue);
                cmd.Parameters.AddWithValue("@ID", hdnEditCourseId.Value);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            popUpForm.Visible = false;
            upModal.Update();
            LoadAllCourses(txtSearch.Text.Trim());
            upGridView.Update();
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "Swal.fire('Success', 'Course Updated', 'success');", true);
        }

        // Cancle button 
        protected void BtnCancelEdit_Click(object sender, EventArgs e)
        {
            popUpForm.Visible = false;
            upModal.Update();
        }

        // Delete course and related enrollments
        protected void BtnDeleteCourse_Click(object sender, EventArgs e)
        {
            string rawId = Request.Form["hdnCourseId"];

            if (!int.TryParse(rawId, out int courseId) || courseId <= 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'Invalid course selected.', 'error');", true);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    SqlCommand cmdEnroll = new SqlCommand("DELETE FROM Enrollment WHERE course_id = @ID", conn);
                    cmdEnroll.Parameters.AddWithValue("@ID", courseId);
                    cmdEnroll.ExecuteNonQuery();

                    SqlCommand cmdCourse = new SqlCommand("DELETE FROM Course WHERE course_id = @ID", conn);
                    cmdCourse.Parameters.AddWithValue("@ID", courseId);
                    cmdCourse.ExecuteNonQuery();
                }

                LoadAllCourses(txtSearch.Text.Trim());

                ScriptManager.RegisterStartupScript(this, GetType(), "deleted",
                    "Swal.fire({ title: 'Deleted!', text: 'Course has been deleted.', icon: 'success', timer: 1500, showConfirmButton: false });", true);
            }
            catch (SqlException)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'Failed to delete course.', 'error');", true);
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error",
                    "Swal.fire('Error', 'An unexpected error occurred.', 'error');", true);
            }
        }
    }
}