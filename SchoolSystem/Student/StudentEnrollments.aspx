<%@ Page Title="Course Enrollment" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentEnrollments.aspx.cs" Inherits="SchoolSystem.StudentEnrollment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <div class="sp-container">
        <asp:UpdatePanel ID="upEnrollment" runat="server">
            <ContentTemplate>
                
                <div class="sp-section-title">
                    <i class="fas fa-clipboard-list" style="color: #64748b; margin-right: 8px;"></i> My Enrollment Status
                </div>
                
                <div class="sp-table-wrapper"> <div class="sp-filter-bar" style="padding: 20px; margin-bottom: 0; border-bottom: 1px solid #e2e8f0;">
                        <input type="text" class="sp-search-input" placeholder="Search by course name or code..." onkeyup="filterStatusTable(this.value)" />
                        <select class="sp-filter-select" onchange="filterStatusTable(this.value)">
                            <option value="">All Statuses</option>
                            <option value="Approved">Approved</option>
                            <option value="Pending">Pending</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>

                    <asp:GridView ID="gvMyStatus" runat="server" AutoGenerateColumns="false" CssClass="sp-table" GridLines="None" Width="100%" EmptyDataText="You have no enrollment history.">
                        <Columns>
                            <asp:BoundField DataField="course_code" HeaderText="Course Code" ItemStyle-CssClass="searchable-text" />
                            <asp:BoundField DataField="course_name" HeaderText="Course Name" ItemStyle-CssClass="searchable-text" />
                            
                            <asp:TemplateField HeaderText="Status" HeaderStyle-CssClass="center-align" ItemStyle-CssClass="center-align">
                                <ItemTemplate>
                                    <span class='sp-badge searchable-text <%# Eval("status").ToString() == "Approved" ? "sp-badge-success" : (Eval("status").ToString() == "Pending" ? "sp-badge-warning" : "sp-badge-danger") %>'>
                                        <%# Eval("status") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <hr style="border: 0; border-top: 2px dashed #e2e8f0; margin: 40px 0;" />

                <div class="enrollment-split">
                    
                    <div>
                        <div class="sp-section-title">
                            <i class="fas fa-book-open" style="color: #64748b; margin-right: 8px;"></i> Available Courses
                        </div>
                        
                        <div style="display: flex; flex-direction: column; gap: 15px;">
                            <asp:Repeater ID="rptAvailableCourses" runat="server" OnItemCommand="rptAvailableCourses_ItemCommand">
                                <ItemTemplate>
                                    <div class="course-catalog-card">
                                        <div>
                                            <h4 class="sp-fw-bold" style="color: var(--antique-gold); margin: 0 0 5px 0; font-size: 16px;"><%# Eval("course_code") %></h4>
                                            <h5 style="color: var(--navy-accent); margin: 0; font-size: 18px; font-weight: 700;"><%# Eval("course_name") %></h5>
                                            
                                            <div class="course-price-tag">
                                                <i class="fas fa-tag" style="margin-right: 5px; color: var(--antique-gold);"></i> 
                                                Fee: RM <%# Convert.ToDecimal(Eval("course_fee")).ToString("N2") %>
                                            </div>
                                        </div>
                                        <div style="text-align: right; margin-top: 20px;">
                                            <asp:Button ID="btnEnroll" runat="server" Text="Request Enrollment" CssClass="sp-btn sp-btn-primary" 
                                                CommandName="Enroll" CommandArgument='<%# Eval("course_id") %>' />
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <div>
                        <div class="sp-section-title">
                            <i class="fas fa-hourglass-half" style="color: #f59e0b; margin-right: 8px;"></i> Awaiting Approval
                        </div>
                        
                        <div style="background: #f8fafc; border-radius: 12px; padding: 20px; min-height: 200px; border: 1px solid #e2e8f0;">
                            <asp:Repeater ID="rptPendingQueue" runat="server">
                                <ItemTemplate>
                                    <div class="pending-queue-card">
                                        <h4><%# Eval("course_name") %></h4>
                                        <p><%# Eval("course_code") %> &bull; <i class="fas fa-clock" style="margin-left: 5px;"></i> Pending Admin</p>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            
                            <div id="divNoPending" runat="server" visible="false" style="text-align: center; color: #94a3b8; padding-top: 40px;">
                                <i class="fas fa-inbox" style="font-size: 30px; margin-bottom: 10px;"></i>
                                <p>No pending requests.</p>
                            </div>
                        </div>
                    </div>

                </div>

                <script type="text/javascript">
                    function filterStatusTable(query) {
                        query = query.toLowerCase();
                        const rows = document.querySelectorAll('#<%= gvMyStatus.ClientID %> tr:not(:first-child)');

                        rows.forEach(row => {
                            const rowText = row.innerText.toLowerCase();
                            if (rowText.includes(query)) {
                                row.style.display = '';
                            } else {
                                row.style.display = 'none';
                            }
                        });
                    }
                </script>

            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>