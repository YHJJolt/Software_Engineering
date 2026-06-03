<%@ Page Title="Course Home" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master"
    AutoEventWireup="true" CodeBehind="StudentCourseHome.aspx.cs" Inherits="SchoolSystem.StudentCourseHome" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hero --%>
    <div class="sch-hero">
        <div class="sch-hero-left">
            <div class="sch-course-code"><asp:Literal ID="litCourseCode" runat="server" /></div>
            <h1 class="sch-course-title"><asp:Literal ID="litCourseName" runat="server" /></h1>
            <div class="sch-meta">
                <div class="sch-meta-item">
                    <i class="fas fa-clock"></i>
                    <asp:Literal ID="litCreditHours" runat="server" /> Credit Hours
                </div>
                <div class="sch-meta-item">
                    <i class="fas fa-graduation-cap"></i>
                    <asp:Literal ID="litProgramName" runat="server" />
                </div>
                <div class="sch-meta-item">
                    <i class="fas fa-chalkboard-teacher"></i>
                    <asp:Literal ID="litLecturerName" runat="server" />
                </div>
            </div>
        </div>
        <asp:Literal ID="litStatusBadge" runat="server" />
    </div>

    <%-- 2 Stats --%>
    <div class="sch-stats-2">
        <div class="sch-stat">
            <div class="sch-stat-icon icon-gold"><i class="fas fa-calendar-check"></i></div>
            <div class="sch-stat-info">
                <span>My Attendance</span>
                <h3><asp:Literal ID="litMyAttendance" runat="server">N/A</asp:Literal></h3>
            </div>
        </div>
        <div class="sch-stat">
            <div class="sch-stat-icon icon-green"><i class="fas fa-star"></i></div>
            <div class="sch-stat-info">
                <span>My Grade</span>
                <h3><asp:Literal ID="litMyGrade" runat="server">N/A</asp:Literal></h3>
            </div>
        </div>
    </div>

    <%-- Two-col: Assignments + Announcements --%>
    <div class="sch-grid">

        <%-- Upcoming Assignments --%>
        <div class="sch-card">
            <div class="sch-card-header">
                <h4><i class="fas fa-file-alt" style="color:var(--antique-gold); margin-right:8px;"></i>Upcoming Assignments</h4>
                <a href='<%="StudentCourseAssignments.aspx?id=" + Request.QueryString["id"] %>' class="sch-view-link">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="sch-card-body">
                <asp:Repeater ID="rptAssignments" runat="server">
                    <ItemTemplate>
                        <div class="sch-assign-item">
                            <div class="sch-assign-icon"><i class="fas fa-file-alt"></i></div>
                            <div class="sch-assign-info">
                                <div class="sch-assign-title"><%# Eval("title") %></div>
                                <div class="sch-assign-meta">
                                    <span class="sch-assign-type"><%# Eval("assignment_type") %></span>
                                    &bull;
                                    <span class='<%# GetDueClass(Eval("due_date")) %>'>
                                        Due: <%# Eval("due_date", "{0:dd MMM yyyy}") %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoAssign" runat="server" Visible="false" CssClass="sch-empty">
                    <i class="fas fa-file-alt"></i>No upcoming assignments
                </asp:Panel>
            </div>
        </div>

        <%-- Announcements --%>
        <div class="sch-card">
            <div class="sch-card-header">
                <h4><i class="fas fa-bullhorn" style="color:var(--antique-gold); margin-right:8px;"></i>Announcements</h4>
                <a href='<%="StudentAnnouncements.aspx?id=" + Request.QueryString["id"] %>' class="sch-view-link">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="sch-card-body">
                <asp:Repeater ID="rptAnnouncements" runat="server">
                    <ItemTemplate>
                        <div class="sch-info-item">
                            <div class="sch-info-dot"></div>
                            <div>
                                <div class="sch-info-title"><%# Eval("title") %></div>
                                <div class="sch-info-sub"><%# Eval("category") %> &bull; <%# Eval("created_at", "{0:dd MMM yyyy}") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoAnnounce" runat="server" Visible="false" CssClass="sch-empty">
                    <i class="fas fa-bullhorn"></i>No announcements for this course yet
                </asp:Panel>
            </div>
        </div>

    </div>

</asp:Content>
