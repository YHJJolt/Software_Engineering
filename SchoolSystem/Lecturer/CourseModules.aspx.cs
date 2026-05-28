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
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("INSERT INTO CourseModule (course_id, module_name, module_description) VALUES (@cid, @name, @desc)", con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    cmd.Parameters.AddWithValue("@name", txtModuleName.Text);
                    cmd.Parameters.AddWithValue("@desc", txtModuleDescription.Text);
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
            if (fuModuleFile.HasFile && !string.IsNullOrEmpty(hfSelectedModuleId.Value))
            {
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
                        cmd.Parameters.AddWithValue("@title", txtFileTitle.Text);
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

        private void ShowToast(string message)
        {
            string script = $@"
                document.getElementById('toastMessage').innerText = '{message}';
                var toastElList = [].slice.call(document.querySelectorAll('.toast'));
                var toastList = toastElList.map(function(toastEl) {{
                    return new bootstrap.Toast(toastEl, {{ delay: 3000 }});
                }});
                toastList.forEach(toast => toast.show());
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
    }
}