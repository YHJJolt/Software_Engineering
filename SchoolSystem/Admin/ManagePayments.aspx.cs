using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class ManagePayments : System.Web.UI.Page
    {
        private readonly string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulatePrograms();
                PopulateStudents();
                LoadPayments();
            }
        }

        // --- 1. LOAD DATA ---
        private void LoadPayments()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT 
                        p.payment_id, 
                        p.payment_amount, 
                        p.payment_duedate, 
                        p.payment_paydate, 
                        ISNULL(p.payment_method, 'Unpaid') AS payment_method, 
                        s.student_name,
                        pr.program_code
                    FROM Payment p
                    INNER JOIN Student s ON p.student_id = s.student_id
                    INNER JOIN Program pr ON s.Program_id = pr.program_id
                    WHERE 1=1 ";

                SqlCommand cmd = new SqlCommand();

                // 1. Apply Search Filter
                if (!string.IsNullOrWhiteSpace(txtSearchStudent.Text))
                {
                    sql += " AND s.student_name LIKE @Search ";
                    cmd.Parameters.AddWithValue("@Search", "%" + txtSearchStudent.Text.Trim() + "%");
                }

                // 2. Apply Status Filter
                if (ddlFilterStatus.SelectedValue == "Paid")
                {
                    sql += " AND p.payment_paydate IS NOT NULL ";
                }
                else if (ddlFilterStatus.SelectedValue == "Unpaid")
                {
                    sql += " AND p.payment_paydate IS NULL ";
                }

                // 3. Apply Program Filter
                if (ddlFilterProgram.SelectedValue != "0")
                {
                    sql += " AND pr.program_id = @ProgId ";
                    cmd.Parameters.AddWithValue("@ProgId", ddlFilterProgram.SelectedValue);
                }

                // 4. Apply Sorting
                if (ddlSortDue.SelectedValue == "ASC")
                {
                    sql += " ORDER BY p.payment_duedate ASC";
                }
                else
                {
                    sql += " ORDER BY p.payment_duedate DESC";
                }

                cmd.CommandText = sql;
                cmd.Connection = conn;

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvPayments.DataSource = dt;
                gvPayments.DataBind();

                // --- UPDATE DYNAMIC SUMMARY STATS ---
                CalculateSummary(dt);
            }
        }

        private void CalculateSummary(DataTable dt)
        {
            int totalInvoices = dt.Rows.Count;
            decimal totalCollected = 0;
            decimal pendingPayments = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal amount = Convert.ToDecimal(row["payment_amount"]);

                // If it has a pay date, it's collected. Otherwise, it's pending.
                if (row["payment_paydate"] != DBNull.Value)
                    totalCollected += amount;
                else
                    pendingPayments += amount;
            }

            litTotalInvoices.Text = totalInvoices.ToString();
            litTotalCollected.Text = totalCollected.ToString("N2");
            litPendingPayments.Text = pendingPayments.ToString("N2");
        }

        private void PopulateStudents()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT student_id, student_name FROM Student ORDER BY student_name ASC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();

                ddlStudent.DataSource = cmd.ExecuteReader();
                ddlStudent.DataTextField = "student_name";
                ddlStudent.DataValueField = "student_id";
                ddlStudent.DataBind();

                ddlStudent.Items.Insert(0, new ListItem("-- Select Student --", "0"));
            }
        }

        private void PopulatePrograms()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT program_id, program_code FROM Program ORDER BY program_code ASC";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();

                ddlFilterProgram.DataSource = cmd.ExecuteReader();
                ddlFilterProgram.DataTextField = "program_code";
                ddlFilterProgram.DataValueField = "program_id";
                ddlFilterProgram.DataBind();

                ddlFilterProgram.Items.Insert(0, new ListItem("All Programs", "0"));
            }
        }

        // Triggered whenever a dropdown changes OR the search button is clicked
        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadPayments();
        }

        // --- 2. OPEN MODALS ---
        protected void BtnOpenCreateModal_Click(object sender, EventArgs e)
        {
            hdnPaymentId.Value = "";
            modalTitle.InnerText = "Create New Invoice";
            ddlStudent.SelectedIndex = 0;
            txtAmount.Text = "";
            txtDueDate.Text = "";
            txtPayDate.Text = "";
            ddlMethod.SelectedIndex = 0;

            ddlStudent.Enabled = true;

            pnlModal.Visible = true;
            upModal.Update();
        }

        protected void GvPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditPayment")
            {
                int paymentId = Convert.ToInt32(e.CommandArgument);
                FetchPaymentDetails(paymentId);
            }
        }

        private void FetchPaymentDetails(int id)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM Payment WHERE payment_id = @ID";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        hdnPaymentId.Value = id.ToString();
                        modalTitle.InnerText = "Update Payment";

                        ddlStudent.SelectedValue = reader["student_id"].ToString();
                        ddlStudent.Enabled = false;

                        txtAmount.Text = Convert.ToDecimal(reader["payment_amount"]).ToString("F2");

                        if (reader["payment_duedate"] != DBNull.Value)
                            txtDueDate.Text = Convert.ToDateTime(reader["payment_duedate"]).ToString("yyyy-MM-dd");

                        if (reader["payment_paydate"] != DBNull.Value)
                            txtPayDate.Text = Convert.ToDateTime(reader["payment_paydate"]).ToString("yyyy-MM-dd");
                        else
                            txtPayDate.Text = "";

                        ddlMethod.SelectedValue = reader["payment_method"].ToString();

                        pnlModal.Visible = true;
                        upModal.Update();
                    }
                }
            }
        }

        protected void BtnCancel_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
            upModal.Update();
        }

        // --- 3. SAVE / UPDATE ---
        protected void BtnSavePayment_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (!decimal.TryParse(txtAmount.Text.Trim(), out decimal amt) || amt <= 0)
            {
                pnlModal.Visible = true; upModal.Update();
                ScriptManager.RegisterStartupScript(this, GetType(), "amtErr",
                    "Swal.fire('Invalid Amount', 'Payment amount must be greater than 0.', 'warning');", true);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand();
                    cmd.Connection = conn;

                    object payDate = string.IsNullOrEmpty(txtPayDate.Text) ? DBNull.Value : (object)Convert.ToDateTime(txtPayDate.Text);
                    object method = string.IsNullOrEmpty(ddlMethod.SelectedValue) ? DBNull.Value : (object)ddlMethod.SelectedValue;

                    if (string.IsNullOrEmpty(hdnPaymentId.Value)) // INSERT
                    {
                        cmd.CommandText = @"INSERT INTO Payment (payment_amount, payment_duedate, payment_paydate, payment_method, student_id) 
                                          VALUES (@Amt, @Due, @Pay, @Method, @StudID)";
                        cmd.Parameters.AddWithValue("@StudID", ddlStudent.SelectedValue);
                    }
                    else // UPDATE
                    {
                        cmd.CommandText = @"UPDATE Payment SET payment_amount = @Amt, payment_duedate = @Due, 
                                          payment_paydate = @Pay, payment_method = @Method 
                                          WHERE payment_id = @ID";
                        cmd.Parameters.AddWithValue("@ID", hdnPaymentId.Value);
                    }

                    cmd.Parameters.AddWithValue("@Amt", Convert.ToDecimal(txtAmount.Text));
                    cmd.Parameters.AddWithValue("@Due", Convert.ToDateTime(txtDueDate.Text));
                    cmd.Parameters.AddWithValue("@Pay", payDate);
                    cmd.Parameters.AddWithValue("@Method", method);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                pnlModal.Visible = false;
                upModal.Update();
                LoadPayments();
                upGridView.Update();

                ScriptManager.RegisterStartupScript(this, GetType(), "success", "Swal.fire('Success', 'Payment record saved successfully!', 'success');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", $"Swal.fire('Error', 'An error occurred: {ex.Message}', 'error');", true);
            }
        }

        // --- 4. DELETE ---
        protected void BtnDeletePayment_Click(object sender, EventArgs e)
        {
            string rawId = hdnDeletePaymentId.Value;

            if (!int.TryParse(rawId, out int paymentId) || paymentId <= 0) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM Payment WHERE payment_id = @ID", conn);
                    cmd.Parameters.AddWithValue("@ID", paymentId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                hdnDeletePaymentId.Value = "";
                LoadPayments();
                upGridView.Update();

                ScriptManager.RegisterStartupScript(this, GetType(), "deleted", "Swal.fire({ title: 'Deleted!', text: 'Payment record removed.', icon: 'success', timer: 1500, showConfirmButton: false });", true);
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "error", "Swal.fire('Error', 'Failed to delete record.', 'error');", true);
            }
        }
    }
}