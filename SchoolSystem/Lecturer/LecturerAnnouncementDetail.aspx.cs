using System;
using System.Configuration;
using System.Data.SqlClient;

namespace SchoolSystem
{
    public partial class LecturerAnnouncementDetail : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LecturerCourseMaster master = (LecturerCourseMaster)this.Master;
                master.PageTitle = "Announcement Detail";

                string aid = Request.QueryString["id"];
                if (string.IsNullOrEmpty(aid)) { Response.Redirect("~/Lecturer/LecturerAnnouncement.aspx"); return; }

                LoadAnnouncement(aid);
            }
        }

        private void LoadAnnouncement(string aid)
        {
            string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"SELECT a.title, a.content, a.category, a.created_at, l.lecturer_name
                               FROM Announcement a
                               JOIN Lecturer l ON a.Lecturer_id = l.lecturer_id
                               WHERE a.announcement_id = @id";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@id", aid);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    string category = dr["category"].ToString();
                    DateTime dt = Convert.ToDateTime(dr["created_at"]);

                    lblTitle.InnerText = dr["title"].ToString();
                    lblContent.InnerText = dr["content"].ToString();
                    lblLecturerName.Text = dr["lecturer_name"].ToString();
                    lblDate.Text = dt.ToString("dd MMM yyyy");
                    lblTime.Text = dt.ToString("hh:mm tt");

                    // category badge with colour
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
                    Response.Redirect("~/Lecturer/LecturerAnnouncement.aspx");
                }
            }
        }
    }
}