using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace SchoolSystem
{
    public partial class StudentAttendance : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) { Response.Redirect("~/Login.aspx"); return; }

            ((StudentMaster)this.Master).PageTitle = "View Attendance";

            if (!IsPostBack) LoadAttendance();
        }

        private void LoadAttendance()
        {
            int studentId = GetStudentId();
            if (studentId == 0)
            {
                pnlTable.Visible = false;
                pnlEmpty.Visible = true;
                litCourseCount.Text = "0";
                litAvgAttendance.Text = "N/A";
                litAtRisk.Text = "0";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        c.course_code,
                        c.course_name,
                        ISNULL(cg.attended_hours, 0) AS attended_hours,
                        ISNULL(cg.total_hours, 0)    AS total_hours,
                        CASE
                            WHEN ISNULL(cg.total_hours, 0) = 0 THEN 0.0
                            ELSE ROUND(
                                CAST(cg.attended_hours AS FLOAT) /
                                CAST(cg.total_hours    AS FLOAT) * 100.0, 1)
                        END AS pct
                    FROM [Enrollment] e
                    JOIN [Course] c ON e.course_id = c.course_id
                    LEFT JOIN [CourseGrade] cg ON e.enrollment_id = cg.Enrollment_id
                    WHERE e.student_id = @sid
                      AND e.status = 'Approved'
                    ORDER BY c.course_name", conn);
                cmd.Parameters.AddWithValue("@sid", studentId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    pnlTable.Visible = false;
                    pnlEmpty.Visible = true;
                    litCourseCount.Text = "0";
                    litAvgAttendance.Text = "N/A";
                    litAtRisk.Text = "0";
                    return;
                }

                pnlTable.Visible = true;
                pnlEmpty.Visible = false;
                litCourseCount.Text = dt.Rows.Count.ToString();

                // Build rows and compute summary
                StringBuilder sb = new StringBuilder();
                int sumAttended = 0; // total attended hours across all courses
                int sumTotal = 0; // total hours across all courses
                int atRisk = 0;

                foreach (DataRow row in dt.Rows)
                {
                    string code = row["course_code"].ToString();
                    string name = row["course_name"].ToString();
                    int attended = Convert.ToInt32(row["attended_hours"]);
                    int total = Convert.ToInt32(row["total_hours"]);

                    // If no hours recorded yet → show N/A row, skip from avg & at-risk
                    if (total == 0)
                    {
                        sb.AppendFormat(@"
                        <tr>
                            <td>
                                <div style='font-weight:700;'>{0}</div>
                                <div style='font-size:12px; color:#64748b; margin-top:2px;'>{1}</div>
                            </td>
                            <td>N/A</td>
                            <td>N/A</td>
                            <td><span style='color:#64748b; font-weight:600; font-size:13px;'>N/A</span></td>
                            <td><span style='display:inline-block; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:700; background:#f1f5f9; color:#64748b;'>No Data</span></td>
                        </tr>",
                            System.Web.HttpUtility.HtmlEncode(name),
                            System.Web.HttpUtility.HtmlEncode(code));
                        continue; // skip this row from stats
                    }

                    double pct = Convert.ToDouble(row["pct"]);
                    sumAttended += attended;
                    sumTotal += total;
                    if (pct < 75) atRisk++;

                    string colour = pct >= 80 ? "#16a34a" : pct >= 75 ? "#d97706" : "#dc2626";
                    string bgCol = pct >= 80 ? "#dcfce7" : pct >= 75 ? "#fef9c3" : "#fee2e2";
                    string label = pct >= 80 ? "Good" : pct >= 75 ? "At Risk" : "Low";
                    double barW = pct > 100 ? 100 : pct;

                    sb.AppendFormat(@"
                        <tr>
                            <td>
                                <div style='font-weight:700;'>{0}</div>
                                <div style='font-size:12px; color:#64748b; margin-top:2px;'>{1}</div>
                            </td>
                            <td>{2} hrs</td>
                            <td>{3} hrs</td>
                            <td>
                                <div class='sa-bar-wrap'>
                                    <div class='sa-bar'>
                                        <div class='sa-bar-fill' style='width:{4}%; background:{5};'></div>
                                    </div>
                                    <span style='font-weight:700; font-size:13px; min-width:40px; color:{5};'>
                                        {6}%
                                    </span>
                                </div>
                            </td>
                            <td>
                                <span style='display:inline-block; padding:3px 10px; border-radius:12px; font-size:12px; font-weight:700; background:{7}; color:{5};'>
                                    {8}
                                </span>
                            </td>
                        </tr>",
                        System.Web.HttpUtility.HtmlEncode(name),
                        System.Web.HttpUtility.HtmlEncode(code),
                        attended,
                        total,
                        barW.ToString("0.0"),
                        colour,
                        pct.ToString("0.0"),
                        bgCol,
                        label);
                }

                litRows.Text = sb.ToString();

                // Avg = total attended hours / total hours (only courses with data)
                litAvgAttendance.Text = sumTotal > 0
                    ? Math.Round((double)sumAttended / sumTotal * 100, 1,
                        MidpointRounding.AwayFromZero).ToString("0.0") + "%"
                    : "N/A";
                litAtRisk.Text = atRisk.ToString();
            }
        }

        private int GetStudentId()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "SELECT student_id FROM [Student] WHERE student_email = @email", conn);
                cmd.Parameters.AddWithValue("@email", Session["UserEmail"].ToString());
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
        }
    }
}