<%@ Page Title="Course Home" Language="C#" MasterPageFile="~/LecturerCourseMaster.Master"
    AutoEventWireup="true" CodeBehind="CourseHome.aspx.cs" Inherits="SchoolSystem.CourseHome" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hero Banner --%>
    <div class="ch-hero">
        <div class="ch-hero-left">
            <div class="ch-course-code">
                <asp:Literal ID="litCourseCode" runat="server" />
            </div>
            <h1 class="ch-course-title">
                <asp:Literal ID="litCourseName" runat="server" />
            </h1>
            <div class="ch-meta">
                <div class="ch-meta-item">
                    <i class="fas fa-clock"></i>
                    <asp:Literal ID="litCreditHours" runat="server" /> Credit Hours
                </div>
                <div class="ch-meta-item">
                    <i class="fas fa-graduation-cap"></i>
                    <asp:Literal ID="litProgramName" runat="server" />
                </div>
            </div>
        </div>
        <asp:Literal ID="litStatusBadge" runat="server" />
    </div>

    <%-- Stats --%>
    <div class="ch-stats">
        <div class="ch-stat">
            <div class="ch-stat-icon icon-blue"><i class="fas fa-users"></i></div>
            <div class="ch-stat-info">
                <span>Enrolled Students</span>
                <h3><asp:Literal ID="litEnrolled" runat="server">0</asp:Literal></h3>
            </div>
        </div>
        <div class="ch-stat">
            <div class="ch-stat-icon icon-gold"><i class="fas fa-calendar-check"></i></div>
            <div class="ch-stat-info">
                <span>Avg Attendance</span>
                <h3><asp:Literal ID="litAvgAttendance" runat="server">N/A</asp:Literal></h3>
            </div>
        </div>
        <div class="ch-stat">
            <div class="ch-stat-icon icon-green"><i class="fas fa-chart-line"></i></div>
            <div class="ch-stat-info">
                <span>Pass Rate</span>
                <h3><asp:Literal ID="litPassRate" runat="server">N/A</asp:Literal></h3>
            </div>
        </div>
        <div class="ch-stat">
            <div class="ch-stat-icon" style="background:#fee2e2;color:#ef4444;">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="ch-stat-info">
                <span>At Risk</span>
                <h3><asp:Literal ID="litAtRisk" runat="server">0</asp:Literal></h3>
            </div>
        </div>
    </div>

    <%-- Two-column cards --%>
    <div class="ch-grid">

        <%-- Recent Students --%>
        <div class="ch-card">
            <div class="ch-card-header">
                <h4><i class="fas fa-users" style="color:var(--antique-gold); margin-right:8px;"></i>Enrolled Students</h4>
                <a href='<%=ResolveUrl("~/CoursePeople.aspx?id=") + Request.QueryString["id"] %>' class="ch-view-link">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="ch-card-body">
                <asp:Repeater ID="rptStudents" runat="server">
                    <ItemTemplate>
                        <div class="ch-student-item">
                            <div class="ch-avatar"><%# Eval("student_name").ToString().Substring(0,1).ToUpper() %></div>
                            <div>
                                <div class="ch-student-name"><%# Eval("student_name") %></div>
                                <div class="ch-student-sub"><%# Eval("student_code") %> &bull; <%# Eval("status") %></div>
                            </div>
                            <span class='ch-grade-badge <%# GetGradeClass(Eval("letter_grade")) %>'>
                                <%# Eval("letter_grade") == DBNull.Value || Eval("letter_grade") == null ? "N/A" : Eval("letter_grade").ToString() %>
                            </span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoStudents" runat="server" Visible="false" CssClass="ch-empty">
                    <i class="fas fa-user-slash"></i>No students enrolled into this course yet
                </asp:Panel>
            </div>
        </div>

        <%-- Announcements --%>
        <div class="ch-card">
            <div class="ch-card-header">
                <h4><i class="fas fa-bullhorn" style="color:var(--antique-gold); margin-right:8px;"></i>Announcements</h4>
                <a href='<%=ResolveUrl("~/LecturerAnnouncement.aspx?id=") + Request.QueryString["id"] %>' class="ch-view-link">
                    View All <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="ch-card-body">
                <asp:Repeater ID="rptAnnouncements" runat="server">
                    <ItemTemplate>
                        <div class="ch-info-item">
                            <div class="ch-info-dot"></div>
                            <div>
                                <div class="ch-info-title"><%# Eval("title") %></div>
                                <div class="ch-info-sub"><%# Eval("category") %> &bull; <%# Eval("created_at", "{0:dd MMM yyyy}") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoAnnounce" runat="server" Visible="false" CssClass="ch-empty">
                    <i class="fas fa-bullhorn"></i>No announcements for this course yet
                </asp:Panel>
            </div>
        </div>

    </div>

</asp:Content>
