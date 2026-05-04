<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SchoolSystem.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stats-row { display:flex; gap:20px; margin-bottom:30px; }
        
        .stat-card {
            background: #ffffff; /* Elevated White Card */
            padding: 25px; border-radius: 12px; flex: 1;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 4px 15px rgba(18, 20, 32, 0.05);
            border-bottom: 3px solid var(--antique-gold);
        }
        
        .stat-label { color: rgba(18, 20, 32, 0.5); font-size: 11px; text-transform: uppercase; font-weight: 800; letter-spacing: 1px; }
        .stat-value { color: var(--navy-accent); font-size: 32px; font-weight: 800; margin-top: 5px; }
        .stat-icon { font-size: 24px; color: var(--soft-glow); opacity: 0.8; }

        .dashboard-grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 25px; }
        
        .panel { 
            background: #ffffff; 
            padding: 30px; border-radius: 12px;
            box-shadow: 0 4px 20px rgba(18, 20, 32, 0.05);
            color: var(--navy-accent);
        }
        .panel-title { 
            font-size: 14px; font-weight: 700; color: var(--navy-accent); 
            text-transform: uppercase; margin-bottom: 25px; 
            border-bottom: 2px solid var(--antique-gold); padding-bottom: 10px; 
        }

        .hub-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .tab-btn { background: none; border: none; color: rgba(18, 20, 32, 0.4); font-weight: 700; cursor: pointer; font-size: 15px; margin-right: 20px; text-decoration:none; }
        .tab-btn.active { color: var(--navy-accent); border-bottom: 3px solid var(--antique-gold); padding-bottom: 5px; }
        
        .hub-table { width: 100%; border-collapse: collapse; }
        .hub-table td { padding: 18px 10px; border-bottom: 1px solid rgba(18, 20, 32, 0.05); color: var(--navy-accent); font-size: 14px; font-weight: 600; }
        .item-date { text-align: right; color: rgba(18, 20, 32, 0.4); font-size: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="stats-row">
        <div class="stat-card">
            <div><div class="stat-label">Students</div><div class="stat-value"><asp:Literal ID="litStudents" runat="server" /></div></div>
            <i class="fas fa-user-graduate stat-icon"></i>
        </div>
        <div class="stat-card">
            <div><div class="stat-label">Lecturers</div><div class="stat-value"><asp:Literal ID="litLecturers" runat="server" /></div></div>
            <i class="fas fa-chalkboard-teacher stat-icon"></i>
        </div>
        <div class="stat-card">
            <div><div class="stat-label">Courses</div><div class="stat-value"><asp:Literal ID="litCourses" runat="server" /></div></div>
            <i class="fas fa-book stat-icon"></i>
        </div>
    </div>

    <div class="dashboard-grid">
        <div class="panel">
            <div class="panel-title">Program Distribution</div>
            <div style="height: 350px;"><canvas id="progChart"></canvas></div>
        </div>
        <div class="panel">
            <div class="hub-header">
                <div>
                    <asp:LinkButton ID="btnShowAnnounce" runat="server" OnClick="btnShowAnnounce_Click" CssClass="tab-btn active">Announcements</asp:LinkButton>
                    <asp:LinkButton ID="btnShowCalendar" runat="server" OnClick="btnShowCalendar_Click" CssClass="tab-btn">Calendar</asp:LinkButton>
                </div>
                <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" BackColor="#ffffff" ForeColor="#121420" BorderStyle="None" Font-Size="12px">
                    <asp:ListItem Text="Newest" Value="DESC" />
                    <asp:ListItem Text="Oldest" Value="ASC" />
                </asp:DropDownList>
            </div>
            <table class="hub-table">
                <asp:Repeater ID="rptHub" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><i class="fas fa-chevron-right" style="color:var(--antique-gold); font-size:10px; margin-right:12px;"></i> <%# Eval("Title") %></td>
                            <td class="item-date"><%# Eval("DisplayDate", "{0:MMM dd}") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </table>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const ctx = document.getElementById('progChart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: <%= ChartLabels %>,
                    datasets: [{
                        data: <%= ChartData %>,
                        backgroundColor: ['#121420', '#c5a059', '#7d8aff', '#94a3b8', '#e2e8f0'],
                        borderWidth: 5, borderColor: '#ffffff'
                    }]
                },
                options: {
                    maintainAspectRatio: false, cutout: '80%',
                    plugins: { legend: { position: 'bottom', labels: { color: '#121420', usePointStyle: true, padding: 25 } } }
                }
            });
        });
    </script>
</asp:Content>