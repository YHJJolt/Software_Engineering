<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/LecturerMaster.Master" AutoEventWireup="true" CodeBehind="LecturerDashboard.aspx.cs" Inherits="SchoolSystem.LecturerDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="stats-grid">
        <div class="stat-card">
            <span>Courses Assigned</span>
            <h2><asp:Literal ID="litCourseCount" runat="server">0</asp:Literal></h2>
        </div>
        <div class="stat-card">
            <span>Registered Students</span>
            <h2><asp:Literal ID="litStudentCount" runat="server">0</asp:Literal></h2>
        </div>
        <div class="stat-card">
            <span>Avg. Passing Rate (Excl. F)</span>
            <h2><asp:Literal ID="litPassRate" runat="server">N/A</asp:Literal></h2>
            <a href="javascript:void(0);" class="rate-link" onclick="openModal('rateModal');">View Specific Course Rates <i class="fas fa-arrow-right"></i></a>
        </div>
    </div>

    <h3 class="section-title">My Assigned Courses</h3>
    
    <div class="courses-grid">
        <asp:Repeater ID="rptCourses" runat="server">
            <ItemTemplate>
                <div class="course-card" onclick="window.location.href='ManageAttendance.aspx?id=<%# Eval("course_id") %>'">
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

        // Close modal if user clicks outside the white box
        window.onclick = function (event) {
            var modal = document.getElementById('rateModal');
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>
</asp:Content>