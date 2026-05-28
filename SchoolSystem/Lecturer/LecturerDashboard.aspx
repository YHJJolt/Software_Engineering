<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Lecturer/LecturerMaster.Master" AutoEventWireup="true" CodeBehind="LecturerDashboard.aspx.cs" Inherits="SchoolSystem.LecturerDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <span>Courses Assigned</span>
                <h2><asp:Literal ID="litCourseCount" runat="server">0</asp:Literal></h2>
            </div>
            <div class="stat-icon-wrapper icon-blue">
                <i class="fas fa-layer-group"></i>
            </div>
        </div>
        
        <div class="stat-card">
            <div class="stat-info">
                <span>Registered Students</span>
                <h2><asp:Literal ID="litStudentCount" runat="server">0</asp:Literal></h2>
            </div>
            <div class="stat-icon-wrapper icon-gold">
                <i class="fas fa-users"></i>
            </div>
        </div>
        
        <div class="stat-card" style="flex-direction: column; align-items: flex-start; justify-content: center; gap: 15px;">
            <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                <div class="stat-info">
                    <span>Avg. Passing Rate</span>
                    <h2><asp:Literal ID="litPassRate" runat="server">N/A</asp:Literal></h2>
                </div>
                <div class="stat-icon-wrapper icon-green">
                    <i class="fas fa-chart-line"></i>
                </div>
            </div>
            <a href="javascript:void(0);" class="rate-link" onclick="openModal('rateModal');">View Course Rates <i class="fas fa-arrow-right"></i></a>
        </div>
    </div>

    <div class="section-header">
        <h3 class="section-title">My Favourite Courses</h3>
    </div>

    <div class="courses-grid">
        <asp:Repeater ID="rptCourses" runat="server">
            <ItemTemplate>
                <div class="course-card" onclick="window.location.href='CourseHome.aspx?id=<%# Eval("course_id") %>'">
                    <div class="course-badge">Active</div>
                    <div class="course-img-container">
                        <img src='<%# GetImageSrc(Eval("course_img")) %>' alt="Course Image" onerror="this.src='Images/default-course.png';" />
                    </div>
                    <div class="course-info">
                        <div class="course-code"><%# Eval("course_code") %></div>
                        <h4 class="course-name"><%# Eval("course_name") %></h4>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <%-- Empty state --%>
        <div id="noFavsPanel" runat="server" style="display:flex; align-items:center; gap:10px; color:#94a3b8; font-size:14px; padding:20px 0;">
            <i class="far fa-star" style="font-size:1.4rem;"></i>
            <span>No favourite courses yet. Head to <a runat="server" href="~/Lecturer/LecturerCourses.aspx" style="color:#f59e0b;">Courses</a> and star the ones you want pinned here.</span>
        </div>
    </div>

    <div id="rateModal" class="modal-overlay">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Specific Course Passing Rates</h3>
                <button type="button" class="modal-close" onclick="closeModal('rateModal')">&times;</button>
            </div>
            <div class="modal-body">
                <table class="rate-table">
                    <thead>
                        <tr>
                            <th>Course Code</th>
                            <th>Course Name</th>
                            <th>Graded Students</th>
                            <th>Pass Rate</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptCourseRates" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%# Eval("course_code") %></strong></td>
                                    <td><%# Eval("course_name") %></td>
                                    <td><%# Eval("TotalGraded") %></td>
                                    <td style="font-weight:bold; color: var(--antique-gold);"><%# Eval("PassRateFormatted") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function openModal(id) {
            document.getElementById(id).style.display = 'flex';
        }
        function closeModal(id) {
            document.getElementById(id).style.display = 'none';
        }

        window.onclick = function (event) {
            var modal = document.getElementById('rateModal');
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>
</asp:Content>