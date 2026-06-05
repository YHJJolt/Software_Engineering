<%@ Page Title="Student Dashboard" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="SchoolSystem.StudentDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <span>Courses Enrolled</span>
                <h2><asp:Literal ID="litCourseCount" runat="server">0</asp:Literal></h2>
            </div>
            <div class="stat-icon-wrapper icon-blue">
                <i class="fas fa-layer-group"></i>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-info">
                <span>Current CGPA</span>
                <h2><asp:Literal ID="litCGPA" runat="server">N/A</asp:Literal></h2>
            </div>
            <div class="stat-icon-wrapper icon-gold">
                <i class="fas fa-graduation-cap"></i>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-info">
                <span>Average Attendance</span>
                <h2><asp:Literal ID="litAttendance" runat="server">0%</asp:Literal></h2>
            </div>
            <div class="stat-icon-wrapper icon-green">
                <i class="fas fa-calendar-check"></i>
            </div>
        </div>
    </div>

    <div class="dashboard-section">
        <div class="section-header">
            <h3>My Enrolled Courses</h3>
        </div>
        
        <asp:Panel ID="noCoursesPanel" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-book-open"></i>
            <p>You have no favourited courses. Star a course in <a href="StudentCourses.aspx">My Courses</a> to pin it here.</p>
        </asp:Panel>

        <div class="courses-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card" onclick="window.location.href='StudentCourseHome.aspx?id=<%# Eval("course_id") %>'">
                        <div class="course-badge">Active</div>
                        <div class="course-img-container">
                            <img src='<%# GetImageSrc(Eval("course_img")) %>' alt="Course Image" onerror="this.src='../Images/default-course.png';" />
                        </div>
                        <div class="course-info">
                            <div class="course-code"><%# Eval("course_code") %></div>
                            <h4 class="course-name"><%# Eval("course_name") %></h4>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

</asp:Content>
