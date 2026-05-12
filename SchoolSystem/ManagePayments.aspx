<%@ Page Title="Manage Payments" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="ManagePayments.aspx.cs" Inherits="SchoolSystem.ManagePayments" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* General styles */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        
        .action-bar { display: flex; justify-content: flex-end; margin-bottom: 25px; width: 100%; }

        /* Button Style */
        .btn { padding: 9px 18px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; transition: 0.2s; }
        .btn-primary { background: #C5A059; color: white; }
        .btn-primary:hover { background: #b08d4b; }
        .btn-secondary { background: #f0f0f0; color: #555; }
        .btn-secondary:hover { background: #e0e0e0; }
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
        .badge-paid { background: #e6ffed; color: #1e8e3e; }
        .badge-unpaid { background: #fce8e6; color: #d93025; }

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

    <div class="action-bar">
        <asp:Button ID="btnCreatePayment" runat="server" Text="+ Create Invoice" CssClass="btn btn-primary" OnClick="BtnOpenCreateModal_Click" />
    </div>

    <%-- Payments Table --%>
    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:HiddenField ID="hdnDeletePaymentId" runat="server" />
            
            <asp:GridView ID="gvPayments" runat="server" CssClass="data-table" AutoGenerateColumns="False" 
                          EmptyDataText="No payment records found." GridLines="None"
                          OnRowCommand="GvPayments_RowCommand">
                <Columns>
                    <asp:BoundField DataField="payment_id" HeaderText="ID" />
                    <asp:BoundField DataField="student_name" HeaderText="Student Name" />
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