<%@ Page Title="Payment" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentPayments.aspx.cs" Inherits="SchoolSystem.StudentPayments" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <div class="sp-container">
        <h3 class="sp-title">Tuition Fees</h3>

        <asp:UpdatePanel ID="upPayments" runat="server">
            <ContentTemplate>
                
                <div class="payment-stat-card">
                    <div class="payment-stat-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="payment-stat-details">
                        <h4>Total Pending Balance</h4>
                        <h2>RM <asp:Literal ID="litPendingBalance" runat="server" Text="0.00"></asp:Literal></h2>
                    </div>
                </div>

                <h4 class="sp-fw-bold" style="color: var(--navy-accent); margin-bottom: 15px;">Invoice History</h4>
                
                <asp:Panel ID="pnlNoInvoices" runat="server" Visible="false" style="text-align: center; padding: 50px; background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 12px;">
                    <i class="fas fa-file-invoice" style="font-size: 40px; color: #cbd5e1; margin-bottom: 15px;"></i>
                    <h5 style="color: var(--text-muted); margin: 0;">No invoices found.</h5>
                </asp:Panel>

                <asp:Repeater ID="rptInvoices" runat="server" OnItemCommand="rptInvoices_ItemCommand" OnItemDataBound="rptInvoices_ItemDataBound">
    <ItemTemplate>
        <div class="invoice-card">
            
            <div class="sp-flex-between invoice-header" onclick="toggleBreakdown('breakdown-<%# Eval("payment_id") %>')">
                <div>
                    <h5 class="sp-fw-bold">Invoice #INV-<%# Eval("payment_id").ToString().PadLeft(5, '0') %></h5>
                    <p class="sp-text-muted">
                        <i class="far fa-calendar-alt" style="margin-right: 5px;"></i> Due: <%# Convert.ToDateTime(Eval("payment_duedate")).ToString("dd MMM yyyy") %>
                    </p>
                </div>
                <div class="sp-flex sp-gap-3">
                    <h4 class="sp-fw-bold">RM <%# Convert.ToDecimal(Eval("payment_amount")).ToString("N2") %></h4>
                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                    <asp:Button ID="btnAction" runat="server" />
                </div>
            </div>

            <div id="breakdown-<%# Eval("payment_id") %>" class="sp-breakdown">
                <div class="sp-fw-bold sp-mb-2" style="font-size: 14px;">
                    <i class="fas fa-book" style="margin-right: 8px;"></i> Course Fee Breakdown
                </div>
                <div class="sp-breakdown-box">
                    
                    <asp:Repeater ID="rptCourseBreakdown" runat="server">
                        <ItemTemplate>
                            <div class="sp-breakdown-row">
                                <span>
                                    <strong style="color: var(--antique-gold);"><%# Eval("course_code") %></strong> 
                                    - <%# Eval("course_name") %>
                                </span>
                                <span class="sp-fw-bold">RM <%# Convert.ToDecimal(Eval("course_fee")).ToString("N2") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                </div>
            </div>
            
        </div> </ItemTemplate>
</asp:Repeater> 
                <div id="paymentModal" class="sp-modal-overlay">
                    <div class="sp-modal-box">
                        <div class="sp-modal-header">
                            <h5 class="sp-fw-bold"><i class="fas fa-lock" style="margin-right: 8px;"></i> Secure Checkout</h5>
                            <button type="button" class="sp-modal-close" onclick="closePaymentModal()">&times;</button>
                        </div>
                        <div class="sp-modal-body">
                            <asp:HiddenField ID="hfPayInvoiceId" runat="server" />
                            
                            <div class="sp-text-center sp-mb-3">
                                <p class="sp-text-muted sp-mb-1">Amount to Pay</p>
                                <h2 class="sp-fw-bold" style="color: var(--navy-accent); margin: 0; font-size: 32px;">RM <asp:Literal ID="litPayAmount" runat="server"></asp:Literal></h2>
                            </div>

                            <div class="sp-mb-3">
                                <label class="sp-form-label">Payment Method</label>
                                <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="sp-form-control" onchange="togglePaymentFields(this)">
                                    <asp:ListItem Value="" Text="-- Select Method --"></asp:ListItem>
                                    <asp:ListItem Value="Credit Card" Text="Credit / Debit Card"></asp:ListItem>
                                    <asp:ListItem Value="Bank Transfer" Text="Online Banking (FPX)"></asp:ListItem>
                                    <asp:ListItem Value="Cash" Text="Cash at Counter"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div id="ccFields" style="display:none; background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 20px;">
                                <div class="sp-mb-2">
                                    <label class="sp-form-label">Card Number</label>
                                    <input type="text" class="sp-form-control" placeholder="XXXX XXXX XXXX XXXX" maxlength="19" />
                                </div>
                                <div class="sp-grid-2">
                                    <div>
                                        <label class="sp-form-label">Expiry</label>
                                        <input type="text" class="sp-form-control" placeholder="MM/YY" maxlength="5" />
                                    </div>
                                    <div>
                                        <label class="sp-form-label">CVV</label>
                                        <input type="password" class="sp-form-control" placeholder="***" maxlength="3" />
                                    </div>
                                </div>
                            </div>

                            <asp:Button ID="btnConfirmPayment" runat="server" Text="Confirm Payment" CssClass="sp-btn sp-btn-success" OnClick="btnConfirmPayment_Click" UseSubmitBehavior="false" OnClientClick="if (!validatePayment()) return false;" />                        </div>
                    </div>
                </div>

                <div id="receiptModal" class="sp-modal-overlay">
                <div class="sp-modal-box" style="background: transparent; box-shadow: none;">
                    <div class="receipt-paper">
            
                        <div class="no-print" style="display: flex; justify-content: flex-end; align-items: center; gap: 15px; margin-bottom: 20px;">
                            <button type="button" class="sp-btn sp-btn-outline" style="background: white; border-color: #cbd5e1; padding: 6px 12px; font-size: 13px;" onclick="window.print()">
                                <i class="fas fa-print" style="margin-right: 5px;"></i> Print
                            </button>
                            <button type="button" class="sp-modal-close" style="color: #333; position: static; font-size: 28px; line-height: 1;" onclick="closeReceiptModal()">&times;</button>
                        </div>

                        <div class="receipt-header">
                            <h3>OFFICIAL RECEIPT</h3>
                        </div>
                            
                        <div class="receipt-row">
    <span class="sp-text-muted">Receipt No:</span>
    <span class="sp-fw-bold">#<asp:Literal ID="litReceiptNo" runat="server"></asp:Literal></span>
                        </div>
                        <div class="receipt-row">
                            <span class="sp-text-muted">Date Paid:</span>
                            <span class="sp-fw-bold"><asp:Literal ID="litReceiptDate" runat="server"></asp:Literal></span>
                        </div>
                        <div class="receipt-row">
                            <span class="sp-text-muted">Paid By:</span>
                            <span class="sp-fw-bold"><asp:Literal ID="litReceiptStudent" runat="server"></asp:Literal></span>
                        </div>
                        <div class="receipt-row">
                            <span class="sp-text-muted">Method:</span>
                            <span class="sp-fw-bold"><asp:Literal ID="litReceiptMethod" runat="server"></asp:Literal></span>
                        </div>

                        <div style="margin-top: 25px; margin-bottom: 10px; border-bottom: 1px dashed #ccc; padding-bottom: 5px;">
                            <strong style="font-size: 13px; letter-spacing: 1px;">ITEMIZED FEES</strong>
                        </div>
                        <asp:Repeater ID="rptReceiptBreakdown" runat="server">
                            <ItemTemplate>
                                <div class="receipt-row" style="font-size: 13px; color: #555; margin-bottom: 5px;">
                                    <span><%# Eval("course_code") %> - <%# Eval("course_name") %></span>
                                    <span>RM <%# Convert.ToDecimal(Eval("course_fee")).ToString("N2") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <div class="receipt-total receipt-row" style="margin-top: 15px;">
                            <span>TOTAL PAID:</span>
                            <span>RM <asp:Literal ID="litReceiptAmount" runat="server"></asp:Literal></span>
                        </div>
                        <div class="receipt-footer">
                            <p style="margin: 0;">Thank you for your payment.</p>
                            <p style="margin: 0;">This is a computer-generated receipt.</p>
                        </div>
                    </div>
                </div>
            </div>

            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <script>
        function toggleBreakdown(id) {
            var el = document.getElementById(id);
            if (el.classList.contains('show')) {
                el.classList.remove('show');
            } else {
                el.classList.add('show');
            }
        }

        function openPaymentModal() { document.getElementById('paymentModal').style.display = 'flex'; }
        function closePaymentModal() { document.getElementById('paymentModal').style.display = 'none'; }

        function openReceiptModal() { document.getElementById('receiptModal').style.display = 'flex'; }
        function closeReceiptModal() { document.getElementById('receiptModal').style.display = 'none'; }

        function togglePaymentFields(dropdown) {
            var ccFields = document.getElementById('ccFields');
            if (dropdown.value === "Credit Card") {
                ccFields.style.display = "block";
            } else {
                ccFields.style.display = "none";
            }
        }

        function validatePayment() {
            var method = document.getElementById('<%= ddlPaymentMethod.ClientID %>').value;
            if (method === "") {
                Swal.fire('Required', 'Please select a payment method.', 'warning');
                return false;
            }
            return true;
        }
    </script>
</asp:Content>