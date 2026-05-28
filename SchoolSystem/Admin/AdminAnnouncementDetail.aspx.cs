using System;
using System.Configuration;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class AdminAnnouncementDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string aid = Request.QueryString["id"];
                if (string.IsNullOrEmpty(aid)) { Response.Redirect("~/Admin/AdminAnnouncement.aspx"); return; }
                LoadAnnouncement(aid);
            }
        }

        private void LoadAnnouncement(string aid)
        {
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT a.title, a.content, a.category, a.created_at,
                                      ISNULL(l.lecturer_name, '') as lecturer_name,
                                      a.admin_id
                               FROM Announcement a
                               LEFT JOIN Lecturer l ON a.Lecturer_id = l.lecturer_id
                               WHERE a.announcement_id = @id";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", aid);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    string category = dr["category"].ToString();
                    DateTime dt = Convert.ToDateTime(dr["created_at"]);
                    string lecturerName = dr["lecturer_name"].ToString();
                    string adminId = dr["admin_id"].ToString();

                    lblTitle.InnerText = dr["title"].ToString();
                    lblContent.InnerText = dr["content"].ToString();
                    lblDate.Text = dt.ToString("dd MMM yyyy");
                    lblTime.Text = dt.ToString("hh:mm tt");

                    lblPostedBy.Text = !string.IsNullOrEmpty(lecturerName) ? lecturerName : "Admin";

                    string colour;
                    if (category == "Academic")
                        colour = "background:#fce8e6;color:#d93025;";
                    else if (category == "Finance")
                        colour = "background:#e6ffed;color:#1e8e3e;";
                    else if (category == "Co-curriculum")
                        colour = "background:#f3e8fd;color:#9334e6;";
                    else
                        colour = "background:#e8f0fe;color:#1967d2;";

                    lblCategory.Style.Value = colour;
                    lblCategory.InnerText = category;
                }
                else
                {
                    Response.Redirect("~/Admin/AdminAnnouncement.aspx");
                }
            }
        }
    }
}