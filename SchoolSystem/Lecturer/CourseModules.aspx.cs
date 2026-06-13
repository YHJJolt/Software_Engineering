using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class CourseModules : System.Web.UI.Page
    {
        string connStr = "Data Source=(localdb)\\MSSQLLocalDB;Initial Catalog=SchoolSystemDB;Integrated Security=True";
        int currentCourseId = 2; // Default fallback

        protected void Page_Load(object sender, EventArgs e)
        {
            // ADD THIS LINE TO OVERRIDE THE MASTER PAGE TITLE
            ((LecturerCourseMaster)this.Master).PageTitle = "Modules";
            if (Request.QueryString["id"] == null && Request.UrlReferrer != null)
            {
                Uri referrerUri = Request.UrlReferrer;
                if (referrerUri.Query.Contains("id="))
                {
                    string refId = System.Web.HttpUtility.ParseQueryString(referrerUri.Query).Get("id");
                    if (!string.IsNullOrEmpty(refId))
                    {
                        Response.Redirect("~/Lecturer/CourseModules.aspx?id=" + refId);
                        return;
                    }
                }
            }

            if (Request.QueryString["id"] != null)
            {
                currentCourseId = Convert.ToInt32(Request.QueryString["id"]);
            }

            if (!IsPostBack)
            {
                LoadCourseHeader();
                BindModules();
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

        private void BindModules()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM CourseModule WHERE course_id = @cid ORDER BY created_at ASC", con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        pnlEmptyState.Visible = false;
                        pnlModules.Visible = true;
                        rptModules.DataSource = dt;
                        rptModules.DataBind();
                    }
                    else
                    {
                        pnlEmptyState.Visible = true;
                        pnlModules.Visible = false;
                    }
                }
            }
        }

        protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                int moduleId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "module_id"));
                Repeater rptFiles = (Repeater)e.Item.FindControl("rptFiles");

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT * FROM ModuleFile WHERE module_id = @mid", con))
                    {
                        cmd.Parameters.AddWithValue("@mid", moduleId);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptFiles.DataSource = dt;
                        rptFiles.DataBind();
                    }
                }
            }
        }

        protected void btnAddModule_Click(object sender, EventArgs e)
        {
            string moduleName = txtModuleName.Text.Trim();
            string currentSession = GetCurrentSession();
            if (string.IsNullOrEmpty(moduleName)) { CloseModalAndCleanup(); ShowToast("Module name cannot be empty.", "error"); return; }
            if (ModuleNameExists(moduleName, currentSession))
            { CloseModalAndCleanup(); ShowToast("A module named '" + moduleName + "' already exists for this course this session.", "error"); return; }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("INSERT INTO CourseModule (course_id, module_name, module_description, academic_session) VALUES (@cid, @name, @desc, @session)", con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    cmd.Parameters.AddWithValue("@name", txtModuleName.Text);
                    cmd.Parameters.AddWithValue("@desc", txtModuleDescription.Text);
                    cmd.Parameters.AddWithValue("@session", currentSession);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            txtModuleName.Text = ""; txtModuleDescription.Text = "";
            BindModules();
            CloseModalAndCleanup();
            ShowToast("Module created successfully!");
        }

        protected void btnEditModule_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string moduleId = btn.CommandArgument;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT module_name, module_description FROM CourseModule WHERE module_id = @mid", con))
                {
                    cmd.Parameters.AddWithValue("@mid", moduleId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfEditModuleId.Value = moduleId;
                            txtEditModuleName.Text = reader["module_name"].ToString();
                            txtEditModuleDescription.Text = reader["module_description"].ToString();
                        }
                    }
                }
            }

            string script = @"
                setTimeout(function() {
                    var modalElement = document.getElementById('editModuleModal');
                    if (modalElement) {
                        var editModal = bootstrap.Modal.getOrCreateInstance(modalElement);
                        editModal.show();
                    }
                }, 100);
            ";
            ScriptManager.RegisterStartupScript(upnlModules, upnlModules.GetType(), "PopEdit", script, true);
        }

        protected void btnUpdateModule_Click(object sender, EventArgs e)
        {
            string moduleName = txtModuleName.Text.Trim();
            string currentSession = GetCurrentSession();
            if (string.IsNullOrEmpty(moduleName)) { CloseModalAndCleanup(); ShowToast("Module name cannot be empty."); return; }
            if (ModuleNameExists(moduleName, currentSession))
            { CloseModalAndCleanup(); ShowToast("A module named '" + moduleName + "' already exists for this course this session."); return; }

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("UPDATE CourseModule SET module_name = @name, module_description = @desc WHERE module_id = @mid", con))
                {
                    cmd.Parameters.AddWithValue("@name", txtEditModuleName.Text);
                    cmd.Parameters.AddWithValue("@desc", txtEditModuleDescription.Text);
                    cmd.Parameters.AddWithValue("@mid", hfEditModuleId.Value);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            BindModules();
            CloseModalAndCleanup();
            ShowToast("Module updated successfully!");
        }

        // NEW DELETE MODULE FUNCTION
        // BEAUTIFUL MODAL DELETE FUNCTION
        protected void btnConfirmDeleteModule_Click(object sender, EventArgs e)
        {
            // Grab the ID from the Hidden Field that Javascript populated
            string moduleId = hfDeleteModuleId.Value;

            if (!string.IsNullOrEmpty(moduleId))
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();

                    // 1. Delete all attached files first
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ModuleFile WHERE module_id = @mid", con))
                    {
                        cmd.Parameters.AddWithValue("@mid", moduleId);
                        cmd.ExecuteNonQuery();
                    }

                    // 2. Delete the module container
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM CourseModule WHERE module_id = @mid", con))
                    {
                        cmd.Parameters.AddWithValue("@mid", moduleId);
                        cmd.ExecuteNonQuery();
                    }
                }

                BindModules();
                CloseModalAndCleanup(); // This clears the dark background!
                ShowToast("Module deleted successfully!");
            }
        }

        protected void btnUploadFile_Click(object sender, EventArgs e)
        {
            // A module must be selected (safety)
            if (string.IsNullOrEmpty(hfSelectedModuleId.Value))
            { CloseModalAndCleanup(); ShowToast("No module selected.", "error"); return; }

            // File is required
            if (!fuModuleFile.HasFile)
            { CloseModalAndCleanup(); ShowToast("Please select a file to upload.", "error"); return; }

            // File title is required
            string fileTitle = txtFileTitle.Text.Trim();
            if (string.IsNullOrEmpty(fileTitle))
            { CloseModalAndCleanup(); ShowToast("File title cannot be empty.", "error"); return; }

            // File type check
            string ext = Path.GetExtension(fuModuleFile.FileName).ToLowerInvariant();
            string[] allowedDocs = { ".pdf", ".docx", ".pptx", ".zip" };
            if (Array.IndexOf(allowedDocs, ext) < 0)
            { CloseModalAndCleanup(); ShowToast("Only .pdf, .docx, .pptx, or .zip files are allowed.", "error"); return; }

            string folderPath = Server.MapPath("~/Uploads/Modules/");
            if (!Directory.Exists(folderPath)) { Directory.CreateDirectory(folderPath); }

            string fileName = Path.GetFileName(fuModuleFile.FileName);
            string savePath = folderPath + fileName;
            string dbPath = "~/Uploads/Modules/" + fileName;

            fuModuleFile.SaveAs(savePath);

            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("INSERT INTO ModuleFile (module_id, file_title, file_description, file_name, file_path) VALUES (@mid, @title, @desc, @fname, @path)", con))
                {
                    cmd.Parameters.AddWithValue("@mid", hfSelectedModuleId.Value);
                    cmd.Parameters.AddWithValue("@title", fileTitle);
                    cmd.Parameters.AddWithValue("@desc", txtFileDescription.Text);
                    cmd.Parameters.AddWithValue("@fname", fileName);
                    cmd.Parameters.AddWithValue("@path", dbPath);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            txtFileTitle.Text = ""; txtFileDescription.Text = "";
            BindModules();
            CloseModalAndCleanup();
            ShowToast("Content uploaded successfully!");
        }

        // BEAUTIFUL MODAL DELETE FILE FUNCTION
        protected void btnConfirmDeleteFile_Click(object sender, EventArgs e)
        {
            // Grab the ID from the Hidden Field that Javascript populated
            string fileId = hfDeleteFileId.Value;

            if (!string.IsNullOrEmpty(fileId))
            {
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM ModuleFile WHERE file_id = @fid", con))
                    {
                        cmd.Parameters.AddWithValue("@fid", fileId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                BindModules();
                CloseModalAndCleanup(); // Clears the dark background!
                ShowToast("File deleted successfully!");
            }
        }

        private void CloseModalAndCleanup()
        {
            string cleanupScript = @"
                var backdrops = document.querySelectorAll('.modal-backdrop');
                backdrops.forEach(function(b) { b.remove(); });
                document.body.classList.remove('modal-open');
                document.body.style.overflow = 'auto';
                document.body.style.paddingRight = '';
                
                var openModals = document.querySelectorAll('.modal.show');
                openModals.forEach(function(m) { 
                    var instance = bootstrap.Modal.getInstance(m);
                    if(instance) instance.hide();
                });
            ";
            ScriptManager.RegisterStartupScript(upnlModules, upnlModules.GetType(), "ModalCleanup", cleanupScript, true);
        }

        private void ShowToast(string message, string type = "success")
        {
            string safe = System.Web.HttpUtility.JavaScriptStringEncode(message);
            bool isError = type == "error";
            string bgClass = isError ? "bg-danger" : "bg-success";
            string iconClass = isError ? "fas fa-times-circle me-2" : "fas fa-check-circle me-2";

            string script = $@"
                var toastEl = document.getElementById('successToast');
                toastEl.classList.remove('bg-success', 'bg-danger');
                toastEl.classList.add('{bgClass}');
                document.getElementById('toastIcon').className = '{iconClass}';
                document.getElementById('toastMessage').innerText = '{safe}';
                var t = bootstrap.Toast.getOrCreateInstance(toastEl, {{ delay: 3000 }});
                t.show();
            ";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ToastScript", script, true);
        }

        public string GetFileIcon(string fileName)
        {
            if (fileName.EndsWith(".pdf")) return "far fa-file-pdf text-danger";
            if (fileName.EndsWith(".pptx") || fileName.EndsWith(".ppt")) return "far fa-file-powerpoint text-warning";
            if (fileName.EndsWith(".docx") || fileName.EndsWith(".doc")) return "far fa-file-word text-primary";
            return "far fa-file text-secondary";
        }

        private bool ModuleNameExists(string name, string session, int excludeId = 0)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM CourseModule WHERE course_id = @cid AND module_name = @name AND academic_session = @session AND module_id <> @id", con))
            {
                cmd.Parameters.AddWithValue("@cid", currentCourseId);
                cmd.Parameters.AddWithValue("@name", name);
                cmd.Parameters.AddWithValue("@session", session);
                cmd.Parameters.AddWithValue("@id", excludeId);
                con.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        private string GetCurrentSession()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session'", con))
            {
                con.Open();
                return cmd.ExecuteScalar()?.ToString() ?? "JAN2026";
            }
        }
    }
}