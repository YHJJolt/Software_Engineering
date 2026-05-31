<%@ Page Title="" Language="C#" MasterPageFile="~/Lecturer/LecturerCourseMaster.Master" AutoEventWireup="true"
    CodeBehind="LecturerGrades.aspx.cs" Inherits="SchoolSystem.Grades" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="~/Lecturer/LecturerGrades.css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="grades-page">

        <div class="print-header">
            <h1>Grades Report</h1>
            <p id="printSubtitle">Student Performance</p>
        </div>

        <div class="grades-header">
            <h2 id="gradesTitle">Grades</h2>
            <a href="#" class="btn-print" onclick="window.print(); return false;">
                <i class="fas fa-print"></i> Print Grades
            </a>
        </div>

        <div class="filters-row">

            <div class="filter-group">
                <label>Student</label>
                <div class="student-search-wrap" id="studentSearchWrap">
                    <input type="text" id="studentDisplay" class="student-search-input"
                           placeholder="-- Select Student --" readonly
                           onclick="toggleStudentDropdown(event)" />
                    <i class="fas fa-chevron-down student-caret" id="studentCaret"></i>
                    <div class="student-dropdown" id="studentDropdown">
                        <input type="text" id="studentSearchBox" class="student-dropdown-search"
                               placeholder="Search student..." autocomplete="off"
                               oninput="filterStudentOptions()" />
                        <div class="student-options-list" id="studentOptionsList"></div>
                    </div>
                </div>
                <asp:DropDownList ID="ddlStudents" runat="server" CssClass="filter-select"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlStudents_Changed"
                    style="display:none;">
                    <asp:ListItem Value="" Text="-- Select Student --" />
                </asp:DropDownList>
            </div>

            <div class="filter-group">
                <label>Search Assignment</label>
                <div class="search-wrap">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchAssign" class="search-input"
                           placeholder="Search by name..." oninput="applyFilters()" />
                </div>
            </div>

            <div class="filter-group">
                <label>Sort By</label>
                <div class="sort-group">
                    <button class="btn-sort active" id="sortName" onclick="setSort('name')">Name A&#8211;Z</button>
                    <button class="btn-sort" id="sortDueDate" onclick="setSort('due')">Due Date</button>
                </div>
            </div>
        </div>

        <div id="perfBanner" class="perf-banner perf-banner-none hidden">

            <div class="perf-left" id="perfLeft">
                <div class="perf-label">Performance</div>
                <div class="perf-pill-row">
                    <div id="perfPill" class="perf-status-pill perf-pill-none">
                        <i class="fas fa-circle-info"></i>
                        <span id="perfPillText">No data</span>
                    </div>
                    <div class="perf-legend">
                        <span><span class="perf-legend-dot perf-legend-dot-excellent"></span>Excellent 90–100%</span>
                        <span><span class="perf-legend-dot perf-legend-dot-good"></span>Good 70–89%</span>
                        <span><span class="perf-legend-dot perf-legend-dot-average"></span>Average 60–69%</span>
                        <span><span class="perf-legend-dot perf-legend-dot-atrisk"></span>At Risk 50–59%</span>
                        <span><span class="perf-legend-dot perf-legend-dot-fail"></span>Fail 0–49%</span>
                    </div>
                </div>
            </div>

            <div class="perf-divider"></div>

            <div class="perf-right">
                <div class="perf-metric-row">
                    <div class="perf-metric-label">Graded only</div>
                    <div class="perf-bar-track">
                        <div class="perf-bar-fill perf-bar-none" id="perfBarGraded" style="width:0%"></div>
                    </div>
                    <div class="perf-metric-value" id="perfValGraded">—</div>
                    <div class="perf-metric-sub" id="perfSubGraded"></div>
                </div>

                <div class="perf-metric-row">
                    <div class="perf-metric-label">Overall total</div>
                    <div class="perf-bar-track">
                        <div class="perf-bar-fill perf-bar-none" id="perfBarOverall" style="width:0%"></div>
                    </div>
                    <div class="perf-metric-value" id="perfValOverall">—</div>
                    <div class="perf-metric-sub" id="perfSubOverall"></div>
                </div>
            </div>
        </div>

        <div id="placeholderState" class="placeholder-state">
            <i class="fas fa-user-graduate"></i>
            <p>Select a student above to view their grades.</p>
        </div>

        <div id="tableWrap" class="table-wrap hidden">
            <table class="grades-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Due</th>
                        <th>Submitted</th>
                        <th>Score</th>
                    </tr>
                </thead>
                <tbody id="gradesBody"></tbody>
                <tfoot>
                    <tr class="total-row" id="totalRow">
                        <td colspan="3"><strong>Assignments Total</strong></td>
                        <td id="totalScoreCell">&#8212;</td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <div id="emptyState" class="empty-state hidden">
            <i class="fas fa-inbox"></i>
            <p id="emptyMsg">This student has no grades or assignments yet.</p>
        </div>

        <asp:HiddenField ID="hfGradeData" runat="server" />
    </div>

    <script>
        var allRows = [];
        var sortMode = localStorage.getItem('gradeSort') || 'name';

        (function () {
            var wrap = document.getElementById('studentSearchWrap');
            var display = document.getElementById('studentDisplay');
            var dropdown = document.getElementById('studentDropdown');
            var searchBox = document.getElementById('studentSearchBox');
            var listEl = document.getElementById('studentOptionsList');
            var caret = document.getElementById('studentCaret');
            var realDdl = document.getElementById('<%= ddlStudents.ClientID %>');

            function buildOptions(filter) {
                filter = (filter || '').toLowerCase().trim();
                listEl.innerHTML = '';
                var opts = realDdl.options;
                var found = 0;
                for (var i = 0; i < opts.length; i++) {
                    var opt = opts[i];
                    if (opt.value === '') continue;
                    if (filter && opt.text.toLowerCase().indexOf(filter) === -1) continue;
                    var div = document.createElement('div');
                    div.className = 'student-option' +
                        (opt.value === realDdl.value && realDdl.value !== '' ? ' selected' : '');
                    div.textContent = opt.text;
                    div.dataset.value = opt.value;
                    div.addEventListener('click', function () {
                        selectStudent(this.dataset.value, this.textContent);
                    });
                    listEl.appendChild(div);
                    found++;
                }
                if (found === 0) {
                    var none = document.createElement('div');
                    none.className = 'student-option no-results';
                    none.textContent = 'No students found.';
                    listEl.appendChild(none);
                }
            }

            function selectStudent(value, text) {
                realDdl.value = value;
                display.value = text;
                display.classList.add('has-value');
                closeDropdown();
                document.getElementById('printSubtitle').textContent =
                    'Student Performance \u2014 ' + text.toUpperCase();
                __doPostBack(realDdl.name, '');
            }

            function openDropdown() {
                buildOptions('');
                dropdown.classList.add('open');
                caret.classList.add('open');
                searchBox.value = '';
                setTimeout(function () { searchBox.focus(); }, 50);
            }
            function closeDropdown() {
                dropdown.classList.remove('open');
                caret.classList.remove('open');
            }

            window.toggleStudentDropdown = function (e) {
                if (e) e.stopPropagation();
                dropdown.classList.contains('open') ? closeDropdown() : openDropdown();
            };
            window.filterStudentOptions = function () { buildOptions(searchBox.value); };
            document.addEventListener('click', function (e) {
                if (!wrap.contains(e.target)) closeDropdown();
            });

            window.addEventListener('DOMContentLoaded', function () {
                if (realDdl.value && realDdl.value !== '') {
                    display.value = realDdl.options[realDdl.selectedIndex].text;
                    display.classList.add('has-value');
                }
            });
        })();

        function getTier(pct) {
            if (pct >= 90) return { key: 'excellent', label: 'Excellent', icon: 'fa-circle-check' };
            if (pct >= 70) return { key: 'good', label: 'Good', icon: 'fa-thumbs-up' };
            if (pct >= 60) return { key: 'average', label: 'Average', icon: 'fa-minus-circle' };
            if (pct >= 50) return { key: 'atrisk', label: 'At Risk \u2014 action needed', icon: 'fa-triangle-exclamation' };
            return { key: 'fail', label: 'Fail \u2014 action needed', icon: 'fa-circle-exclamation' };
        }

        function updatePerformanceBanner(gradedScore, gradedMax, overallScore, overallMax, gradedCount) {
            var banner = document.getElementById('perfBanner');
            var pill = document.getElementById('perfPill');
            var pillText = document.getElementById('perfPillText');

            var barGraded = document.getElementById('perfBarGraded');
            var valGraded = document.getElementById('perfValGraded');
            var subGraded = document.getElementById('perfSubGraded');
            var barOverall = document.getElementById('perfBarOverall');
            var valOverall = document.getElementById('perfValOverall');
            var subOverall = document.getElementById('perfSubOverall');

            banner.classList.remove('hidden');

            var gradedPct = gradedMax > 0 ? (gradedScore / gradedMax) * 100 : null;
            var overallPct = overallMax > 0 ? (overallScore / overallMax) * 100 : null;
            var tierPct = gradedPct !== null ? gradedPct : (overallPct !== null ? overallPct : null);

            ['excellent', 'good', 'average', 'atrisk', 'fail', 'none'].forEach(function (k) {
                banner.classList.remove('perf-banner-' + k);
                pill.classList.remove('perf-pill-' + k);
                barGraded.classList.remove('perf-bar-' + k);
                barOverall.classList.remove('perf-bar-' + k);
            });

            if (tierPct === null) {
                banner.classList.add('perf-banner-none');
                pill.classList.add('perf-pill-none');
                pill.innerHTML = '<i class="fas fa-circle-info"></i><span>No graded data</span>';
                barGraded.classList.add('perf-bar-none');
                barOverall.classList.add('perf-bar-none');
                barGraded.style.width = '0%';
                barOverall.style.width = '0%';
                valGraded.textContent = '—';
                valOverall.textContent = '—';
                subGraded.textContent = '';
                subOverall.textContent = '';
                return;
            }

            var tier = getTier(tierPct);

            banner.classList.add('perf-banner-' + tier.key);
            pill.classList.add('perf-pill-' + tier.key);
            pill.innerHTML = '<i class="fas ' + tier.icon + '"></i><span>' + tier.label + '</span>';

            barGraded.classList.add('perf-bar-' + tier.key);
            barOverall.classList.add('perf-bar-' + tier.key);

            if (gradedPct !== null) {
                barGraded.style.width = Math.min(gradedPct, 100).toFixed(1) + '%';
                valGraded.textContent = gradedPct.toFixed(1) + '%';
                subGraded.textContent = 'Based on ' + gradedCount + ' graded assignment' + (gradedCount === 1 ? '' : 's');
            } else {
                barGraded.style.width = '0%';
                valGraded.textContent = '—';
                subGraded.textContent = 'No graded assignments yet';
            }

            if (overallPct !== null) {
                barOverall.style.width = Math.min(overallPct, 100).toFixed(1) + '%';
                valOverall.textContent = overallPct.toFixed(1) + '%';
                subOverall.textContent = overallScore.toFixed(1) + ' / ' + overallMax + ' including unsubmitted';
            } else {
                barOverall.style.width = '0%';
                valOverall.textContent = '—';
                subOverall.textContent = '';
            }
        }

        window.addEventListener('DOMContentLoaded', function () {
            var raw = document.getElementById('<%= hfGradeData.ClientID %>').value;
            if (raw && raw !== '') {
                allRows = JSON.parse(raw);
                document.getElementById('sortDueDate').classList.toggle('active', sortMode === 'due');
                document.getElementById('sortName').classList.toggle('active', sortMode === 'name');
                renderTable();
            }
        });

        function setSort(mode) {
            sortMode = mode;
            localStorage.setItem('gradeSort', mode);
            document.getElementById('sortDueDate').classList.toggle('active', mode === 'due');
            document.getElementById('sortName').classList.toggle('active', mode === 'name');
            renderTable();
        }

        function applyFilters() { renderTable(); }

        function renderTable() {
            var q = document.getElementById('searchAssign').value.toLowerCase().trim();
            var rows = allRows.filter(function (r) {
                return !q || r.title.toLowerCase().includes(q);
            });

            rows.sort(function (a, b) {
                if (sortMode === 'name') return a.title.localeCompare(b.title);
                if (!a.dueRaw && !b.dueRaw) return 0;
                if (!a.dueRaw) return 1;
                if (!b.dueRaw) return -1;
                return new Date(a.dueRaw) - new Date(b.dueRaw);
            });

            var placeholder = document.getElementById('placeholderState');
            var tableWrap = document.getElementById('tableWrap');
            var emptyState = document.getElementById('emptyState');
            var body = document.getElementById('gradesBody');

            var realDdl = document.getElementById('<%= ddlStudents.ClientID %>');
            if (!realDdl.value || realDdl.value === '') {
                placeholder.classList.remove('hidden');
                tableWrap.classList.add('hidden');
                emptyState.classList.add('hidden');
                document.getElementById('perfBanner').classList.add('hidden');
                return;
            } else {
                placeholder.classList.add('hidden');
            }

            if (rows.length === 0) {
                tableWrap.classList.add('hidden');
                var msg = document.getElementById('emptyMsg');
                msg.textContent = allRows.length === 0
                    ? 'This student has no grades or assignments yet.'
                    : 'No assignments match your search.';
                emptyState.classList.remove('hidden');
                computeAndUpdateBanner([]);
                return;
            }

            emptyState.classList.add('hidden');
            tableWrap.classList.remove('hidden');

            var totalScore = 0, totalMax = 0, hasAnyScore = false;
            body.innerHTML = rows.map(function (r) {
                var scoreHtml;
                if (r.score !== null && r.score !== '') {
                    var s = parseFloat(r.score);
                    totalScore += s;
                    totalMax += parseInt(r.maxScore);
                    hasAnyScore = true;
                    scoreHtml = '<span class="score-cell">' + s.toFixed(1) +
                        ' <span class="score-max">/ ' + r.maxScore + '</span></span>';
                } else {
                    totalMax += parseInt(r.maxScore);
                    scoreHtml = '<span class="score-none">\u2014</span>';
                }

                var subBadge = '', subDate = '';
                if (r.submittedAt) {
                    var isLate = r.dueRaw && new Date(r.submittedRaw) > new Date(r.dueRaw);
                    subBadge = isLate
                        ? '<span class="badge badge-late">Late</span>'
                        : '<span class="badge badge-submitted">Submitted</span>';
                    subDate = '<div class="date-cell">' + r.submittedAt + '</div>';
                } else {
                    subBadge = '<span class="badge badge-missing">Not Submitted</span>';
                }

                var dueHtml = r.due
                    ? '<div class="date-cell">' + r.due + '</div>'
                    : '<span class="score-none">\u2014</span>';
                return '<tr>' +
                    '<td><span class="assign-name">' + r.title + '</span>' +
                    '<span class="assign-type">' + r.type + '</span></td>' +
                    '<td>' + dueHtml + '</td>' +
                    '<td>' + subBadge + subDate + '</td>' +
                    '<td>' + scoreHtml + '</td>' +
                    '</tr>';
            }).join('');

            var pct = totalMax > 0 ? ((totalScore / totalMax) * 100).toFixed(1) + '%' : '\u2014';
            document.getElementById('totalScoreCell').innerHTML =
                '<span class="total-score">' +
                (hasAnyScore ? totalScore.toFixed(1) + ' / ' + totalMax : '\u2014 / ' + totalMax) +
                '</span>' +
                (hasAnyScore ? '<span class="total-pct">(' + pct + ')</span>' : '');

            computeAndUpdateBanner(allRows);
        }

        function computeAndUpdateBanner(data) {
            var gradedScore = 0, gradedMax = 0, gradedCount = 0;
            var overallMax = 0, overallScore = 0;

            data.forEach(function (r) {
                var max = parseInt(r.maxScore) || 0;
                overallMax += max;

                if (r.score !== null && r.score !== '') {
                    var s = parseFloat(r.score);
                    gradedScore += s;
                    gradedMax += max;
                    overallScore += s;
                    gradedCount++;
                }
            });

            updatePerformanceBanner(gradedScore, gradedMax, overallScore, overallMax, gradedCount);
        }
    </script>
</asp:Content>