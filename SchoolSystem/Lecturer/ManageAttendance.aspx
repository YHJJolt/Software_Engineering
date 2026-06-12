<%@ Page Title="Manage Attendance" Language="C#" MasterPageFile="~/Lecturer/LecturerCourseMaster.Master" AutoEventWireup="true" CodeBehind="ManageAttendance.aspx.cs" Inherits="SchoolSystem.ManageAttendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="attendance-container">
        <h2>Mark Attendance</h2>
        
        <asp:Label ID="lblSuccessMsg" runat="server" Visible="false" ForeColor="Green" Font-Bold="true" style="display:block; margin-bottom: 15px;"></asp:Label>

        <div class="filter-controls" style="display: flex; gap: 15px; margin-bottom: 20px; align-items: center;">
            <label style="font-weight: 600;">Session Date:</label>
            <asp:TextBox ID="txtAttendanceDate" runat="server" TextMode="Date" AutoPostBack="true" OnTextChanged="txtAttendanceDate_TextChanged" style="padding: 8px; border-radius: 6px; border: 1px solid #ccc; outline: none;"></asp:TextBox>

            <asp:TextBox ID="txtSearch" runat="server" Placeholder="Search student name..." style="padding: 8px; border-radius: 6px; border: 1px solid #ccc; width: 250px; outline: none;"></asp:TextBox>
            
            <asp:DropDownList ID="ddlAttendanceFilter" runat="server" style="padding: 8px; border-radius: 6px; border: 1px solid #ccc; outline: none;">
                <asp:ListItem Text="All Students" Value="All"></asp:ListItem>
                <asp:ListItem Text="High Attendance (≥ 75%)" Value="High"></asp:ListItem>
                <asp:ListItem Text="Low Attendance (< 75%)" Value="Low"></asp:ListItem>
            </asp:DropDownList>
            
            <asp:Button ID="btnSearch" runat="server" Text="Search & Filter" OnClick="btnSearch_Click" style="padding: 8px 15px; background-color: #121420; color: white; border: none; border-radius: 6px; cursor: pointer;" />
        </div>

        <table class="attendance-table">
            <thead>
                <tr>
                    <th>Student Code</th>
                    <th>Student Name</th>
                    <th>Total Hours</th>
                    <th>Attended Hours</th>
                    <th>Attendance %</th>
                    <th>Mark Session (<asp:Literal ID="litSelectedDate" runat="server">Today</asp:Literal>)</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptAttendance" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><%# Eval("student_code") %></td>
                            <td><%# Eval("student_name") %></td>
                            <td><%# Eval("total_hours") %> hrs</td>
                            <td><%# Eval("attended_hours") %> hrs</td>
                            <td>
                                <span class='<%# Convert.ToInt32(Eval("total_hours")) == 0 ? "neutral-text" : (Convert.ToDouble(Eval("AttendancePercentage")) < 75.0 ? "bad-text" : "good-text") %>'>
                                    <%# Eval("AttendancePercentage", "{0:0.0}") %>%
                                </span>
                                <%# (Convert.ToInt32(Eval("total_hours")) > 0 && Convert.ToDouble(Eval("AttendancePercentage")) < 75.0) ? "<span class='warn-badge'><i class='fas fa-exclamation-triangle'></i> Critical</span>" : "" %>
                            </td>
                            <td>
                                <asp:HiddenField ID="hfEnrollmentId" runat="server" Value='<%# Eval("Enrollment_id") %>' />
                                
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-dropdown" SelectedValue='<%# Eval("day_status") %>'>
                                    <asp:ListItem Text="— Not Marked —" Value="NotMarked"></asp:ListItem>
                                    <asp:ListItem Text="Present" Value="Present"></asp:ListItem>
                                    <asp:ListItem Text="Absent" Value="Absent"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>

        <asp:Button ID="btnSave" runat="server" Text="Save Session Attendance" CssClass="btn-save-attendance" OnClick="btnSave_Click" />
        <div style="clear: both;"></div>
    </div>
</asp:Content>