<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SchoolSystem.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="dashboard-page">
        <div class="header">
            <h1><i class="fas fa-th-large me-2"></i>Dashboard</h1>
        </div>
        <div class="dashboard-wrapper">
            <div class="stats-row">
                <div class="stat-card stat-students">
                    <div class="stat-info">
                        <span class="stat-label">Students</span>
                        <div class="stat-value"><asp:Literal ID="litStudents" runat="server" /></div>
                    </div>
                    <div class="icon-box"><i class="fas fa-user-graduate"></i></div>
                </div>
                <div class="stat-card stat-lecturers">
                    <div class="stat-info">
                        <span class="stat-label">Lecturers</span>
                        <div class="stat-value"><asp:Literal ID="litLecturers" runat="server" /></div>
                    </div>
                    <div class="icon-box"><i class="fas fa-chalkboard-teacher"></i></div>
                </div>
                <div class="stat-card stat-courses">
                    <div class="stat-info">
                        <span class="stat-label">Courses</span>
                        <div class="stat-value"><asp:Literal ID="litCourses" runat="server" /></div>
                    </div>
                    <div class="icon-box"><i class="fas fa-book"></i></div>
                </div>
            </div>

            <div class="dashboard-grid">
                <div class="panel">
                    <div class="panel-title">Program Distribution</div>
                    <div class="chart-wrapper"><canvas id="progChart"></canvas></div>
                </div>

                <div class="panel">
                    <div class="hub-header">
                        <div class="hub-tabs">
                            <asp:LinkButton ID="btnShowAnnounce" runat="server" OnClick="btnShowAnnounce_Click" CssClass="tab-btn active">Announcements</asp:LinkButton>
                            <asp:LinkButton ID="btnShowCalendar" runat="server" OnClick="btnShowCalendar_Click" CssClass="tab-btn">Calendar</asp:LinkButton>
                            <input type="text" id="hubSearch" class="search-box" placeholder="Search items..." onkeyup="filterHub()" />
                        </div>
                        <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" CssClass="sort-dropdown">
                            <asp:ListItem Text="Newest First" Value="DESC" />
                            <asp:ListItem Text="Oldest First" Value="ASC" />
                        </asp:DropDownList>
                    </div>

                    <table class="hub-table" id="hubTable">
                        <asp:Repeater ID="rptHub" runat="server">
                            <ItemTemplate>
                                <tr class="hub-row" 
                                    data-id='<%# Eval("ID") %>'
                                    data-type='<%# Eval("Type") %>' 
                                    data-date='<%# Eval("DisplayDate", "{0:yyyy-MM-dd}") %>'
                                    onclick="handleInteractiveClick(this)">
                                    <td>
                                        <div style="display:flex; align-items:center;">
                                            <span class="row-title"><%# Eval("Title") %></span>
                                            <span class="dash-tag tag-<%# Eval("Type") %>"><%# Eval("Type") %></span>
                                        </div>
                                    </td>
                                    <td class="item-date"><%# Eval("DisplayDate", "{0:MMM dd}") %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </table>
                </div>
            </div>
        </div>

        <script>
            // Real-time Hub Filter
            function filterHub() {
                let val = document.getElementById("hubSearch").value.toLowerCase();
                let rows = document.querySelectorAll("#hubTable .hub-row");
                rows.forEach(row => {
                    let text = row.querySelector(".row-title").innerText.toLowerCase();
                    row.style.display = text.includes(val) ? "" : "none";
                });
            }

            // Click Logic: Navigate directly to Detail Pages
            function handleInteractiveClick(row) {
                const type = row.getAttribute('data-type');
                const id = row.getAttribute('data-id');
                const date = row.getAttribute('data-date');

                if (type === 'Announce') {
                    // Redirects to AdminAnnouncementDetail.aspx using the specific announcement ID
                    window.location.href = '<%= ResolveUrl("~/Admin/AdminAnnouncementDetail.aspx?id=") %>' + id;
                } else {
                    // Redirects to the Calendar page
                    window.location.href = '<%= ResolveUrl("~/Admin/Calendar.aspx?date=") %>' + date;
                }
            }

            // Animated Chart Initialization
            document.addEventListener("DOMContentLoaded", function() {
                const ctx = document.getElementById('progChart').getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: <%= ChartLabels %>,
                        datasets: [{
                            data: <%= ChartData %>,
                            backgroundColor: ['#2b3558', '#c5a059', '#7d8aff', '#94a3b8', '#e2e8f0'],
                            hoverOffset: 15,
                            borderWidth: 4,
                            borderColor: '#ffffff'
                        }]
                    },
                    options: {
                        maintainAspectRatio: false,
                        cutout: '75%',
                        animation: { animateScale: true, animateRotate: true },
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: { usePointStyle: true, padding: 25, font: { weight: 'bold', size: 13 } }
                            },
                            tooltip: {
                                backgroundColor: '#2c3e50',
                                padding: 15,
                                cornerRadius: 8,
                                titleFont: { size: 14 },
                                bodyFont: { size: 14 },
                                callbacks: { label: (c) => ` ${c.label}: ${c.raw} Students` }
                            }
                        }
                    }
                });
            });
        </script>
    </div>
</asp:Content>