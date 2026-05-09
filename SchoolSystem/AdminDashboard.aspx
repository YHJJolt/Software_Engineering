<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SchoolSystem.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* 1. Stat Cards with Vibrant Gradients */
        .stats-row { display:flex; gap:20px; margin-bottom:30px; }
        
        .stat-card {
            padding: 25px; border-radius: 12px; flex: 1;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 8px 25px rgba(18, 20, 32, 0.08);
            border-bottom: 4px solid var(--antique-gold);
            transition: transform 0.3s ease;
        }
        .stat-card:hover { transform: translateY(-5px); }
        
        .stat-students { background: linear-gradient(135deg, #121420 0%, #2b3558 100%); }
        .stat-lecturers { background: linear-gradient(135deg, #c5a059 0%, #f1e4c7 100%); }
        .stat-courses { background: linear-gradient(135deg, #7d8aff 0%, #ced4ff 100%); }

        .stat-label { font-size: 11px; text-transform: uppercase; font-weight: 800; letter-spacing: 1.5px; margin-bottom: 5px; display: block; }
        .stat-value { font-size: 36px; font-weight: 900; }
        .stat-icon { font-size: 28px; opacity: 0.6; }

        .stat-students .stat-label { color: rgba(255, 255, 255, 0.7); }
        .stat-students .stat-value, .stat-students .stat-icon { color: #ffffff; }
        .stat-lecturers .stat-label, .stat-courses .stat-label { color: rgba(18, 20, 32, 0.5); }
        .stat-lecturers .stat-value, .stat-courses .stat-value { color: var(--navy-accent); }
        .stat-lecturers .stat-icon, .stat-courses .stat-icon { color: var(--navy-accent); }

        /* 2. Interactive Hub & Panels */
        .dashboard-grid { display: grid; grid-template-columns: 1fr 1.2fr; gap: 25px; }
        
        .panel { 
            background: #ffffff; padding: 30px; border-radius: 12px;
            box-shadow: 0 4px 20px rgba(18, 20, 32, 0.05); color: var(--navy-accent);
        }
        .panel-title { 
            font-size: 14px; font-weight: 700; color: var(--navy-accent); 
            text-transform: uppercase; margin-bottom: 25px; 
            border-bottom: 2px solid var(--antique-gold); padding-bottom: 10px; 
        }

        .hub-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        
        /* Search Bar Interaction */
        .search-box {
            background: var(--cream-base); border: 1px solid rgba(18, 20, 32, 0.1);
            border-radius: 20px; padding: 6px 15px; font-size: 12px;
            color: var(--navy-accent); outline: none; transition: 0.3s;
            width: 140px; margin-left: 15px;
        }
        .search-box:focus { width: 200px; border-color: var(--antique-gold); box-shadow: 0 0 10px rgba(197, 160, 89, 0.1); }

        .tab-btn { background: none; border: none; color: rgba(18, 20, 32, 0.4); font-weight: 700; cursor: pointer; font-size: 15px; margin-right: 15px; text-decoration:none; }
        .tab-btn.active { color: var(--navy-accent); border-bottom: 3px solid var(--antique-gold); padding-bottom: 5px; }
        
        .hub-table { width: 100%; border-collapse: collapse; }
        .hub-row { cursor: pointer; transition: 0.2s; }
        .hub-row:hover { background: rgba(125, 138, 255, 0.05); }
        .hub-table td { padding: 18px 10px; border-bottom: 1px solid rgba(18, 20, 32, 0.05); color: var(--navy-accent); font-size: 14px; font-weight: 600; }
        .item-date { text-align: right; color: rgba(18, 20, 32, 0.4); font-size: 12px; }

        .dash-tag { font-size: 9px; font-weight: 800; text-transform: uppercase; padding: 2px 8px; border-radius: 4px; margin-left: 10px; vertical-align: middle; }
        .tag-General { background: #e8f0fe; color: #1967d2; }
        .tag-Exam { background: #fce8e6; color: #d93025; }
        .tag-Holiday { background: #e6ffed; color: #1e8e3e; }
        .tag-Enrolment { background: #f3e8fd; color: #9334e6; }
        .tag-Announce { background: var(--cream-base); color: var(--antique-gold); border: 1px solid var(--antique-gold); }

        /* 3. Modern Announcement Modal */
        .preview-modal {
            display: none; position: fixed; z-index: 9999; left: 0; top: 0;
            width: 100%; height: 100%; background: rgba(18, 20, 32, 0.6); backdrop-filter: blur(5px);
        }
        .modal-body {
            background: #ffffff; margin: 10% auto; padding: 45px;
            width: 550px; border-radius: 15px; border-top: 6px solid var(--antique-gold);
            box-shadow: 0 25px 50px rgba(0,0,0,0.3); position: relative;
        }
        .modal-close { position: absolute; right: 25px; top: 20px; font-size: 28px; cursor: pointer; color: #ccc; transition: 0.2s; }
        .modal-close:hover { color: var(--navy-accent); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="stats-row">
        <div class="stat-card stat-students">
            <div><span class="stat-label">Students</span><div class="stat-value"><asp:Literal ID="litStudents" runat="server" /></div></div>
            <i class="fas fa-user-graduate stat-icon"></i>
        </div>
        <div class="stat-card stat-lecturers">
            <div><span class="stat-label">Lecturers</span><div class="stat-value"><asp:Literal ID="litLecturers" runat="server" /></div></div>
            <i class="fas fa-chalkboard-teacher stat-icon"></i>
        </div>
        <div class="stat-card stat-courses">
            <div><span class="stat-label">Courses</span><div class="stat-value"><asp:Literal ID="litCourses" runat="server" /></div></div>
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
                <div style="display:flex; align-items:center;">
                    <asp:LinkButton ID="btnShowAnnounce" runat="server" OnClick="btnShowAnnounce_Click" CssClass="tab-btn active">Announcements</asp:LinkButton>
                    <asp:LinkButton ID="btnShowCalendar" runat="server" OnClick="btnShowCalendar_Click" CssClass="tab-btn">Calendar</asp:LinkButton>
                    <input type="text" id="hubSearch" class="search-box" placeholder="Search items..." onkeyup="filterHub()" />
                </div>
                <asp:DropDownList ID="ddlSort" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged" BackColor="Transparent" BorderStyle="None" Font-Bold="True">
                    <asp:ListItem Text="Newest" Value="DESC" />
                    <asp:ListItem Text="Oldest" Value="ASC" />
                </asp:DropDownList>
            </div>

            <table class="hub-table" id="hubTable">
                <asp:Repeater ID="rptHub" runat="server">
                    <ItemTemplate>
                        <tr class="hub-row" 
                            data-type='<%# Eval("Type") %>' 
                            data-date='<%# Eval("DisplayDate", "{0:yyyy-MM-dd}") %>'
                            data-title='<%# Eval("Title") %>'
                            data-content='<%# Eval("Content") %>'
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

    <!-- Announcement Modal -->
    <div id="previewModal" class="preview-modal">
        <div class="modal-body">
            <span class="modal-close" onclick="closePreview()">&times;</span>
            <span id="pDate" style="font-size: 11px; font-weight: 800; color: var(--antique-gold); text-transform: uppercase;"></span>
            <h2 id="pTitle" style="color: var(--navy-accent); margin: 10px 0 25px 0; border-bottom: 2px solid var(--cream-base); padding-bottom: 12px;"></h2>
            <p id="pContent" style="color: #555; line-height: 1.8; font-size: 14px;"></p>
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

        // Click Logic: Preview or Navigate
        function handleInteractiveClick(row) {
            const type = row.getAttribute('data-type');
            const date = row.getAttribute('data-date');
            const title = row.getAttribute('data-title');
            const content = row.getAttribute('data-content');

            if (type === 'Announce') {
                document.getElementById('pTitle').innerText = title;
                document.getElementById('pContent').innerText = content || "No description available.";
                document.getElementById('pDate').innerText = "Posted on " + row.querySelector('.item-date').innerText;
                document.getElementById('previewModal').style.display = 'block';
            } else {
                window.location.href = 'Calendar.aspx?date=' + date;
            }
        }

        function closePreview() { document.getElementById('previewModal').style.display = 'none'; }

        // Animated Chart Initialization
        document.addEventListener("DOMContentLoaded", function() {
            const ctx = document.getElementById('progChart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: <%= ChartLabels %>,
                    datasets: [{
                        data: <%= ChartData %>,
                        backgroundColor: ['#121420', '#c5a059', '#7d8aff', '#94a3b8', '#e2e8f0'],
                        hoverOffset: 25, // Pops out segment on hover
                        borderWidth: 5, borderColor: '#ffffff'
                    }]
                },
                options: {
                    maintainAspectRatio: false, cutout: '78%',
                    animation: { animateScale: true, animateRotate: true },
                    plugins: {
                        legend: { position: 'bottom', labels: { usePointStyle: true, padding: 25, font: { weight: 'bold' } } },
                        tooltip: {
                            backgroundColor: '#121420', padding: 15,
                            callbacks: { label: (c) => ` ${c.label}: ${c.raw} Students` }
                        }
                    }
                }
            });
        });
    </script>
</asp:Content>