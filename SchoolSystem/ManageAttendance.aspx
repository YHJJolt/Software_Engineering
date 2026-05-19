<%@ Page Title="Manage Attendance" Language="C#" MasterPageFile="~/CourseMaster.Master" AutoEventWireup="true" CodeBehind="ManageAttendance.aspx.cs" Inherits="SchoolSystem.ManageAttendance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .attendance-container { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); border: 1px solid rgba(0,0,0,0.05); }
        .attendance-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .attendance-table th { text-align: left; padding: 15px; border-bottom: 2px solid var(--antique-gold); color: var(--navy-accent); font-weight: 700; }
        .attendance-table td { padding: 15px; border-bottom: 1px solid #eee; vertical-align: middle; }
        .attendance-table tr:hover { background-color: #fafafa; }
        
        .status-dropdown { padding: 8px 12px; border-radius: 6px; border: 1px solid #ccc; font-family: inherit; font-weight: 600; cursor: pointer; outline: none; }
        .status-dropdown:focus { border-color: var(--soft-glow); }
        
        .btn-save-attendance { background: var(--navy-accent); color: white; border: none; padding: 12px 25px; border-radius: 6px; font-weight: bold; cursor: pointer; float: right; margin-top: 20px; transition: 0.2s; }
        .btn-save-attendance:hover { background: var(--antique-gold); }
        
        .warn-badge { display: inline-flex; align-items: center; gap: 5px; background: #fee2e2; color: #b91c1c; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-left: 10px; }
        .good-text { color: #10b981; font-weight: bold; }
        .bad-text { color: #b91c1c; font-weight: bold; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="attendance-container">
        <h3 style="margin-top: 0; color: var(--navy-accent);">Weekly Session Attendance</h3>
        <p style="color: #888; font-size: 14px; margin-bottom: 20px;">
            <i class="fas fa-info-circle"></i> Marking a student <strong>Present</strong> adds 2 Total Hours and 2 Attended Hours. 
            Marking <strong>Absent</strong> adds 2 Total Hours and 0 Attended Hours.
        </p>
        
        <asp:Label ID="lblSuccessMsg" runat="server" Visible="false" ForeColor="#10b981" Font-Bold="true" style="display:block; margin-bottom: 15px;"></asp:Label>

        <table class="attendance-table">
            <thead>
                <tr>
                    <th>Student ID</th>
                    <th>Student Name</th>
                    <th>Total Hours</th>
                    <th>Attended Hours</th>
                    <th>Attendance %</th>
                    <th>Record This Session</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptStudents" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><strong><%# Eval("student_id") %></strong></td>
                            <td><%# Eval("student_name") %></td>
                            <td><%# Eval("total_hours") %> hrs</td>
                            <td><%# Eval("attended_hours") %> hrs</td>
                            <td>
                                <span class='<%# Convert.ToDouble(Eval("AttendancePercentage")) < 75.0 ? "bad-text" : "good-text" %>'>
                                    <%# Eval("AttendancePercentage", "{0:0.0}") %>%
                                </span>
                                <%# Convert.ToDouble(Eval("AttendancePercentage")) < 75.0 ? "<span class='warn-badge'><i class='fas fa-exclamation-triangle'></i> Critical</span>" : "" %>
                            </td>
                            <td>
                                <asp:HiddenField ID="hfEnrollmentId" runat="server" Value='<%# Eval("Enrollment_id") %>' />
                                
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-dropdown">
                                    <asp:ListItem Text="Present" Value="Present" Selected="True"></asp:ListItem>
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