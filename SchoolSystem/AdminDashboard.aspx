<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SchoolSystem.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stats-row { display: flex; gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 25px; border-radius: 15px; flex: 1; box-shadow: 0 4px 10px rgba(0,0,0,0.05); text-align: center; border-bottom: 5px solid #4a69bd; }
        .stat-card h3 { color: #888; font-size: 12px; margin: 0; text-transform: uppercase; letter-spacing: 1px; }
        .stat-card .num { font-size: 36px; font-weight: bold; color: #2c3e50; display: block; margin-top: 10px; }

        .dashboard-grid { display: grid; grid-template-columns: 1.2fr 1fr; gap: 25px; }
        .panel { background: white; padding: 25px; border-radius: 15px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .panel h3 { margin-top: 0; color: #2c3e50; border-bottom: 1px solid #eee; padding-bottom: 15px; font-size: 18px; }

        .list-item { display: block; padding: 12px; border-bottom: 1px solid #f9f9f9; text-decoration: none; color: inherit; transition: 0.2s; border-radius: 8px; }
        .list-item:hover { background: #f0f4ff; color: #4a69bd; }
        .list-item strong { display: block; font-size: 14px; }
        .list-item small { color: #999; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="stats-row">
        <div class="stat-card"><h3>Total Students</h3><span class="num"><asp:Literal ID="litStudents" runat="server" /></span></div>
        <div class="stat-card"><h3>Total Lecturers</h3><span class="num"><asp:Literal ID="litLecturers" runat="server" /></span></div>
        <div class="stat-card"><h3>Total Courses</h3><span class="num"><asp:Literal ID="litCourses" runat="server" /></span></div>
    </div>

    <div class="dashboard-grid">
        <div class="panel">
            <h3>Student Program Distribution</h3>
            <div style="height: 350px; position: relative;">
                <canvas id="progChart"></canvas>
            </div>
        </div>

        <div class="panel">
            <h3>Latest Announcements</h3>
            <asp:Repeater ID="rptAnnouncements" runat="server">
                <ItemTemplate>
                    <a href="AnnouncementManagement.aspx" class="list-item">
                        <strong><%# Eval("title") %></strong>
                        <small><%# Eval("created_at", "{0:MMM dd, yyyy}") %></small>
                    </a>
                </ItemTemplate>
            </asp:Repeater>

            <h3 style="margin-top: 30px;">Upcoming Schedule</h3>
            <asp:Repeater ID="rptSchedule" runat="server">
                <ItemTemplate>
                    <a href="CalendarManagement.aspx" class="list-item">
                        <strong><%# Eval("event_title") %></strong>
                        <small>📅 <%# Eval("start_date", "{0:MMM dd}") %></small>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <script>
        const ctx = document.getElementById('progChart').getContext('2d');
        new Chart(ctx, {
            type: 'pie',
            data: {
                labels: <%= ChartLabels %>,
                datasets: [{ 
                    data: <%= ChartData %>,
                    backgroundColor: ['#4a69bd', '#1abc9c', '#f1c40f', '#e67e22', '#e74c3c', '#9b59b6']
                }]
            },
            options: { maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });
    </script>
</asp:Content>