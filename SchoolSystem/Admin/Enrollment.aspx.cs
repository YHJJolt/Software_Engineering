using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class Enrollment : System.Web.UI.Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateSessionFilter();
                LoadEnrollments();
            }
        }

        private void PopulateSessionFilter()
        {
            string selected = ddlSessionFilter.SelectedValue;
            ddlSessionFilter.Items.Clear();
            ddlSessionFilter.Items.Add(new ListItem("All Sessions", ""));

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string sql = @"SELECT DISTINCT academic_session FROM Enrollment
                                WHERE academic_session IS NOT NULL AND academic_session <> ''
                                ORDER BY academic_session DESC";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlSessionFilter.Items.Add(new ListItem(reader["academic_session"].ToString()));
                        }
                    }
                }
            }

            ListItem item = ddlSessionFilter.Items.FindByValue(selected);
            if (item != null) ddlSessionFilter.SelectedValue = selected;
        }

        private void LoadEnrollments(string searchTerm = "", string status = "", string session = "")
        {
            lblMessage.Visible = false;
            lblMessage.Text = "";

            DataTable dt = GetEnrollments(searchTerm, status, session);

            int pageSize = 10;
            if (int.TryParse(txtPageSize.Text.Trim(), out int ps) && ps > 0)
                pageSize = ps;

            Enrollments.PageSize = pageSize;
            Enrollments.DataSource = dt;
            Enrollments.DataBind();

            TotalRows.Text = $"of {dt.Rows.Count} rows";
        }

        private DataTable GetEnrollments(string search = "", string status = "", string session = "")
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string sql = @"SELECT e.enrollment_id, s.student_name as name, s.student_email as email,
                      p.program_name, e.enrolled_semester, c.course_code, c.course_name,
                      e.enrollment_date, e.status, e.academic_session
               FROM Enrollment e
               INNER JOIN Student s ON e.student_id = s.student_id
               INNER JOIN Program p ON s.Program_id = p.program_id
               INNER JOIN Course c ON e.course_id = c.course_id
               WHERE 1=1 ";

                if (!string.IsNullOrEmpty(search))
                {
                    sql += " AND (s.student_name LIKE @Search OR p.program_name LIKE @Search OR c.course_name LIKE @Search) ";
                }

                if (!string.IsNullOrEmpty(status))
                {
                    sql += " AND e.status = @Status";
                }

                if (!string.IsNullOrEmpty(session))
                {
                    sql += " AND e.academic_session = @Session";
                }

                sql += " ORDER BY s.student_name";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
                    if (!string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@Status", status);
                    if (!string.IsNullOrEmpty(session)) cmd.Parameters.AddWithValue("@Session", session);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            return dt;
        }

        protected void BtnSearchEnrollment_Click(object sender, EventArgs e)
        {
            Enrollments.PageIndex = 0;
            LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
        }

        protected void DdlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            Enrollments.PageIndex = 0;
            LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
        }

        protected void DdlSessionFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            Enrollments.PageIndex = 0;
            LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
        }

        // --- SINGLE ACTIONS ---

        protected void BtnApprove_Click(object sender, EventArgs e)
        {
            UpdateStatus(((Button)sender).CommandArgument, "Approved");
        }

        protected void BtnReject_Click(object sender, EventArgs e)
        {
            UpdateStatus(((Button)sender).CommandArgument, "Rejected");
        }

        protected void BtnDisenroll_Click(object sender, EventArgs e)
        {
            UpdateStatus(((Button)sender).CommandArgument, "Dropped");
        }

        protected void BtnDeleteEnrollment_Click(object sender, EventArgs e)
        {
            string enrollmentId = ((Button)sender).CommandArgument;
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    string sql = @"DELETE FROM CourseGrade WHERE Enrollment_id = @ID;
                           DELETE FROM Enrollment WHERE enrollment_id = @ID;";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", enrollmentId);
                        cmd.ExecuteNonQuery();
                    }
                }

                ShowMessage("Record permanently deleted.", "success");
                LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting record: " + ex.Message, "error");
            }
        }


        private void UpdateStatus(string id, string newStatus)
        {
            // status_updated_at lets the student notification feed sort/track rejections by when they happened
            string sql = "UPDATE Enrollment SET status = @Status, status_updated_at = GETDATE() WHERE enrollment_id = @ID";
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@ID", id);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                ShowMessage($"Enrollment successfully {newStatus.ToLower()}.", "success");
                LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating status: " + ex.Message, "error");
            }
        }

        // --- BULK ACTIONS ---

        protected void BtnApproveSelected_Click(object sender, EventArgs e) { BulkUpdateStatus("Approved"); }
        protected void BtnRejectSelected_Click(object sender, EventArgs e) { BulkUpdateStatus("Rejected"); }

        private void BulkUpdateStatus(string status)
        {
            int count = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();
                    foreach (GridViewRow row in Enrollments.Rows)
                    {
                        CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                        if (chkSelect != null && chkSelect.Checked)
                        {
                            HiddenField hdnId = (HiddenField)row.FindControl("hdnEnrollmentId");
                            if (hdnId != null && !string.IsNullOrEmpty(hdnId.Value))
                            {
                                // FIXED: Completely removed tab check references
                                string sql = "UPDATE Enrollment SET status = @Status, status_updated_at = GETDATE() WHERE enrollment_id = @ID";

                                using (SqlCommand cmd = new SqlCommand(sql, conn))
                                {
                                    cmd.Parameters.AddWithValue("@Status", status);
                                    cmd.Parameters.AddWithValue("@ID", hdnId.Value);
                                    cmd.ExecuteNonQuery();
                                }
                                count++;
                            }
                        }
                    }
                }

                if (count > 0) ShowMessage($"{count} record(s) marked as {status}.", "success");
                else ShowMessage("No records selected.", "error");

                LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage("Error updating records: " + ex.Message, "error");
            }
        }

        protected void BtnExportSelected_Click(object sender, EventArgs e)
        {
            List<string> selectedIds = new List<string>();
            foreach (GridViewRow row in Enrollments.Rows)
            {
                CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                if (chkSelect != null && chkSelect.Checked)
                {
                    HiddenField hdnId = (HiddenField)row.FindControl("hdnEnrollmentId");
                    if (hdnId != null && !string.IsNullOrEmpty(hdnId.Value))
                        selectedIds.Add(hdnId.Value);
                }
            }

            if (selectedIds.Count == 0)
            {
                ShowMessage("No records selected for export.", "error");
                return;
            }

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string[] paramNames = selectedIds.Select((id, i) => "@ID" + i).ToArray();
                string sql = $@"SELECT s.student_name as Name, s.student_email as Email,
                      p.program_name as Program, e.academic_session as Session,
                      c.course_code as CourseCode, c.course_name as CourseName,
                      e.enrollment_date as EnrollmentDate, e.status as Status
               FROM Enrollment e
               INNER JOIN Student s ON e.student_id = s.student_id
               INNER JOIN Program p ON s.Program_id = p.program_id
               INNER JOIN Course c ON e.course_id = c.course_id
               WHERE e.enrollment_id IN ({string.Join(",", paramNames)})
               ORDER BY s.student_name";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    for (int i = 0; i < selectedIds.Count; i++)
                        cmd.Parameters.AddWithValue(paramNames[i], selectedIds[i]);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }

            StringBuilder sb = new StringBuilder();
            sb.Append("<table border='1'><tr>");
            foreach (DataColumn col in dt.Columns)
                sb.Append("<th>").Append(col.ColumnName).Append("</th>");
            sb.Append("</tr>");

            foreach (DataRow row in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (object cell in row.ItemArray)
                    sb.Append("<td>").Append(cell).Append("</td>");
                sb.Append("</tr>");
            }
            sb.Append("</table>");

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", "attachment;filename=Enrollments_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xls");
            Response.Write(sb.ToString());
            Response.End();
        }

        protected void BtnDeleteSelected_Click(object sender, EventArgs e)
        {
            int count = 0;

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    foreach (GridViewRow row in Enrollments.Rows)
                    {
                        CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                        if (chkSelect != null && chkSelect.Checked)
                        {
                            HiddenField hdnId = (HiddenField)row.FindControl("hdnEnrollmentId");

                            if (hdnId != null && !string.IsNullOrEmpty(hdnId.Value))
                            {
                                // FIXED: Cleared out old Lecturer table deletion fallbacks
                                string sql = @"
                                    DELETE FROM CourseGrade WHERE Enrollment_id = @ID;
                                    DELETE FROM Enrollment WHERE enrollment_id = @ID;";

                                using (SqlCommand cmd = new SqlCommand(sql, conn))
                                {
                                    cmd.Parameters.AddWithValue("@ID", hdnId.Value);
                                    cmd.ExecuteNonQuery();
                                }
                                count++;
                            }
                        }
                    }
                }

                if (count > 0) ShowMessage($"{count} record(s) permanently deleted.", "success");
                else ShowMessage("No records selected for deletion.", "error");

                LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
            }
            catch (Exception ex)
            {
                ShowMessage("Error deleting records: " + ex.Message, "error");
            }
        }

        protected void Enrollments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            Enrollments.PageIndex = e.NewPageIndex;
            LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
        }

        protected void BtnApplyPageSize_Click(object sender, EventArgs e)
        {
            Enrollments.PageIndex = 0;
            LoadEnrollments(txtSearch.Text.Trim(), ddlStatusFilter.SelectedValue, ddlSessionFilter.SelectedValue);
        }

        private void ShowMessage(string message, string type)
        {
            lblMessage.Text = message;
            lblMessage.Visible = true;

            if (type == "success")
            {
                lblMessage.Style["background"] = "#d4edda"; lblMessage.Style["color"] = "#155724";
            }
            else
            {
                lblMessage.Style["background"] = "#f8d7da"; lblMessage.Style["color"] = "#721c24";
            }
        }

        private string _lastRenderedName = "";
        protected bool IsSameName(int rowIndex, string currentName)
        {
            if (rowIndex == 0) { _lastRenderedName = currentName; return false; }
            if (currentName == _lastRenderedName) return true;
            _lastRenderedName = currentName;
            return false;
        }
    }
}