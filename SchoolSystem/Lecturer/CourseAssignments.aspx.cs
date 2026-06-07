using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CourseAssignments : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int currentCourseId = 2; // Default fallback

        protected void Page_Load(object sender, EventArgs e)
        {
            // ADD THIS LINE TO OVERRIDE THE MASTER PAGE TITLE
            ((LecturerCourseMaster)this.Master).PageTitle = "Assignments";

            // 1. Your exact clever Referrer fallback logic from CourseModules
            if (Request.QueryString["id"] == null && Request.UrlReferrer != null)
            {
                Uri referrerUri = Request.UrlReferrer;
                if (referrerUri.Query.Contains("id="))
                {
                    string refId = System.Web.HttpUtility.ParseQueryString(referrerUri.Query).Get("id");
                    if (!string.IsNullOrEmpty(refId))
                    {
                        Response.Redirect("~/Lecturer/CourseAssignments.aspx?id=" + refId);
                        return;
                    }
                }
            }

            // 2. Grab the ID from the URL
            if (Request.QueryString["id"] != null)
            {
                currentCourseId = Convert.ToInt32(Request.QueryString["id"]);
            }

            // 3. Normal Page Load
            if (!IsPostBack)
            {
                LoadCourseHeader();
                BindAssignments();
            }
        }

        private void LoadCourseHeader()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT course_code FROM Course WHERE course_id = @cid", con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) lblCourseBreadcrumb.Text = result.ToString();
                }
            }
        }

        // NEW SORTING EVENT HANDLER
        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAssignments();
        }

        private void BindAssignments()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // DYNAMIC SORTING QUERY
                string sortOrder = ddlSort.SelectedValue == "DESC" ? "DESC" : "ASC";
                string query = $"SELECT * FROM CourseAssignment WHERE course_id = @cid ORDER BY due_date {sortOrder}";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        pnlEmptyState.Visible = false;
                        pnlAssignments.Visible = true;
                        rptAssignments.DataSource = dt;
                        rptAssignments.DataBind();
                    }
                    else
                    {
                        pnlEmptyState.Visible = true;
                        pnlAssignments.Visible = false;
                    }
                }
            }
        }

        // ==========================================================
        // CREATE, EDIT, AND DELETE ASSIGNMENT LOGIC
        // ==========================================================

        protected void btnSaveAssignment_Click(object sender, EventArgs e)
        {
            string dbPath = null;
            if (fuAssignmentFile.HasFile)
            {
                string folderPath = Server.MapPath("~/Uploads/Assignments/");
                if (!Directory.Exists(folderPath)) { Directory.CreateDirectory(folderPath); }
                string fileName = Path.GetFileName(fuAssignmentFile.FileName);
                fuAssignmentFile.SaveAs(folderPath + fileName);
                dbPath = "~/Uploads/Assignments/" + fileName;
            }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "INSERT INTO CourseAssignment (course_id, title, description, assignment_type, due_date, max_marks, attachment_path) VALUES (@cid, @title, @desc, @type, @date, @max, @path)";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    cmd.Parameters.AddWithValue("@title", txtAssignmentTitle.Text);
                    cmd.Parameters.AddWithValue("@desc", txtAssignmentDescription.Text);
                    cmd.Parameters.AddWithValue("@type", ddlAssignmentType.SelectedValue);
                    cmd.Parameters.AddWithValue("@date", Convert.ToDateTime(txtDueDate.Text));
                    cmd.Parameters.AddWithValue("@max", Convert.ToInt32(txtMaxMarks.Text));
                    cmd.Parameters.AddWithValue("@path", (object)dbPath ?? DBNull.Value);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            txtAssignmentTitle.Text = ""; txtAssignmentDescription.Text = "";
            BindAssignments();
            CloseModals();
            ShowToast("Assignment created successfully!");
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string assignmentId = btn.CommandArgument;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM CourseAssignment WHERE assignment_id = @aid", con))
                {
                    cmd.Parameters.AddWithValue("@aid", assignmentId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfEditAssignmentId.Value = assignmentId;
                            txtEditTitle.Text = reader["title"].ToString();
                            txtEditDescription.Text = reader["description"].ToString();
                            ddlEditType.SelectedValue = reader["assignment_type"].ToString();
                            txtEditMaxMarks.Text = reader["max_marks"].ToString();

                            // Parse DateTime specifically for the HTML5 input
                            if (reader["due_date"] != DBNull.Value)
                            {
                                DateTime dt = Convert.ToDateTime(reader["due_date"]);
                                txtEditDueDate.Text = dt.ToString("yyyy-MM-ddTHH:mm");
                            }
                        }
                    }
                }
            }

            string script = "setTimeout(function() { var m = new bootstrap.Modal(document.getElementById('editAssignmentModal')); m.show(); }, 100);";
            ScriptManager.RegisterStartupScript(upnlAssignments, upnlAssignments.GetType(), "PopEdit", script, true);
        }

        protected void btnUpdateAssignment_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "UPDATE CourseAssignment SET title = @title, description = @desc, assignment_type = @type, max_marks = @max, due_date = @date WHERE assignment_id = @aid";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@title", txtEditTitle.Text);
                    cmd.Parameters.AddWithValue("@desc", txtEditDescription.Text);
                    cmd.Parameters.AddWithValue("@type", ddlEditType.SelectedValue);
                    cmd.Parameters.AddWithValue("@max", Convert.ToInt32(txtEditMaxMarks.Text));
                    cmd.Parameters.AddWithValue("@date", Convert.ToDateTime(txtEditDueDate.Text));
                    cmd.Parameters.AddWithValue("@aid", hfEditAssignmentId.Value);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            BindAssignments();
            CloseModals();
            ShowToast("Assignment updated successfully!");
        }

        protected void btnConfirmDeleteAssignment_Click(object sender, EventArgs e)
        {
            string assignmentId = hfDeleteAssignmentId.Value;
            if (!string.IsNullOrEmpty(assignmentId))
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    // 1. Delete Student Submissions First (Foreign Key)
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM AssignmentSubmission WHERE assignment_id = @aid", con))
                    {
                        cmd.Parameters.AddWithValue("@aid", assignmentId);
                        cmd.ExecuteNonQuery();
                    }
                    // 2. Delete Assignment
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM CourseAssignment WHERE assignment_id = @aid", con))
                    {
                        cmd.Parameters.AddWithValue("@aid", assignmentId);
                        cmd.ExecuteNonQuery();
                    }
                }
                BindAssignments();
                CloseModals();
                ShowToast("Assignment and all submissions deleted.");
            }
        }

        // ==========================================================
        // GRADING DASHBOARD LOGIC
        // ==========================================================

        protected void btnGrade_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            hfGradingAssignmentId.Value = btn.CommandArgument;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = @"
            SELECT DISTINCT s.student_id, s.student_code, s.student_name, 
                   sub.submission_file, sub.submitted_at, sub.marks_awarded, sub.feedback, sub.is_published,
                   ca.due_date
            FROM Enrollment e
            JOIN Student s ON e.student_id = s.student_id
            JOIN CourseAssignment ca ON ca.assignment_id = @aid
            LEFT JOIN AssignmentSubmission sub ON s.student_id = sub.student_id AND sub.assignment_id = @aid
            WHERE e.course_id = @cid 
              AND e.status = 'Approved'
              AND e.enrolled_semester = s.student_sem"; // <--- THIS FILTERS OUT OLD STUDENTS

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@aid", hfGradingAssignmentId.Value);
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvGrades.DataSource = dt;
                    gvGrades.DataBind();
                }
            }
            ScriptManager.RegisterStartupScript(upnlGradeModal, upnlGradeModal.GetType(), "OpenGrid", "openGradingDashboard();", true);
        }

        protected void btnSaveGrades_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();
                foreach (GridViewRow row in gvGrades.Rows)
                {
                    HiddenField hfStudent = (HiddenField)row.FindControl("hfStudentId");
                    TextBox txtMarks = (TextBox)row.FindControl("txtMarks");
                    TextBox txtFeedback = (TextBox)row.FindControl("txtFeedback");
                    CheckBox chkPublished = (CheckBox)row.FindControl("chkPublished");

                    if (!string.IsNullOrEmpty(txtMarks.Text))
                    {
                        string query = @"
                            MERGE AssignmentSubmission AS target
                            USING (SELECT @aid AS assignment_id, @sid AS student_id) AS source
                            ON (target.assignment_id = source.assignment_id AND target.student_id = source.student_id)
                            WHEN MATCHED THEN 
                                UPDATE SET marks_awarded = @marks, feedback = @feed, is_published = @pub, graded_date = GETDATE()
                            WHEN NOT MATCHED THEN
                                INSERT (assignment_id, student_id, marks_awarded, feedback, is_published, graded_date)
                                VALUES (@aid, @sid, @marks, @feed, @pub, GETDATE());";

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@aid", hfGradingAssignmentId.Value);
                            cmd.Parameters.AddWithValue("@sid", hfStudent.Value);
                            cmd.Parameters.AddWithValue("@marks", Convert.ToDecimal(txtMarks.Text));
                            cmd.Parameters.AddWithValue("@feed", txtFeedback.Text);
                            cmd.Parameters.AddWithValue("@pub", chkPublished.Checked);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            ScriptManager.RegisterStartupScript(upnlGradeModal, upnlGradeModal.GetType(), "CloseGrid", "closeGradingDashboard();", true);
            ShowToast("Marks saved and published successfully!");
        }

        // ==========================================================
        // DYNAMIC UI GENERATORS & HELPERS
        // ==========================================================

        public string GetBadgeClass(string type)
        {
            if (type == "Midterm") return "bg-warning text-dark";
            if (type == "Final") return "bg-danger text-white";
            return "bg-info text-dark"; // Coursework
        }

        public string GetGuidelineLink(object filePath, object title)
        {
            if (filePath == DBNull.Value || filePath == null) return "";
            string url = ResolveUrl(filePath.ToString());
            string safeTitle = title.ToString().Replace("\"", "\\\"").Replace("'", "\\'");
            return $"<a href='javascript:void(0);' onclick='openCustomPreview(\"{url}\", \"{safeTitle} - Guidelines\")' class='small mt-2 d-block text-primary text-decoration-none fw-bold'><i class='fas fa-search me-1'></i> Preview Guidelines</a>";
        }

        public string GetSubmissionStatus(object submittedAt, object dueDate)
        {
            if (submittedAt == DBNull.Value || submittedAt == null) return "<span class='badge bg-danger rounded-pill'>Missing</span>";
            DateTime subDate = Convert.ToDateTime(submittedAt);
            DateTime due = Convert.ToDateTime(dueDate);
            if (subDate > due) return "<span class='badge bg-warning text-dark rounded-pill'>Late</span>";
            return "<span class='badge bg-success rounded-pill'>On Time</span>";
        }

        public string GetFileLink(object filePath, object studentName)
        {
            if (filePath == DBNull.Value || filePath == null) return "<span class='text-muted fst-italic'>No File Uploaded</span>";
            string url = ResolveUrl(filePath.ToString());
            string title = studentName.ToString() + " - Submission";
            return $"<a href='javascript:void(0);' onclick='openCustomPreview(\"{url}\", \"{title}\")' class='text-primary fw-bold text-decoration-none'><i class='fas fa-search me-1'></i> View File</a>";
        }

        private void CloseModals()
        {
            string cleanupScript = @"
                var backdrops = document.querySelectorAll('.modal-backdrop');
                backdrops.forEach(function(b) { b.remove(); });
                document.body.classList.remove('modal-open');
                document.body.style.overflow = 'auto';
                document.body.style.paddingRight = '';
                var openModals = document.querySelectorAll('.modal.show');
                openModals.forEach(function(m) { var instance = bootstrap.Modal.getInstance(m); if(instance) instance.hide(); });
            ";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ModalCleanup", cleanupScript, true);
        }

        private void ShowToast(string message)
        {
            string script = $@"
                document.getElementById('toastMessage').innerText = '{message}';
                var toastElList = [].slice.call(document.querySelectorAll('.toast'));
                var toastList = toastElList.map(function(toastEl) {{ return new bootstrap.Toast(toastEl, {{ delay: 3000 }}); }});
                toastList.forEach(toast => toast.show());
            ";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ToastScript", script, true);
        }
    }
}