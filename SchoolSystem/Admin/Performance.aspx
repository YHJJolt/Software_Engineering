<%@ Page Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="performance.aspx.cs" Inherits="SchoolSystem.Performance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Student Performance</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
    <style>
        @media screen {
            #gradeMid        { display: none !important; }
            #gradeStats      { display: none !important; }
            #courseGradesCard { display: none !important; }
        }
        @media print {
            #gradeMid    { display: flex !important; }
            #gradeStats  { display: block !important; }
            #vGrades     { display: block !important; }
            #enrollMid   { display: none !important; }
            #enrollStats { display: none !important; }
            #vEnroll     { display: none !important; }
            .grade-chart-hide { display: none !important; }
            .performance-page > .header { display: none !important; }
        }
    </style>

</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="TopbarTitle" runat="server">
    <h1 style="margin: 0; font-size: 24px; color: #1e293b;">
        <i class="fas fa-chart-line" style="margin-right: 10px;"></i>Student Performance
    </h1>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="performance-page">
<div class="pg">
    <div class="tab-row">
        <div>
            <button type="button" class="tb on" id="tb1" onclick="sw('enroll')">Enrollment Statistics</button>
            <button type="button" class="tb" id="tb2" onclick="sw('grades')">Grades</button>
        </div>
        <button type="button" class="btn-export" id="btnExportPdf" onclick="window.print()" style="display:none;">
            <i class="fas fa-file-pdf"></i> Export to PDF
        </button>
    </div>

    <div id="printable-area">

        <div class="print-title" id="printTitleBlock">
            <div class="print-title-text" id="printTitleText"></div>
            <div class="print-title-sub" id="printTitleSub"></div>
        </div>

        <div class="card header-card">

            <div class="picker-row">
                <span class="picker-label">Viewing Student:</span>
                <select class="student-picker" id="studentPicker" onchange="switchStudent(this.value)"></select>
            </div>

            <div class="top-row">
                <div class="top-left">
                    <div class="info-group"><div class="info-label">Student Name:</div><div class="info-val large" id="studentName">—</div></div>
                    <div class="info-group"><div class="info-label">Student ID:</div><div class="info-val" id="studentID">—</div></div>
                    <div class="info-group"><div class="info-label">Programme:</div><div class="info-val" id="studentProg">—</div></div>
                    <%-- CHANGED to Session --%>
                    <div class="info-group"><div class="info-label">Session:</div><div class="info-val" id="semesterDisplay">—</div></div> 
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
                        <%-- CHANGED to Session --%>
                        <div class="info-label" style="margin-bottom: 4px; width: auto;">Filter Session</div>
                        <select id="commonSemSel" onchange="unifiedChangeSem(this.value)"></select>
                    </div>
                </div>
            </div>
        </div>

        <div id="vEnroll">
            <div class="card">
                <div class="section-title">
                    <span class="section-card-title">Enrolled Courses</span>
                    <%-- CHANGED to Session --%>
                    <span class="title-center">Session <span id="eSecTitle">...</span></span>
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

        <div id="vGrades" class="hidden">
            <div class="card" id="courseGradesCard">
                <div class="section-title">
                    <span class="section-card-title">Course Grades</span>
                    <%-- CHANGED to Session --%>
                    <span class="title-center">Session <span id="gSecTitle">...</span></span>
                    <span id="gCountBadge" class="badge b-blue">0 Courses</span>
                </div>
                <div id="gCourseList"></div>
            </div>
            <div class="card grade-chart-hide">
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
    </div></div>

<script>
// @ts-nocheck
var student = <%=StudentMetaJson%>;
    var semData = <%=StudentJsonData%>;
    var allStudents = <%=AllStudentsJson%>;
    var currentSid  = <%=SelectedStudentId%>;
    var allSessions = <%=AllSessionsJson%>;
    var currentSession = "<%=CurrentSession%>";
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

        var sel = document.getElementById('commonSemSel');

        // Build the filter from EVERY academic session in the system (ordered chronologically),
        // so the admin can switch sessions even when this student only has data in one of them.
        var sessions = (allSessions && allSessions.length) ? allSessions.slice() : Object.keys(semData);
        sessions.sort(function (a, b) { return sessionRank(a) - sessionRank(b); });

        if (sessions.length === 0) {
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

        sel.innerHTML = '';
        sessions.forEach(function (s) {
            var opt = document.createElement('option');
            opt.value = s; opt.textContent = s; // e.g. "APR2026"
            sel.appendChild(opt);
        });

        // Land on the student's most recent session that actually has data; otherwise
        // fall back to the global current session, then the newest session in the list.
        var withData = Object.keys(semData);
        withData.sort(function (a, b) { return sessionRank(a) - sessionRank(b); });
        var defaultSem = withData.length ? withData[withData.length - 1]
                        : (currentSession && sessions.indexOf(currentSession) !== -1 ? currentSession
                        : sessions[sessions.length - 1]);
        sel.value = defaultSem;
        unifiedChangeSem(defaultSem);
    })();

    // Ranks a session string chronologically (year, then JAN < APR < AUG).
    function sessionRank(s) {
        if (!s || s.length < 7) return 0;
        var order = { JAN: 0, APR: 1, AUG: 2 };
        var m = order[s.substring(0, 3).toUpperCase()];
        var y = parseInt(s.substring(3), 10);
        return (isNaN(y) ? 0 : y) * 3 + (m === undefined ? 0 : m);
    }

    // ── Session change ──────────────────────────────────────────────
    function unifiedChangeSem(val) {
        var sem = val; // keep as a string, e.g. "APR2026"

        document.getElementById('semesterDisplay').textContent = sem;
        document.getElementById('eSecTitle').textContent = sem;
        document.getElementById('gSecTitle').textContent = sem;

        var d = semData[sem];
        if (!d) {
            // This student has no enrolment data for the chosen session — show a clean empty state.
            document.getElementById('eCountBadge').textContent = '0 Courses';
            document.getElementById('gCountBadge').textContent = '0 Courses';
            document.getElementById('eTotalCredits').textContent = '—';
            document.getElementById('eAttRate').textContent = '—';
            document.getElementById('gSemGpaBox').textContent = '0.00';
            var na = document.getElementById('statusIndicator');
            na.className = 'status-pill stat-na';
            na.textContent = 'UNAVAILABLE';
            document.getElementById('eCourseList').innerHTML = '<div class="no-data">No enrolled courses for this session.</div>';
            document.getElementById('gCourseList').innerHTML = '<div class="no-data">No grade data for this session.</div>';
            document.getElementById('eChart').innerHTML = '';
            document.getElementById('gChart').innerHTML = '';
            return;
        }

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

        // Grabs the real GPA computed safely from the database!
        document.getElementById('gSemGpaBox').textContent = d.realGpa || '0.00';

        // Grade distribution counts — totalled across ALL sessions
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

        // Uses the true CGPA pulled directly from the Grades table!
        document.getElementById('gCgpaBox').textContent = student.cgpa || '0.00';

        buildEnrollCourses(d); buildEnrollChart(d);
        buildGradeCourses(d); buildGradeChart(d);
    }

    function buildEnrollCourses(d) {
        var el = document.getElementById('eCourseList');
        el.innerHTML = '';
        if (d.courses.length === 0) {
            el.innerHTML = '<div class="no-data">No enrolled courses for this session.</div>';
            return;
        }
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
        if (d.courses.length === 0) {
            el.innerHTML = '<div class="no-data">No grade data for this session.</div>';
            return;
        }
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


    // ── Set correct print title before browser prints ────────────────
    // ── Tab switcher ────────────────────────────────────────────────
    function sw(t) {
        var isE = t === 'enroll';
        document.getElementById('vEnroll').classList.toggle('hidden', !isE);
        document.getElementById('vGrades').classList.toggle('hidden', isE);
        document.getElementById('enrollStats').classList.toggle('hidden', !isE);
        document.getElementById('tb1').classList.toggle('on', isE);
        document.getElementById('tb2').classList.toggle('on', !isE);
        document.getElementById('enrollMid').style.display = isE ? 'flex' : 'none';
        document.getElementById('btnExportPdf').style.display = isE ? 'none' : '';
    }

    window.onbeforeprint = function () {
        var name = student.name || '—';
        document.getElementById('printTitleText').textContent = 'Student Performance Report';
        document.getElementById('printTitleSub').textContent = 'Grade Summary — ' + name.toUpperCase();
    };
</script>
</div>
</asp:Content>