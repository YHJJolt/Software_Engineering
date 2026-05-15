<%@ Page Title="Manage Payments" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="ManagePayments.aspx.cs" Inherits="SchoolSystem.ManagePayments" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* General styles */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        
        /* Summary Dashboard Cards */
        .stats-container { display: flex; gap: 20px; margin-bottom: 25px; }
        .stat-card { flex: 1; background: white; padding: 20px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); display: flex; align-items: center; gap: 15px; border: 1px solid #f0f0f0; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; }
        .stat-details { display: flex; flex-direction: column; }
        .stat-title { font-size: 13px; color: #888; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 5px; }
        .stat-value { font-size: 22px; color: #2c3e50; font-weight: 700; }

        /* Filter Styles */
        .action-bar { display: flex; justify-content: space-between; margin-bottom: 25px; width: 100%; align-items: center; }
        .filter-bar { display: flex; gap: 15px; align-items: center; background: white; padding: 12px 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); flex-wrap: wrap; }
        .filter-group { display: flex; align-items: center; gap: 10px; }
        .filter-group label { font-size: 13px; font-weight: 600; color: #555; margin: 0; }
        .filter-select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; outline: none; cursor: pointer; transition: 0.2s; }
        .filter-select:focus { border-color: #C5A059; }
        
        /* Search Bar */
        .search-group { display: flex; align-items: center; position: relative; }
        .filter-input { padding: 8px 35px 8px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; width: 220px; outline: none; transition: 0.2s; }
        .filter-input:focus { border-color: #C5A059; box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.1); }
        .search-btn { position: absolute; right: 10px; color: #888; border: none; background: none; cursor: pointer; font-size: 14px; }
        .search-btn:hover { color: #C5A059; }

        /* Button Style */
        .btn { padding: 9px 18px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; transition: 0.2s; }
        .btn-primary { background: #C5A059; color: white; box-shadow: 0 4px 10px rgba(197, 160, 89, 0.3); }
        .btn-primary:hover { background: #b08d4b; transform: translateY(-1px); }
        .btn-tertiary { background: #f8fafc; border: 1px solid #ddd; color: #555; }
        .btn-tertiary:hover { background: #e2e8f0; }
        .btn-warning { background: #fff5f5; border: 1px solid #ffcccc; color: #d33; }
        .btn-warning:hover { background: #ffe6e6; }

        /* Table */
        .data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.04); }
        .data-table th { background: #2c3e50; color: white; padding: 15px 16px; text-align: left; font-size: 14px; font-weight: 600; letter-spacing: 0.5px; }
        .data-table td { padding: 14px 16px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #444; }
        .data-table tr:hover td { background: #f8fafc; }
        .data-table tr:last-child td { border-bottom: none; }

        /* Status badges */
        .badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-paid { background: #e6ffed; color: #1e8e3e; border: 1px solid #b7ebc5; }
        .badge-unpaid { background: #fce8e6; color: #d93025; border: 1px solid #fad2cf; }

        .action-container { display: flex; gap: 8px; align-items: center; }

        /* Modal */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(18, 20, 32, 0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 1000; }
        .modal-form { background: #fff; padding: 35px 40px; border-radius: 12px; width: 450px; max-height: 85vh; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.2); border-top: 5px solid #C5A059; animation: fadeIn 0.3s ease; }
        @keyframes fadeIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }
        .modal-form h3 { margin: 0 0 25px 0; color: #2c3e50; font-size: 22px; font-weight: 700; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; color: #666; margin-bottom: 8px; font-weight: 600; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; transition: 0.3s; box-sizing: border-box; }
        .form-control:focus { border-color: #C5A059; box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15); outline: none; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server"> 

    <div class="header">
        <h1 style="color: #2c3e50; font-size: 28px; margin: 0;">Fee & Payment Management</h1>
    </div>

    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            
            <%-- Dynamic Summary Dashboard --%>
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(197, 160, 89, 0.1); color: #c5a059;"><i class="fas fa-file-invoice"></i></div>
                    <div class="stat-details">
                        <span class="stat-title">Filtered Invoices</span>
                        <span class="stat-value"><asp:Literal ID="litTotalInvoices" runat="server" Text="0"></asp:Literal></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(46, 204, 113, 0.1); color: #2ecc71;"><i class="fas fa-hand-holding-usd"></i></div>
                    <div class="stat-details">
                        <span class="stat-title">Total Collected</span>
                        <span class="stat-value">RM <asp:Literal ID="litTotalCollected" runat="server" Text="0.00"></asp:Literal></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(231, 76, 60, 0.1); color: #e74c3c;"><i class="fas fa-exclamation-circle"></i></div>
                    <div class="stat-details">
                        <span class="stat-title">Pending Payments</span>
                        <span class="stat-value">RM <asp:Literal ID="litPendingPayments" runat="server" Text="0.00"></asp:Literal></span>
                    </div>
                </div>
            </div>

            <%-- Top Action Bar containing Filters and Create Button --%>
            <div class="action-bar">
                <div class="filter-bar">
                    <div class="search-group">
                        <asp:TextBox ID="txtSearchStudent" runat="server" CssClass="filter-input" placeholder="Search student name..."></asp:TextBox>
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="search-btn" OnClick="Filter_Changed"><i class="fas fa-search"></i></asp:LinkButton>
                    </div>

                    <div class="filter-group">
                        <label>Status:</label>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="All">All Status</asp:ListItem>
                            <asp:ListItem Value="Unpaid">Unpaid</asp:ListItem>
                            <asp:ListItem Value="Paid">Paid</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="filter-group">
                        <label>Program:</label>
                        <asp:DropDownList ID="ddlFilterProgram" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
                    </div>

                    <div class="filter-group">
                        <label>Sort:</label>
                        <asp:DropDownList ID="ddlSortDue" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="ASC">Due Soonest</asp:ListItem>
                            <asp:ListItem Value="DESC">Due Latest</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                
                <div>
                    <asp:Button ID="btnCreatePayment" runat="server" Text="+ Create Invoice" CssClass="btn btn-primary" OnClick="BtnOpenCreateModal_Click" />
                </div>
            </div>

            <%-- Payments Table --%>
            <asp:HiddenField ID="hdnDeletePaymentId" runat="server" />
   
            <asp:GridView ID="gvPayments" runat="server" CssClass="data-table" AutoGenerateColumns="False" 
                          EmptyDataText="No payment records found matching your criteria." GridLines="None"
                          OnRowCommand="GvPayments_RowCommand">
                <Columns>
                    <asp:BoundField DataField="payment_id" HeaderText="ID" />
                    <asp:BoundField DataField="student_name" HeaderText="Student Name" />
                    <asp:BoundField DataField="program_code" HeaderText="Program" />
           
                    <asp:BoundField DataField="payment_amount" HeaderText="Amount (RM)" DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="payment_duedate" HeaderText="Due Date" DataFormatString="{0:MMM dd, yyyy}" />
                    
                    <asp:TemplateField HeaderText="Pay Date">
                        <ItemTemplate>
                            <%# Eval("payment_paydate") == DBNull.Value ? "-" : Convert.ToDateTime(Eval("payment_paydate")).ToString("MMM dd, yyyy") %>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="payment_method" HeaderText="Method" NullDisplayText="-" />
                    
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge <%# Eval("payment_paydate") == DBNull.Value ? "badge-unpaid" : "badge-paid" %>'>
                                <%# Eval("payment_paydate") == DBNull.Value ? "Unpaid" : "Paid" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <div class="action-container">
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-tertiary" ToolTip="Edit/Update Payment"
                                    CommandName="EditPayment" CommandArgument='<%# Eval("payment_id") %>'>
                                    <i class="fa fa-pencil"></i> 
                                </asp:LinkButton>
   
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-warning" ToolTip="Delete Record"
                                    OnClick="BtnDeletePayment_Click" OnClientClick='<%# "return confirmDelete(this, \"" + Eval("payment_id") + "\");" %>'>
                                    <i class="fa fa-trash"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
    </asp:UpdatePanel>

    <%-- Create/Edit Modal Form --%>
    <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional"> 
        <ContentTemplate>
            <asp:Panel ID="pnlModal" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-form">
                    <h3 id="modalTitle" runat="server">Create New Invoice</h3>
                    <asp:HiddenField ID="hdnPaymentId" runat="server" />
              
                    <div class="form-group">
                        <label>Student</label>
                        <asp:DropDownList ID="ddlStudent" runat="server" CssClass="form-control"></asp:DropDownList>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlStudent" InitialValue="0" ErrorMessage="Select a student" ForeColor="Red" Display="Dynamic" Font-Size="12px" />
                    </div>
                    
                    <div class="form-group">
                        <label>Amount (RM)</label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" TextMode="Number" Step="0.01" placeholder="e.g. 1500.00" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAmount" ErrorMessage="Amount is required" ForeColor="Red" Display="Dynamic" Font-Size="12px" />
                    </div>

                    <div class="form-group">
                        <label>Due Date</label>
                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" TextMode="Date" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDueDate" ErrorMessage="Due date is required" ForeColor="Red" Display="Dynamic" Font-Size="12px" />
                    </div>

                    <hr style="border: 0; border-top: 1px solid #eee; margin: 25px 0;" />
                    <p style="font-size: 12px; color: #888; margin-bottom: 15px;"><i>Fill the below only when payment is received:</i></p>

                    <div class="form-group">
                        <label>Payment Date (Optional)</label>
                        <asp:TextBox ID="txtPayDate" runat="server" CssClass="form-control" TextMode="Date" />
                    </div>

                    <div class="form-group">
                        <label>Payment Method</label>
                        <asp:DropDownList ID="ddlMethod" runat="server" CssClass="form-control">
                            <asp:ListItem Value="">-- Select Method --</asp:ListItem>
                            <asp:ListItem Value="Cash">Cash</asp:ListItem>
                            <asp:ListItem Value="Credit Card">Credit Card</asp:ListItem>
                            <asp:ListItem Value="Bank Transfer">Bank Transfer</asp:ListItem>
                            <asp:ListItem Value="Cheque">Cheque</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div style="margin-top: 30px; display: flex; gap: 10px; justify-content: flex-end;">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="BtnCancel_Click" CausesValidation="false" />
                        <asp:Button ID="btnSave" runat="server" Text="Save Payment" CssClass="btn btn-primary" OnClick="BtnSavePayment_Click" />
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
        function confirmDelete(btn, paymentId) {
            Swal.fire({
                title: 'Delete Record?',
                text: 'Are you sure you want to delete this payment record?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, delete it!'
            }).then(function (result) {
                if (result.isConfirmed) {
                    document.getElementById('<%= hdnDeletePaymentId.ClientID %>').value = paymentId;

                    var href = btn.getAttribute('href');
                    if (href && href.startsWith('javascript:')) {
                        eval(href.replace('javascript:', ''));
                    } else {
                        btn.removeAttribute('onclick');
                        btn.click();
                    }
                }
            });
            return false;
        }
    </script>
</asp:Content>