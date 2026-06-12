<%@ Page Title="Results & Grades" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentAllGrades.aspx.cs" Inherits="SchoolSystem.StudentAllGrades" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        @media print {
            body * { visibility: hidden !important; }
            #printable-area, #printable-area * { visibility: visible !important; }
            #printable-area {
                position: absolute;
                left: 0; top: 0;
                width: 100%;
                padding: 32px 40px !important;
                box-sizing: border-box;
            }
            .grades-toolbar, .print-modal-overlay { display: none !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<div class="grades-page" id="printable-area">

    <!-- Print header (hidden on screen, shown when printing) -->
    <div class="print-header" id="printHeader">
        <h2>Results &amp; Grades Report</h2>
        <p id="printSubtitle"></p>
    </div>

    <!-- Toolbar -->
    <div class="grades-toolbar">
        <div style="display:flex;align-items:center;gap:12px;">
            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="sem-select"
                AutoPostBack="true"
                OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
            </asp:DropDownList>
        </div>
        <button type="button" class="btn-export-pdf" onclick="openPrintModal()">
            <i class="fas fa-file-pdf"></i> Export PDF
        </button>
    </div>

    <!-- Stat cards -->
    <div class="grades-stats">
        <div class="gstat-card gold">
            <div class="gstat-label">Semester GPA</div>
            <div class="gstat-value"><asp:Literal ID="litSemGPA" runat="server">—</asp:Literal></div>
        </div>
        <div class="gstat-card purple">
            <div class="gstat-label">Cumulative CGPA</div>
            <div class="gstat-value"><asp:Literal ID="litCGPA" runat="server">—</asp:Literal></div>
        </div>
        <div class="gstat-card blue">
            <div class="gstat-label">Credit Hours</div>
            <div class="gstat-value"><asp:Literal ID="litCredits" runat="server">0</asp:Literal></div>
        </div>
    </div>

    <!-- Table -->
    <div class="table-card">
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-graduation-cap"></i>
            <p>No grade records found for this semester.</p>
        </asp:Panel>

        <asp:Panel ID="pnlTable" runat="server">
            <table class="grades-table">
                <thead>
                    <tr>
                        <th>Course Code</th>
                        <th>Course Name</th>
                        <th>Credit Hours</th>
                        <th>Score (%)</th>
                        <th>Grade</th>
                        <th>Point</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptGrades" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><span class="code-badge"><%# Eval("course_code") %></span></td>
                                <td class="course-name-link"><%# Eval("course_name") %></td>
                                <td><%# Eval("credit_hours") %></td>
                                <td class="score-cell">
                                    <div class="score-bar-wrap">
                                        <span class="score-text"><%# Eval("score_pct") %>%</span>
                                        <div class="score-bar-bg">
                                            <div class="score-bar-fill"
                                                style="width:<%# Eval("score_pct") %>%;
                                                       background:<%# GetBarColor(Eval("score_pct").ToString()) %>;">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td><span class="grade-letter <%# GetGradeClass(Eval("letter_grade").ToString()) %>"><%# Eval("letter_grade") %></span></td>
                                <td><%# Eval("grade_point") %></td>
                                <td><span class="status-badge <%# GetStatusClass(Eval("score_pct").ToString(), Eval("letter_grade").ToString()) %>"><%# GetStatusText(Eval("score_pct").ToString(), Eval("letter_grade").ToString()) %></span></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
            <div class="table-footer">
                Total Credit Hours: <strong><asp:Literal ID="litFooterCredits" runat="server">0</asp:Literal></strong>
            </div>
        </asp:Panel>
    </div>

</div>

<!-- Print modal -->
<div class="print-modal-overlay" id="printModalOverlay" onclick="closePrintModal(event)">
    <div class="print-modal">
        <div class="print-modal-header">
            <h3><i class="fas fa-file-pdf"></i> Export Results &amp; Grades</h3>
            <button class="print-modal-close" onclick="closePrintModalDirect()"><i class="fas fa-times"></i></button>
        </div>
        <div class="print-modal-preview">
            <strong>Student:</strong> <span id="modalStudentName">—</span><br/>
            <strong>Semester:</strong> <span id="modalSemester">—</span><br/>
            <strong>Semester GPA:</strong> <span id="modalGPA">—</span> &nbsp;|&nbsp;
            <strong>CGPA:</strong> <span id="modalCGPA">—</span><br/>
            <strong>Total Credit Hours:</strong> <span id="modalCredits">—</span>
        </div>
        <div class="print-modal-actions">
            <button class="btn-print-cancel" onclick="closePrintModalDirect()">Cancel</button>
            <button class="btn-print-confirm" onclick="confirmPrint()">
                <i class="fas fa-print"></i> Save as PDF
            </button>
        </div>
    </div>
</div>

<script>
    // ── Student info passed from code-behind for the modal ──
    var gradeStudentName = '<%= StudentName %>';
    var gradeSemLabel    = '<%= SemesterLabel %>';
    var gradeSemGPA = document.getElementById ? document.querySelector('.gstat-card.gold .gstat-value')?.textContent : '—';
    var gradeCGPA = document.getElementById ? document.querySelector('.gstat-card.purple .gstat-value')?.textContent : '—';
    var gradeCredits = document.getElementById ? document.querySelector('.gstat-card.blue .gstat-value')?.textContent : '—';

    function openPrintModal() {
        document.getElementById('modalStudentName').textContent = gradeStudentName;
        document.getElementById('modalSemester').textContent = gradeSemLabel;
        document.getElementById('modalGPA').textContent = document.querySelector('.gstat-card.gold .gstat-value').textContent;
        document.getElementById('modalCGPA').textContent = document.querySelector('.gstat-card.purple .gstat-value').textContent;
        document.getElementById('modalCredits').textContent = document.querySelector('.gstat-card.blue .gstat-value').textContent;
        document.getElementById('printModalOverlay').classList.add('active');
    }

    function closePrintModal(e) {
        if (e.target === document.getElementById('printModalOverlay'))
            document.getElementById('printModalOverlay').classList.remove('active');
    }

    function closePrintModalDirect() {
        document.getElementById('printModalOverlay').classList.remove('active');
    }

    function confirmPrint() {
        closePrintModalDirect();
        document.getElementById('printSubtitle').textContent =
            gradeStudentName + ' — ' + gradeSemLabel;
        window.print();
    }
</script>

</asp:Content>
