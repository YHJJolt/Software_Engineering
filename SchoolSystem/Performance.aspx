<%@ Page Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="performance.aspx.cs" Inherits="YourApp.Performance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Student Performance</title>
    <style>
        *{box-sizing:border-box;margin:0;padding:0}
        .pg{background:#f5f0e8;padding:20px;border-radius:12px;font-family:sans-serif}
        .card{background:#fff;border-radius:12px;border:0.5px solid #e0dbd0;padding:16px 20px;margin-bottom:14px}
        .header-card { min-height: 180px; display: flex; flex-direction: column; }
        .picker-row { display: flex; align-items: center; gap: 10px; padding-bottom: 12px; margin-bottom: 12px; border-bottom: 0.5px solid #f0ebe0; }
        .picker-label { font-size: 11px; color: #999; text-transform: uppercase; letter-spacing: .4px; white-space: nowrap; }
        .student-picker { padding: 7px 12px; border: 0.5px solid #d0c9b8; border-radius: 6px; font-size: 13px; background: #fff; color: #1a2238; min-width: 200px; cursor: pointer; }
        .student-picker:focus { outline: none; border-color: #1a2238; }
        .top-row { display: flex; width: 100%; align-items: center; justify-content: space-between; }
        .top-left { flex: 1; padding-right: 20px; border-right: 0.5px solid #e8e3d8; display: flex; flex-direction: column; gap: 8px; }
        .top-mid { flex: 1.2; padding: 0 20px; border-right: 0.5px solid #e8e3d8; display: flex; flex-direction: column; align-items: center; text-align: center; }
        .top-right { flex: 1.5; padding-left: 20px; display: flex; flex-direction: column; gap: 12px; align-items: flex-end; }
        .info-group { display: flex; align-items: baseline; gap: 10px; }
        .info-label { font-size: 11px; color: #999; text-transform: uppercase; letter-spacing: .4px; width: 100px; flex-shrink: 0; }
        .info-val { font-size: 13px; color: #1a2238; font-weight: 500; }
        .info-val.large { font-size: 13px; font-weight: 600; }
        .status-pill { display: inline-block; padding: 6px 16px; border-radius: 6px; font-size: 11px; font-weight: 700; text-transform: uppercase; border: 1px solid transparent; }
        .stat-good { background: #ecfdf5; color: #059669; border-color: #10b981; }
        .stat-warn { background: #fffbeb; color: #92400e; border-color: #f59e0b; }
        .stat-crit { background: #fef2f2; color: #dc2626; border-color: #ef4444; }
        .stat-na   { background: #f3f4f6; color: #6b7280; border-color: #9ca3af; }
        .stat-grid-horizontal { display: flex; gap: 10px; width: 100%; }
        .stat-box { background: #fcfaf7; border: 1px solid #f0ebe0; border-radius: 8px; padding: 10px; text-align: center; flex: 1; display: flex; flex-direction: column; justify-content: center; }
        .stat-label { font-size: 9px; color: #888; text-transform: uppercase; margin-bottom: 4px; }
        .stat-val { font-size: 18px; font-weight: 700; color: #1a2238; }
        select { width: 100%; padding: 8px 10px; border: 0.5px solid #d0c9b8; border-radius: 6px; font-size: 13px; background: #fff; color: #1a2238; }
        .section-title { position: relative; min-height: 35px; display: flex; justify-content: space-between; align-items: center; border-bottom: 0.5px solid #f0ebe0; padding-bottom: 8px; margin-bottom: 10px; font-size: 12px; font-weight: 500; }
        .title-center { position: absolute; left: 50%; transform: translateX(-50%); font-weight: 700; color: #1a2238; white-space: nowrap; }
        .course-row { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 0.5px solid #f8f5ef; font-size: 13px; }
        .badge { font-size: 11px; padding: 3px 10px; border-radius: 12px; font-weight: 500; }
        .b-green { background: #e8f4ec; color: #2a7a45; }
        .b-blue { background: #e8f0fb; color: #1a5fa0; }
        .b-purple { background: #f3e8ff; color: #6b21a8; }
        .b-amber { background: #fffbeb; color: #92400e; }
        .b-red { background: #fef2f2; color: #dc2626; }
        .chart-container { position: relative; padding: 35px 10px 0 35px; border-bottom: 2px solid #e8e3d8; margin: 20px 0 50px 10px; background: #fff; min-height: 200px; }
        .chart-container::before { content: ''; position: absolute; left: -2px; top: 10px; bottom: 0; width: 2px; background: #e8e3d8; }
        .grid-line { position: absolute; left: 0; right: 0; border-top: 1px dashed #eee; z-index: 1; }
        .chart-wrap { position: relative; z-index: 2; height: 160px; display: flex; align-items: flex-end; justify-content: space-around; width: 100%; }
        .bar-grp { flex: 1; position: relative; height: 160px; max-width: 120px; display: flex; flex-direction: column; align-items: center; }
        .lbl { position: absolute; top: 100%; font-size: 10px; color: #888; padding-top: 6px; text-align: center; width: 100%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .yl { position: absolute; left: -32px; font-size: 10px; color: #999; font-weight: 600; width: 28px; text-align: right; }
        .tab-row { display: flex; gap: 8px; margin-bottom: 14px; justify-content: space-between; align-items: center; }
        .tb { padding: 6px 16px; border-radius: 20px; border: 0.5px solid #d0c9b8; font-size: 12px; cursor: pointer; background: #fff; color: #666; }
        .tb.on { background: #1a2238; color: #fff; border-color: #1a2238; }
        .hidden { display: none !important; }
        .btn-export { background: #1a2238; color: white; border: none; padding: 8px 18px; border-radius: 20px; font-size: 12px; font-weight: 500; cursor: pointer; display: flex; align-items: center; gap: 8px; }
        .bar-wrap { position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; height: 100%; width: 100%; }
        .tip { visibility: hidden; background: #1a2238; color: #fff; padding: 5px 8px; border-radius: 4px; position: absolute; bottom: 105%; left: 50%; transform: translateX(-50%); font-size: 10px; white-space: nowrap; z-index: 100; pointer-events: none; }
        .bar-wrap:hover .tip { visibility: visible; }
        .legend { display: flex; justify-content: center; gap: 20px; margin-top: 10px; font-size: 11px; color: #666; flex-wrap: wrap; }
        .leg-item { display: flex; align-items: center; gap: 6px; }
        .leg-box { width: 12px; height: 12px; border-radius: 3px; }
        .no-data { text-align: center; padding: 30px; color: #aaa; font-size: 13px; }

        /* ── Print report title ────────────────────────────────────── */
        .print-title { display: none; text-align: center; padding: 18px 0 10px; margin-bottom: 4px; }
        .print-title-text { font-size: 18px; font-weight: 700; color: #1a2238; letter-spacing: .5px; }
        .print-title-sub { font-size: 11px; color: #999; margin-top: 3px; text-transform: uppercase; letter-spacing: .6px; }

        /* ── Section card titles ───────────────────────────────────── */
        .section-card-title { font-size: 13px; font-weight: 700; color: #1a2238; letter-spacing: .3px; text-transform: uppercase; }

        /* ── Grade Distribution Panel ──────────────────────────────── */
        .grade-dist-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; width: 100%; padding: 0 4px; }
        .grade-dist-row { display: flex; align-items: center; gap: 8px; background: #fcfaf7; border: 1px solid #f0ebe0; border-radius: 8px; padding: 8px 10px; }
        .grade-dist-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }
        .grade-dist-info { display: flex; flex-direction: column; flex: 1; min-width: 0; text-align: left; }
        .grade-dist-name { font-size: 11px; font-weight: 600; color: #1a2238; line-height: 1.2; }
        .grade-dist-range { font-size: 9px; color: #999; }
        .grade-dist-count { font-size: 16px; font-weight: 700; color: #1a2238; min-width: 20px; text-align: right; }
        .grade-dist-label { font-size: 9px; color: #999; white-space: nowrap; }

        /* ── Print / Export to PDF ─────────────────────────────────── */
        @media print {
            @page {
                margin: 0;
            }

            .header-card {
                min-height: auto !important;
                margin-bottom: 10px !important;
            }

            /* Hide chrome */
            #sidebar,
            .tab-row,
            .picker-row,
            #semFilterWrap,
            .tip,
            .btn-export { display: none !important; }

            /* Remove sidebar offset */
            #main-content { margin-left: 0 !important; padding: 10px !important; }

            /* Force background colours to print */
            body { background: #f5f0e8 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }

            /* Keep inactive tab hidden */
            .hidden { display: none !important; }

            /* Hide the attendance colour-key hint line */
            #enrollMid div:last-child { display: none !important; }

            /* Prevent cards splitting across pages */
            .card { border: 0.5px solid #e0dbd0 !important; box-shadow: none !important; break-inside: avoid; }

            .pg { padding-top: 50px !important; }

            /* Ensure bar colours print */
            * { -webkit-print-color-adjust: exact; print-color-adjust: exact; }

            /* Print report title banner */
            .print-title { display: block !important; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="pg">
    <div class="tab-row">
        <div>
            <button type="button" class="tb on" id="tb1" onclick="sw('enroll')">Enrollment Statistics</button>
            <button type="button" class="tb" id="tb2" onclick="sw('grades')">Grades</button>
        </div>
        <button type="button" class="btn-export" onclick="window.print()">
            <i class="fas fa-file-pdf"></i> Export to PDF
        </button>
    </div>

    <div id="printable-area">

        <!-- ══ PRINT-ONLY TITLE — sits above everything ══ -->
        <div class="print-title" id="printTitleBlock">
            <div class="print-title-text" id="printTitleText"></div>
            <div class="print-title-sub" id="printTitleSub"></div>
        </div>

        <div class="card header-card">

            <!-- ══ STUDENT PICKER ROW ══ -->
            <div class="picker-row">
                <span class="picker-label">Viewing Student:</span>
                <select class="student-picker" id="studentPicker" onchange="switchStudent(this.value)"></select>
            </div>

            <!-- ══ STUDENT INFO ROW ══ -->
            <div class="top-row">
                <div class="top-left">
                    <div class="info-group"><div class="info-label">Student Name:</div><div class="info-val large" id="studentName">—</div></div>
                    <div class="info-group"><div class="info-label">Student ID:</div><div class="info-val" id="studentID">—</div></div>
                    <div class="info-group"><div class="info-label">Programme:</div><div class="info-val" id="studentProg">—</div></div>
                    <div class="info-group"><div class="info-label">Semester:</div><div class="info-val" id="semesterDisplay">—</div></div>
                </div>

                <div class="top-mid">
                    <div id="enrollMid" style="display: flex; flex-direction: column; align-items: center;">
                        <div class="info-label" style="width:auto; margin-bottom:12px;">Attendance Status</div>
                        <div id="statusIndicator" class="status-pill stat-good">GOOD</div>
                        <div style="font-size:10px; color:#888; margin-top:10px;">🟢 Good (≥ 80%) | 🟡 Warning (70-79%) | 🔴 Critical (< 70%)</div>
                    </div>
                    <div id="gradeMid" style="display: none; flex-direction: column; align-items: center; width: 100%;">
                        <div class="info-label" style="width:auto; margin-bottom:12px; letter-spacing:.6px;">Overall Grade Distribution</div>
                        <div class="grade-dist-grid">
                            <div class="grade-dist-row">
                                <div class="grade-dist-dot" style="background:#4a3fa0;"></div>
                                <div class="grade-dist-info">
                                    <span class="grade-dist-name">Excellent</span>
                                    <span class="grade-dist-range">≥ 3.7</span>
                                </div>
                                <div class="grade-dist-count" id="gdExc">—</div>
                                <div class="grade-dist-label">courses</div>
                            </div>
                            <div class="grade-dist-row">
                                <div class="grade-dist-dot" style="background:#1a5fa0;"></div>
                                <div class="grade-dist-info">
                                    <span class="grade-dist-name">Good</span>
                                    <span class="grade-dist-range">3.0 – 3.6</span>
                                </div>
                                <div class="grade-dist-count" id="gdGood">—</div>
                                <div class="grade-dist-label">courses</div>
                            </div>
                            <div class="grade-dist-row">
                                <div class="grade-dist-dot" style="background:#c9a84c;"></div>
                                <div class="grade-dist-info">
                                    <span class="grade-dist-name">Average</span>
                                    <span class="grade-dist-range">2.0 – 2.9</span>
                                </div>
                                <div class="grade-dist-count" id="gdAvg">—</div>
                                <div class="grade-dist-label">courses</div>
                            </div>
                            <div class="grade-dist-row">
                                <div class="grade-dist-dot" style="background:#dc2626;"></div>
                                <div class="grade-dist-info">
                                    <span class="grade-dist-name">Poor</span>
                                    <span class="grade-dist-range">< 2.0</span>
                                </div>
                                <div class="grade-dist-count" id="gdPoor">—</div>
                                <div class="grade-dist-label">courses</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="top-right">
                    <div id="enrollStats" style="width: 100%;">
                        <div class="stat-grid-horizontal">
                            <div class="stat-box"><div class="stat-label">Avg Attendance</div><div class="stat-val" id="eAttRate">—</div></div>
                            <div class="stat-box"><div class="stat-label">Total Credits</div><div class="stat-val" id="eTotalCredits">—</div></div>
                        </div>
                    </div>
                    <div id="gradeStats" class="hidden" style="width: 100%;">
                        <div class="stat-grid-horizontal">
                            <div class="stat-box"><div class="stat-label">Sem GPA</div><div class="stat-val" id="gSemGpaBox">—</div></div>
                            <div class="stat-box"><div class="stat-label">CGPA</div><div class="stat-val" id="gCgpaBox">—</div></div>
                        </div>
                    </div>
                    <div id="semFilterWrap" style="display: flex; flex-direction: column; width: 100%; margin-top: 5px; align-items: flex-start;">
                        <div class="info-label" style="margin-bottom: 4px; width: auto;">Filter Semester</div>
                        <select id="commonSemSel" onchange="unifiedChangeSem(this.value)"></select>
                    </div>
                </div>
            </div>
        </div>

        <!-- ══ ENROLLMENT VIEW ══════════════════════════════════════ -->
        <div id="vEnroll">
            <div class="card">
                <div class="section-title">
                    <span class="section-card-title">Enrolled Courses</span>
                    <span class="title-center">Semester <span id="eSecTitle">1</span></span>
                    <span id="eCountBadge" class="badge b-blue">0 Courses</span>
                </div>
                <div id="eCourseList"></div>
            </div>
            <div class="card">
                <div class="section-title">
                    <span class="section-card-title">Attendance Hours — Total vs Attended</span>
                </div>
                <div class="chart-container">
                    <div class="grid-line" style="bottom: 0px"></div>
                    <div class="grid-line" style="bottom: 53.3px"></div>
                    <div class="grid-line" style="bottom: 106.6px"></div>
                    <div class="grid-line" style="bottom: 160px"></div>
                    <span class="yl" style="bottom:160px">60h</span>
                    <span class="yl" style="bottom:106.6px">40h</span>
                    <span class="yl" style="bottom:53.3px">20h</span>
                    <span class="yl" style="bottom:0px">0h</span>
                    <div class="chart-wrap" id="eChart"></div>
                </div>
                <div class="legend">
                    <div class="leg-item"><div class="leg-box" style="background:#1a2238"></div>Total</div>
                    <div class="leg-item"><div class="leg-box" style="background:#c9a84c"></div>Attended</div>
                    <div class="leg-item"><div class="leg-box" style="background:#dc2626"></div>Critical</div>
                </div>
            </div>
        </div>

        <!-- ══ GRADES VIEW ═════════════════════════════════════════ -->
        <div id="vGrades" class="hidden">
            <div class="card">
                <div class="section-title">
                    <span class="section-card-title">Course Grades</span>
                    <span class="title-center">Semester <span id="gSecTitle">1</span></span>
                    <span id="gCountBadge" class="badge b-blue">0 Courses</span>
                </div>
                <div id="gCourseList"></div>
            </div>
            <div class="card">
                <div class="section-title">
                    <span class="section-card-title">Grade Point Distribution</span>
                </div>
                <div class="chart-container">
                    <div class="grid-line" style="bottom: 0px"></div>
                    <div class="grid-line" style="bottom: 80px"></div>
                    <div class="grid-line" style="bottom: 160px"></div>
                    <span class="yl" style="bottom:160px">4.0</span>
                    <span class="yl" style="bottom:80px">2.0</span>
                    <span class="yl" style="bottom:0px">0.0</span>
                    <div class="chart-wrap" id="gChart"></div>
                </div>
                <div class="legend">
                    <div class="leg-item"><div class="leg-box" style="background:#4a3fa0"></div>Excellent (≥ 3.7)</div>
                    <div class="leg-item"><div class="leg-box" style="background:#1a5fa0"></div>Good (3.0 – 3.6)</div>
                    <div class="leg-item"><div class="leg-box" style="background:#c9a84c"></div>Average (2.0 – 2.9)</div>
                    <div class="leg-item"><div class="leg-box" style="background:#dc2626"></div>Poor (< 2.0)</div>
                </div>
            </div>
        </div>
    </div><!-- end #printable-area -->
</div>

<script>
    var student = <%=StudentMetaJson%>;
    var semData = <%=StudentJsonData%>;
    var allStudents = <%=AllStudentsJson%>;
    var currentSid  = <%=SelectedStudentId%>;

    var badgeClass = {
        'A': 'b-purple', 'A-': 'b-purple',
        'B+': 'b-blue', 'B': 'b-blue',
        'C+': 'b-amber', 'C': 'b-amber',
        'D': 'b-red', 'F': 'b-red'
    };

    // ── Populate student picker ──────────────────────────────────────
    (function populatePicker() {
        var sel = document.getElementById('studentPicker');
        allStudents.forEach(function (s) {
            var opt = document.createElement('option');
            opt.value = s.id;
            opt.textContent = s.name;
            if (s.id === currentSid) opt.selected = true;
            sel.appendChild(opt);
        });
    })();

    function switchStudent(sid) {
        window.location.href = 'Performance.aspx?sid=' + sid;
    }

    // ── Init page data ───────────────────────────────────────────────
    (function init() {
        document.getElementById('studentName').textContent = student.name || '—';
        document.getElementById('studentID').textContent = student.id || '—';
        document.getElementById('studentProg').textContent = student.programme || '—';

        var sems = Object.keys(semData).sort(function (a, b) { return a - b; });
        var sel = document.getElementById('commonSemSel');

        if (sems.length === 0) {
            sel.innerHTML = '<option>No data</option>';
            document.getElementById('semesterDisplay').textContent = '—';
            document.getElementById('eCourseList').innerHTML = '<div class="no-data">No enrollment data found for this student.</div>';
            document.getElementById('gCourseList').innerHTML = '<div class="no-data">No grade data found for this student.</div>';
            document.getElementById('eChart').innerHTML = '';
            document.getElementById('gChart').innerHTML = '';
            document.getElementById('eAttRate').textContent = '—';
            document.getElementById('eTotalCredits').textContent = '—';
            var pill = document.getElementById('statusIndicator');
            pill.className = 'status-pill stat-na';
            pill.textContent = 'UNAVAILABLE';
            return;
        }

        sems.forEach(function (s) {
            var opt = document.createElement('option');
            opt.value = s; opt.textContent = 'Semester ' + s;
            sel.appendChild(opt);
        });

        var defaultSem = sems.includes(String(student.currentSem))
            ? String(student.currentSem)
            : sems[sems.length - 1];
        sel.value = defaultSem;
        unifiedChangeSem(defaultSem);
    })();

    // ── Semester change ──────────────────────────────────────────────
    function unifiedChangeSem(val) {
        var sem = parseInt(val);
        var d = semData[sem];
        if (!d) return;

        document.getElementById('semesterDisplay').textContent = sem;
        document.getElementById('eSecTitle').textContent = sem;
        document.getElementById('gSecTitle').textContent = sem;

        var count = d.courses.length;
        document.getElementById('eCountBadge').textContent = count + ' Courses';
        document.getElementById('gCountBadge').textContent = count + ' Courses';

        var totalCredits = d.credits.reduce(function (a, b) { return a + parseInt(b); }, 0);
        document.getElementById('eTotalCredits').textContent = totalCredits;

        var totalSched = d.total.reduce(function (a, b) { return a + parseInt(b); }, 0);
        var totalAtt = d.attended.reduce(function (a, b) { return a + parseInt(b); }, 0);
        var attRate = totalSched > 0 ? Math.round((totalAtt / totalSched) * 100) : 0;
        document.getElementById('eAttRate').textContent = attRate + '%';

        var pill = document.getElementById('statusIndicator');
        pill.className = 'status-pill';
        if (attRate >= 80) { pill.classList.add('stat-good'); pill.textContent = 'GOOD'; }
        else if (attRate >= 70) { pill.classList.add('stat-warn'); pill.textContent = 'WARNING'; }
        else { pill.classList.add('stat-crit'); pill.textContent = 'CRITICAL'; }

        var gpas = d.gpa.map(function (g) { return parseFloat(g); });
        var semGpa = gpas.length > 0 ? gpas.reduce(function (a, b) { return a + b; }, 0) / gpas.length : 0;
        document.getElementById('gSemGpaBox').textContent = semGpa.toFixed(2);

        // Grade distribution counts — totalled across ALL semesters
        var exc = 0, good = 0, avg = 0, poor = 0;
        Object.values(semData).forEach(function (sd) {
            sd.gpa.forEach(function (g) {
                var gp = parseFloat(g);
                if (gp >= 3.7) exc++;
                else if (gp >= 3.0) good++;
                else if (gp >= 2.0) avg++;
                else poor++;
            });
        });
        document.getElementById('gdExc').textContent = exc;
        document.getElementById('gdGood').textContent = good;
        document.getElementById('gdAvg').textContent = avg;
        document.getElementById('gdPoor').textContent = poor;

        var allGpa = [];
        Object.values(semData).forEach(function (sd) {
            sd.gpa.forEach(function (g) { allGpa.push(parseFloat(g)); });
        });
        var cgpa = allGpa.length > 0 ? allGpa.reduce(function (a, b) { return a + b; }, 0) / allGpa.length : 0;
        document.getElementById('gCgpaBox').textContent = cgpa.toFixed(2);

        buildEnrollCourses(d); buildEnrollChart(d);
        buildGradeCourses(d); buildGradeChart(d);
    }

    function buildEnrollCourses(d) {
        var el = document.getElementById('eCourseList');
        el.innerHTML = '';
        d.courses.forEach(function (c, i) {
            el.innerHTML += '<div class="course-row"><span>' + c + '</span><span class="badge b-green">' + d.credits[i] + ' cr</span></div>';
        });
    }

    function buildEnrollChart(d) {
        var ec = document.getElementById('eChart');
        ec.innerHTML = '';
        var axisMax = 60;
        d.courses.forEach(function (c, i) {
            var tH = (d.total[i] / axisMax) * 100;
            var aH = (d.attended[i] / axisMax) * 100;
            var rate = d.total[i] > 0 ? (d.attended[i] / d.total[i]) * 100 : 0;
            var attColor = rate < 70 ? '#dc2626' : '#c9a84c';
            var div = document.createElement('div');
            div.className = 'bar-grp';
            div.innerHTML =
                '<div style="position:absolute;bottom:0;display:flex;gap:4px;align-items:flex-end;justify-content:center;width:100%;height:100%;">' +
                '<div class="bar-wrap" style="height:' + tH + '%;width:14px;">' +
                '<div class="tip">Total: ' + d.total[i] + 'h</div>' +
                '<div style="width:14px;height:100%;background:#1a2238;border-radius:4px 4px 0 0;"></div>' +
                '</div>' +
                '<div class="bar-wrap" style="height:' + aH + '%;width:14px;">' +
                '<div class="tip">Attended: ' + d.attended[i] + 'h</div>' +
                '<div style="width:14px;height:100%;background:' + attColor + ';border-radius:4px 4px 0 0;"></div>' +
                '</div>' +
                '</div>' +
                '<div class="lbl">' + c + '</div>';
            ec.appendChild(div);
        });
    }

    function buildGradeCourses(d) {
        var el = document.getElementById('gCourseList');
        el.innerHTML = '';
        d.courses.forEach(function (c, i) {
            var bc = badgeClass[d.grades[i]] || 'b-blue';
            el.innerHTML += '<div class="course-row"><span>' + c + '</span><span class="badge ' + bc + '">' + d.grades[i] + ' (' + parseFloat(d.gpa[i]).toFixed(1) + ')</span></div>';
        });
    }

    function buildGradeChart(d) {
        var gc = document.getElementById('gChart');
        gc.innerHTML = '';
        var axisMax = 4.0;
        var getColor = function (gp) {
            if (gp >= 3.7) return '#4a3fa0';
            if (gp >= 3.0) return '#1a5fa0';
            if (gp >= 2.0) return '#c9a84c';
            return '#dc2626';
        };
        d.courses.forEach(function (c, i) {
            var gp = parseFloat(d.gpa[i]);
            var h = (gp / axisMax) * 100;
            var clr = getColor(gp);
            var div = document.createElement('div');
            div.className = 'bar-grp';
            div.innerHTML =
                '<div style="position:absolute;bottom:0;width:100%;height:100%;display:flex;flex-direction:column;justify-content:flex-end;align-items:center;">' +
                '<div class="bar-wrap" style="height:' + h + '%;width:28px;">' +
                '<div class="tip">Grade: ' + gp.toFixed(2) + '</div>' +
                '<div style="font-size:10px;font-weight:700;color:' + clr + ';position:absolute;bottom:100%;margin-bottom:4px;text-align:center;width:100%">' + gp.toFixed(1) + '</div>' +
                '<div style="height:100%;background:' + clr + ';width:28px;border-radius:4px 4px 0 0;"></div>' +
                '</div>' +
                '</div>' +
                '<div class="lbl">' + c + '</div>';
            gc.appendChild(div);
        });
    }

    // ── Tab switcher ────────────────────────────────────────────────
    function sw(t) {
        var isE = t === 'enroll';
        document.getElementById('vEnroll').classList.toggle('hidden', !isE);
        document.getElementById('vGrades').classList.toggle('hidden', isE);
        document.getElementById('enrollStats').classList.toggle('hidden', !isE);
        document.getElementById('gradeStats').classList.toggle('hidden', isE);
        document.getElementById('tb1').classList.toggle('on', isE);
        document.getElementById('tb2').classList.toggle('on', !isE);
        var eMid = document.getElementById('enrollMid');
        var gMid = document.getElementById('gradeMid');
        if (isE) { eMid.style.display = 'flex'; gMid.style.display = 'none'; }
        else { eMid.style.display = 'none'; gMid.style.display = 'flex'; }
    }

    // ── Set correct print title before browser prints ────────────────
    window.onbeforeprint = function () {
        var isEnroll = !document.getElementById('vEnroll').classList.contains('hidden');
        var name = student.name || '—';
        if (isEnroll) {
            document.getElementById('printTitleText').textContent = 'Enrollment Statistics Report';
            document.getElementById('printTitleSub').textContent = 'Student Performance — ' + name;
        } else {
            document.getElementById('printTitleText').textContent = 'Student Performance Report';
            document.getElementById('printTitleSub').textContent = 'Grade Summary — ' + name;
        }
    };
</script>
</asp:Content>
