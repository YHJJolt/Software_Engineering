using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentCourseModules : System.Web.UI.Page
    {
        // Pulled from your Dashboard logic for consistency
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int currentCourseId = 0;
        string academicSession = "";

        // THE MAGIC SWITCH! 
        // This allows you to test the sidebar correctly from the Dashboard click
        protected void Page_PreInit(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] != null || Request.QueryString["course_id"] != null)
            {
                this.MasterPageFile = "~/Student/StudentCourseMaster.Master";
            }
            else
            {
                this.MasterPageFile = "~/Student/StudentMaster.Master";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");
            // ADD THIS LINE TO OVERRIDE THE MASTER PAGE TITLE
            ((StudentCourseMaster)this.Master).PageTitle = "Modules";

            if (Request.QueryString["id"] != null)
            {
                currentCourseId = Convert.ToInt32(Request.QueryString["id"]);
                academicSession = Request.QueryString["session"] ?? "";
            }
            else
            {
                Response.Redirect("~/Student/StudentDashboard.aspx");
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
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM CourseModule WHERE course_id = @cid AND (@Session = '' OR academic_session = @Session) ORDER BY created_at ASC", con))
                {
                    cmd.Parameters.AddWithValue("@cid", currentCourseId);
                    cmd.Parameters.AddWithValue("@Session", academicSession);
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

        public string GetFileIcon(string fileName)
        {
            if (fileName.EndsWith(".pdf")) return "far fa-file-pdf text-danger";
            if (fileName.EndsWith(".pptx") || fileName.EndsWith(".ppt")) return "far fa-file-powerpoint text-warning";
            if (fileName.EndsWith(".docx") || fileName.EndsWith(".doc")) return "far fa-file-word text-primary";
            return "far fa-file text-secondary";
        }
    }
}