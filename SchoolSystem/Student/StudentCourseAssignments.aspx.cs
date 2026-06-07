using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentCourseAssignments : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int currentCourseId = 0;
        int currentStudentId = 0;

        protected void Page_PreInit(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] != null || Request.QueryString["course_id"] != null)
                this.MasterPageFile = "~/Student/StudentCourseMaster.Master";
            else
                this.MasterPageFile = "~/Student/StudentMaster.Master";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");
            
            // ADD THIS LINE TO OVERRIDE THE MASTER PAGE TITLE
            ((StudentCourseMaster)this.Master).PageTitle = "Assignments";
            currentStudentId = GetStudentId();

            if (Request.QueryString["id"] != null)
            {
                currentCourseId = Convert.ToInt32(Request.QueryString["id"]);
            }
            else
            {
                Response.Redirect("~/Student/StudentDashboard.aspx");
            }

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

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAssignments();
        }

        private void BindAssignments()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string sortOrder = ddlSort.SelectedValue == "DESC" ? "DESC" : "ASC";

                // Magic Query: Grabs the assignment AND the student's submission status in one go
                string query = $@"
                    SELECT ca.*, 
                           sub.submission_file, sub.submitted_at, sub.marks_awarded, sub.feedback, sub.is_published
                    FROM CourseAssignment ca
                    LEFT JOIN AssignmentSubmission sub ON ca.assignment_id = sub.assignment_id AND sub.student_id = @sid
                    WHERE ca.course_id = @cid 
                    ORDER BY ca.due_date {sortOrder}";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
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

        // Logic for styling the cards dynamically based on the student's progress
        protected void rptAssignments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                DateTime dueDate = Convert.ToDateTime(row["due_date"]);

                Label lblStatusBadge = (Label)e.Item.FindControl("lblStatusBadge");
                Button btnOpenSubmit = (Button)e.Item.FindControl("btnOpenSubmit");
                Panel pnlGradeInfo = (Panel)e.Item.FindControl("pnlGradeInfo");
                Literal litScore = (Literal)e.Item.FindControl("litScore");
                Panel pnlFeedback = (Panel)e.Item.FindControl("pnlFeedback");
                Literal litFeedback = (Literal)e.Item.FindControl("litFeedback");

                string assignmentId = row["assignment_id"].ToString();
                string safeTitle = row["title"].ToString().Replace("'", "\\'").Replace("\"", "&quot;").Replace("\r", "").Replace("\n", "");
                btnOpenSubmit.OnClientClick = $"openSubmitModal({assignmentId}, '{safeTitle}'); return false;";

                // If submitted_at is not null, they submitted it
                if (row["submitted_at"] != DBNull.Value)
                {
                    // Check if the lecturer has graded AND published it
                    bool isGraded = row["marks_awarded"] != DBNull.Value;

                    if (isGraded)
                    {
                        lblStatusBadge.Text = "<i class='fas fa-check-circle me-1'></i> Graded";
                        lblStatusBadge.CssClass = "badge bg-success rounded-pill fs-6 px-3 py-2";

                        pnlGradeInfo.Visible = true;
                        litScore.Text = row["marks_awarded"].ToString();

                        if (row["feedback"] != DBNull.Value && !string.IsNullOrWhiteSpace(row["feedback"].ToString()))
                        {
                            pnlFeedback.Visible = true;
                            litFeedback.Text = row["feedback"].ToString();
                        }

                        // Once graded, they usually cannot resubmit
                        btnOpenSubmit.Visible = false;
                    }
                    else
                    {
                        lblStatusBadge.Text = "<i class='fas fa-paper-plane me-1'></i> Submitted";
                        lblStatusBadge.CssClass = "badge bg-primary rounded-pill fs-6 px-3 py-2";
                        btnOpenSubmit.Text = "Update Submission";
                        btnOpenSubmit.CssClass = "btn btn-outline-primary fw-bold";
                    }
                }
                else
                {
                    // Not submitted yet
                    if (DateTime.Now > dueDate)
                    {
                        lblStatusBadge.Text = "<i class='fas fa-exclamation-circle me-1'></i> Missing";
                        lblStatusBadge.CssClass = "badge bg-danger rounded-pill fs-6 px-3 py-2";
                        btnOpenSubmit.Text = "Submit Late";
                        btnOpenSubmit.CssClass = "btn btn-warning fw-bold";
                    }
                    else
                    {
                        lblStatusBadge.Text = "Pending";
                        lblStatusBadge.CssClass = "badge bg-secondary rounded-pill fs-6 px-3 py-2";
                    }
                }
            }
        }

        protected void btnSubmitWork_Click(object sender, EventArgs e)
        {
            if (fuSubmission.HasFile && !string.IsNullOrEmpty(hfSelectedAssignmentId.Value))
            {
                string folderPath = Server.MapPath("~/Uploads/Submissions/");
                if (!Directory.Exists(folderPath)) { Directory.CreateDirectory(folderPath); }

                // Attach Student ID to filename to prevent them from overwriting each other!
                string fileName = currentStudentId + "_" + Path.GetFileName(fuSubmission.FileName);
                string savePath = folderPath + fileName;
                string dbPath = "~/Uploads/Submissions/" + fileName;

                fuSubmission.SaveAs(savePath);

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    // If they already submitted, update the file. Otherwise, insert a new record.
                    string sql = @"
                            -- The Safety Check: Make sure the lecturer hasn't deleted this assignment!
                            IF EXISTS (SELECT 1 FROM CourseAssignment WHERE assignment_id = @aid)
                            BEGIN
                                -- If the assignment exists, proceed normally:
                                IF EXISTS (SELECT 1 FROM AssignmentSubmission WHERE assignment_id = @aid AND student_id = @sid)
                                    UPDATE AssignmentSubmission 
                                    SET submission_file = @file, submitted_at = GETDATE() 
                                    WHERE assignment_id = @aid AND student_id = @sid
                                ELSE
                                    INSERT INTO AssignmentSubmission (assignment_id, student_id, submission_file, submitted_at, is_published) 
                                    VALUES (@aid, @sid, @file, GETDATE(), 0)
                            END";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@aid", hfSelectedAssignmentId.Value);
                        cmd.Parameters.AddWithValue("@sid", currentStudentId);
                        cmd.Parameters.AddWithValue("@file", dbPath);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                BindAssignments();

                // Force close the modal
                ScriptManager.RegisterStartupScript(upnlAssignments, upnlAssignments.GetType(), "CloseModal", "$('.modal').modal('hide'); $('.modal-backdrop').remove();", true);
                ShowToast("Assignment submitted successfully!");
            }
        }

        private int GetStudentId()
        {
            if (Session["StudentID"] != null) return Convert.ToInt32(Session["StudentID"]);

            // Fallback query if Session["StudentID"] gets wiped
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT student_id FROM Student WHERE student_email = @email", con))
                {
                    cmd.Parameters.AddWithValue("@email", Session["UserEmail"].ToString());
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) return Convert.ToInt32(result);
                }
            }
            return 0;
        }

        public string GetBadgeClass(string type)
        {
            if (type == "Midterm") return "bg-warning text-dark";
            if (type == "Final") return "bg-danger text-white";
            return "bg-info text-dark";
        }

        public string GetGuidelineLink(object filePath, object title)
        {
            if (filePath == DBNull.Value || filePath == null || string.IsNullOrEmpty(filePath.ToString())) return "";
            string url = ResolveUrl(filePath.ToString());
            string safeTitle = title.ToString().Replace("\"", "\\\"").Replace("'", "\\'");
            return $"<a href='javascript:void(0);' onclick='openCustomPreview(\"{url}\", \"{safeTitle} - Guidelines\")' class='btn btn-outline-info btn-sm fw-bold'><i class='fas fa-file-pdf me-1'></i> View Guidelines</a>";
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