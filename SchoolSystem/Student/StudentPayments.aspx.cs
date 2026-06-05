using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class StudentPayments : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;
        int currentStudentId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserEmail"] == null) Response.Redirect("~/Login.aspx");

            currentStudentId = GetStudentId();

            if (!IsPostBack)
            {
                LoadStudentPayments();
            }
        }

        private void LoadStudentPayments()
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Grab all payments for this specific student
                string sql = "SELECT * FROM Payment WHERE student_id = @sid ORDER BY payment_duedate DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", currentStudentId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptInvoices.DataSource = dt;
                        rptInvoices.DataBind();
                        pnlNoInvoices.Visible = false;

                        // Calculate total pending amount
                        decimal totalPending = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            if (row["payment_paydate"] == DBNull.Value)
                            {
                                totalPending += Convert.ToDecimal(row["payment_amount"]);
                            }
                        }
                        litPendingBalance.Text = totalPending.ToString("N2");
                    }
                    else
                    {
                        pnlNoInvoices.Visible = true;
                    }
                }
            }
        }

        protected void rptInvoices_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                Label lblStatus = (Label)e.Item.FindControl("lblStatus");
                Button btnAction = (Button)e.Item.FindControl("btnAction");

                // 1. Find the nested repeater we just added to the HTML
                Repeater rptCourseBreakdown = (Repeater)e.Item.FindControl("rptCourseBreakdown");

                // 2. Fetch and bind the real courses for this student
                if (rptCourseBreakdown != null)
                {
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        // This query finds all approved courses the student is taking
                        string subSql = @"
                            SELECT c.course_code, c.course_name, pd.course_fee
                            FROM PaymentDetail pd
                            INNER JOIN Enrollment e ON pd.enrollment_id = e.enrollment_id
                            INNER JOIN Course c ON e.course_id = c.course_id
                            WHERE pd.payment_id = @pid";

                        using (SqlCommand subCmd = new SqlCommand(subSql, con))
                        {
                            // Grab the payment ID from the current row
                            subCmd.Parameters.AddWithValue("@pid", row["payment_id"]);
                            SqlDataAdapter subDa = new SqlDataAdapter(subCmd);
                            DataTable subDt = new DataTable();
                            subDa.Fill(subDt);

                            rptCourseBreakdown.DataSource = subDt;
                            rptCourseBreakdown.DataBind();
                        }
                    }
                }

                // 3. Keep your existing status badge & button logic intact
                if (row["payment_paydate"] == DBNull.Value)
                {
                    lblStatus.Text = "<span class='sp-badge sp-badge-danger'>Unpaid</span>";
                    btnAction.Text = "Pay Now";
                    btnAction.CssClass = "sp-btn sp-btn-primary";
                    btnAction.CommandName = "Pay";
                    btnAction.CommandArgument = row["payment_id"].ToString() + "|" + row["payment_amount"].ToString();
                }
                else
                {
                    lblStatus.Text = "<span class='sp-badge sp-badge-success'>Paid</span>";
                    btnAction.Text = "View Receipt";
                    btnAction.CssClass = "sp-btn sp-btn-outline";
                    btnAction.CommandName = "Receipt";
                    btnAction.CommandArgument = row["payment_id"].ToString();
                }
            }
        }

        protected void rptInvoices_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Pay")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                hfPayInvoiceId.Value = args[0];
                litPayAmount.Text = Convert.ToDecimal(args[1]).ToString("N2");
                ddlPaymentMethod.SelectedIndex = 0; // Reset dropdown

                ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenModal", "openPaymentModal();", true);
            }
            else if (e.CommandName == "Receipt")
            {
                GenerateReceipt(Convert.ToInt32(e.CommandArgument));
            }
        }

        protected void btnConfirmPayment_Click(object sender, EventArgs e)
        {
            int invoiceId = Convert.ToInt32(hfPayInvoiceId.Value);
            string method = ddlPaymentMethod.SelectedValue;

            using (SqlConnection con = new SqlConnection(connStr))
            {
                // Update the admin's Payment table instantly!
                string sql = "UPDATE Payment SET payment_paydate = GETDATE(), payment_method = @method WHERE payment_id = @id";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@method", method);
                    cmd.Parameters.AddWithValue("@id", invoiceId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Refresh the dashboard data
            LoadStudentPayments();

            // Close Payment Modal, Show Success Alert, THEN open Receipt
            string script = $@"
                closePaymentModal();
                Swal.fire({{
                    title: 'Payment Successful!',
                    text: 'Your payment has been processed.',
                    icon: 'success',
                    timer: 2000,
                    showConfirmButton: false
                }}).then(() => {{
                    __doPostBack('receiptTrigger', '{invoiceId}');
                }});
            ";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "PaymentSuccess", script, true);
        }

        // Trick to catch the javascript trigger and open the receipt automatically after payment
        protected override void RaisePostBackEvent(IPostBackEventHandler sourceControl, string eventArgument)
        {
            base.RaisePostBackEvent(sourceControl, eventArgument);
            if (Request["__EVENTTARGET"] == "receiptTrigger")
            {
                GenerateReceipt(Convert.ToInt32(Request["__EVENTARGUMENT"]));
            }
        }

        private void GenerateReceipt(int invoiceId)
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open(); // Open connection once for both queries

                // 1. Fetch Main Receipt Details
                string sql = @"
            SELECT p.*, s.student_name 
            FROM Payment p 
            JOIN Student s ON p.student_id = s.student_id 
            WHERE p.payment_id = @id";

                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@id", invoiceId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litReceiptNo.Text = "INV-" + reader["payment_id"].ToString().PadLeft(5, '0');
                            litReceiptDate.Text = Convert.ToDateTime(reader["payment_paydate"]).ToString("dd MMM yyyy, hh:mm tt");
                            litReceiptStudent.Text = reader["student_name"].ToString().ToUpper();
                            litReceiptMethod.Text = reader["payment_method"].ToString();
                            litReceiptAmount.Text = Convert.ToDecimal(reader["payment_amount"]).ToString("N2");
                        }
                    } // The reader must be closed before running the next query!
                }

                // 2. Fetch the Course Breakdown for the Receipt
                string subSql = @"
                    SELECT c.course_code, c.course_name, pd.course_fee
                    FROM PaymentDetail pd
                    INNER JOIN Enrollment e ON pd.enrollment_id = e.enrollment_id
                    INNER JOIN Course c ON e.course_id = c.course_id
                    WHERE pd.payment_id = @pid";

                using (SqlCommand subCmd = new SqlCommand(subSql, con))
                {
                    subCmd.Parameters.AddWithValue("@pid", invoiceId);
                    using (SqlDataAdapter da = new SqlDataAdapter(subCmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptReceiptBreakdown.DataSource = dt;
                        rptReceiptBreakdown.DataBind();
                    }
                }

                // 3. Trigger Modal to open
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenReceipt", "openReceiptModal();", true);
            }
        }

        private int GetStudentId()
        {
            if (Session["StudentID"] != null) return Convert.ToInt32(Session["StudentID"]);

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
    }
}