<%@ Page Title="View Attendance" Language="C#" MasterPageFile="~/Student/StudentMaster.Master"

    AutoEventWireup="true" CodeBehind="StudentAttendance.aspx.cs" Inherits="SchoolSystem.StudentAttendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Summary stats --%>
    <div class="sa-stats">
        <div class="sa-stat">
            <div class="sa-stat-icon icon-blue"><i class="fas fa-book-open"></i></div>
            <div class="sa-stat-info">
                <span>Courses Tracked</span>
                <h3><asp:Literal ID="litCourseCount" runat="server">0</asp:Literal></h3>
            </div>
        </div>
        <div class="sa-stat">
            <div class="sa-stat-icon icon-gold"><i class="fas fa-calendar-check"></i></div>
            <div class="sa-stat-info">
                <span>Average Attendance</span>
                <h3><asp:Literal ID="litAvgAttendance" runat="server">N/A</asp:Literal></h3>
            </div>
        </div>
        <div class="sa-stat">
            <div class="sa-stat-icon" style="background:#fee2e2;color:#ef4444;">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="sa-stat-info">
                <span>At Risk</span>
                <h3><asp:Literal ID="litAtRisk" runat="server">0</asp:Literal></h3>
            </div>
        </div>
    </div>

    <%-- Attendance Table — rows built fully server-side, no code-behind calls in ASPX --%>
    <div class="sa-card">
        <div class="sa-card-header">
            <h4><i class="fas fa-user-check" style="color:var(--antique-gold); margin-right:8px;"></i>Attendance by Course</h4>
        </div>

        <asp:Panel ID="pnlTable" runat="server" Visible="false">
            <table class="sa-table">
                <thead>
                    <tr>
                        <th>Course</th>
                        <th>Attended</th>
                        <th>Total</th>
                        <th>Attendance Rate</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Rows injected by server-side Literal to avoid inline method call errors --%>
                    <asp:Literal ID="litRows" runat="server" />
                </tbody>
            </table>
        </asp:Panel>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="sa-empty">
            <i class="fas fa-calendar-times"></i>No attendance records found
        </asp:Panel>
    </div>

</asp:Content>
