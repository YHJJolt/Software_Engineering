using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CourseAllocation : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        private string ActiveSession
        {
            get
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session'", conn))
                {
                    conn.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? "JAN2026";
                }
            }
        }

        private string ActiveSessionLabel
        {
            get
            {
                string s = ActiveSession;
                return (s.Length >= 7) ? s.Substring(0, 3) + " " + s.Substring(3) : s;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateCourseDropdown();
                PopulateLecturerDropdown();
                RefreshPage();
            }
        }

        private void RefreshPage()
        {
            litActiveSession.Text = ActiveSessionLabel;
            LoadAssignments();
        }

        // ============================================================
        // DROPDOWNS
        // ============================================================

        private void PopulateCourseDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT course_id, course_code + ' - ' + course_name AS display FROM Course ORDER BY course_code", conn))
            {
                conn.Open();
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                ddlCourse.DataSource = dt;
                ddlCourse.DataTextField = "display";
                ddlCourse.DataValueField = "course_id";
                ddlCourse.DataBind();
            }
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", "0"));
        }

        private void PopulateLecturerDropdown()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT lecturer_id, lecturer_name FROM Lecturer WHERE teacher_isactive = 'Active' ORDER BY lecturer_name", conn))
            {
                conn.Open();
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                ddlLecturer.DataSource = dt;
                ddlLecturer.DataTextField = "lecturer_name";
                ddlLecturer.DataValueField = "lecturer_id";
                ddlLecturer.DataBind();
            }
            ddlLecturer.Items.Insert(0, new ListItem("-- Select Lecturer --", "0"));
        }

        // ============================================================
        // GRID
        // ============================================================

        private void LoadAssignments()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT
                        ca.assign_id,
                        c.course_code,
                        c.course_name,
                        l.lecturer_name,
                        ca.assign_status
                    FROM CourseAssignment_Session ca
                    INNER JOIN Course   c ON ca.course_id   = c.course_id
                    INNER JOIN Lecturer l ON ca.lecturer_id = l.lecturer_id
                    WHERE ca.academic_session = @Session
                    ORDER BY c.course_code";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Session", ActiveSession);
                    conn.Open();
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);
                    gvAssignments.DataSource = dt;
                    gvAssignments.DataBind();
                    pnlEmpty.Visible = (dt.Rows.Count == 0);
                }
            }
            upWorkspace.Update();
        }

        // ============================================================
        // ASSIGN / EDIT SUBMIT
        // ============================================================

        protected void BtnAssign_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int courseId = int.Parse(ddlCourse.SelectedValue);
            int lecturerId = int.Parse(ddlLecturer.SelectedValue);
            string status = ddlStatus.SelectedValue;
            int editId = int.Parse(hdnEditAssignId.Value);

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (editId > 0)
                    {
                        using (SqlCommand cmd = new SqlCommand(@"
                            UPDATE CourseAssignment_Session
                            SET course_id = @CourseId, lecturer_id = @LecturerId, assign_status = @Status
                            WHERE assign_id = @Id", conn))
                        {
                            cmd.Parameters.AddWithValue("@CourseId", courseId);
                            cmd.Parameters.AddWithValue("@LecturerId", lecturerId);
                            cmd.Parameters.AddWithValue("@Status", status);
                            cmd.Parameters.AddWithValue("@Id", editId);
                            cmd.ExecuteNonQuery();
                        }

                        ShowAlert("Updated!", "Assignment updated successfully.", "success");
                    }
                    else
                    {
                        using (SqlCommand chk = new SqlCommand(
                            "SELECT COUNT(1) FROM CourseAssignment_Session WHERE course_id = @CourseId AND academic_session = @Session", conn))
                        {
                            chk.Parameters.AddWithValue("@CourseId", courseId);
                            chk.Parameters.AddWithValue("@Session", ActiveSession);
                            if ((int)chk.ExecuteScalar() > 0)
                            {
                                ShowAlert("Duplicate", "This course already has a lecturer assigned for the selected session.", "warning");
                                return;
                            }
                        }

                        using (SqlCommand cmd = new SqlCommand(@"
                            INSERT INTO CourseAssignment_Session (course_id, lecturer_id, academic_session, assign_status)
                            VALUES (@CourseId, @LecturerId, @Session, @Status)", conn))
                        {
                            cmd.Parameters.AddWithValue("@CourseId", courseId);
                            cmd.Parameters.AddWithValue("@LecturerId", lecturerId);
                            cmd.Parameters.AddWithValue("@Session", ActiveSession);
                            cmd.Parameters.AddWithValue("@Status", status);
                            cmd.ExecuteNonQuery();
                        }

                        ShowAlert("Assigned!", "Lecturer has been assigned successfully.", "success");
                    }
                }

                ResetForm();
                LoadAssignments();
            }
            catch (SqlException ex)
            {
                ShowAlert("Database Error", HttpUtility.JavaScriptStringEncode(ex.Message), "error");
            }
        }

        // ============================================================
        // GRID ROW COMMANDS (Edit + Delete)
        // ============================================================

        protected void GvAssignments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditAssign")
            {
                int assignId = int.Parse(e.CommandArgument.ToString());

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT course_id, lecturer_id, assign_status FROM CourseAssignment_Session WHERE assign_id = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", assignId);
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            ddlCourse.SelectedValue = r["course_id"].ToString();
                            ddlLecturer.SelectedValue = r["lecturer_id"].ToString();
                            ddlStatus.SelectedValue = r["assign_status"].ToString();
                            hdnEditAssignId.Value = assignId.ToString();
                        }
                    }
                }

                btnAssign.Text = "Save Changes";
                btnCancelEdit.Visible = true;
                upWorkspace.Update();
            }
        }

        protected void BtnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
            upWorkspace.Update();
        }

        // ============================================================
        // DELETE (triggered by hidden btnDeleteConfirm after SweetAlert)
        // ============================================================

        protected void BtnDeleteAssign_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(hdnDeleteId.Value, out int assignId) || assignId <= 0) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM CourseAssignment_Session WHERE assign_id = @Id", conn))
                {
                    cmd.Parameters.AddWithValue("@Id", assignId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                hdnDeleteId.Value = "0";
                LoadAssignments();
                ShowAlert("Removed", "Assignment has been removed.", "success");
            }
            catch (SqlException ex)
            {
                ShowAlert("Error", HttpUtility.JavaScriptStringEncode(ex.Message), "error");
            }
        }

        // ============================================================
        // HELPERS
        // ============================================================

        private void ResetForm()
        {
            hdnEditAssignId.Value = "0";
            ddlCourse.SelectedIndex = 0;
            ddlLecturer.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            btnAssign.Text = "Assign Lecturer";
            btnCancelEdit.Visible = false;
        }

        private void ShowAlert(string title, string message, string icon)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "swal",
                $"Swal.fire('{title}', '{message}', '{icon}');", true);
        }
    }
}