<%@ Page Title="" Language="C#" MasterPageFile="~/LecturerCourseMaster.Master" AutoEventWireup="true"
    CodeBehind="LecturerGrades.aspx.cs" Inherits="SchoolSystem.Grades" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="grades-page">

        <!-- Print-only header -->
        <div class="print-header">
            <h1>Grades Report</h1>
            <p id="printSubtitle">Student Performance</p>
        </div>

        <!-- Header -->
        <div class="grades-header">
            <h2 id="gradesTitle">Grades</h2>
            <a href="#" class="btn-print" onclick="window.print(); return false;">
                <i class="fas fa-print"></i> Print Grades
            </a>
        </div>

        <!-- Filters -->
        <div class="filters-row">

            <!-- Searchable student picker -->
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
                <!-- Hidden real ASP.NET dropdown that owns the AutoPostBack -->
                <asp:DropDownList ID="ddlStudents" runat="server" CssClass="filter-select"
                    AutoPostBack="true" OnSelectedIndexChanged="ddlStudents_Changed"
                    style="display:none;">
                    <asp:ListItem Value="" Text="-- Select Student --" />
                </asp:DropDownList>
            </div>

            <!-- Search assignments -->
            <div class="filter-group">
                <label>Search Assignment</label>
                <div class="search-wrap">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchAssign" class="search-input"
                           placeholder="Search by name..." oninput="applyFilters()" />
                </div>
            </div>

            <!-- Sort -->
            <div class="filter-group">
                <label>Sort By</label>
                <div class="sort-group">
                    <button class="btn-sort active" id="sortName" onclick="setSort('name')">Name A&#8211;Z</button>
                    <button class="btn-sort" id="sortDueDate" onclick="setSort('due')">Due Date</button>
                </div>
            </div>
        </div>

        <!-- Placeholder -->
        <div id="placeholderState" class="placeholder-state">
            <i class="fas fa-user-graduate"></i>
            <p>Select a student above to view their grades.</p>
        </div>

        <!-- Table -->
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

        <!-- Empty state -->
        <div id="emptyState" class="empty-state hidden">
            <i class="fas fa-inbox"></i>
            <p>No assignments found for this student.</p>
        </div>

        <asp:HiddenField ID="hfGradeData" runat="server" />
    </div>

    <script>
        var allRows = [];
        var sortMode = localStorage.getItem('gradeSort') || 'name';

        /* ══════════════════════════════════════════════
           SEARCHABLE STUDENT DROPDOWN
        ══════════════════════════════════════════════ */
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

            /* Restore selected name after postback */
            window.addEventListener('DOMContentLoaded', function () {
                if (realDdl.value && realDdl.value !== '') {
                    display.value = realDdl.options[realDdl.selectedIndex].text;
                    display.classList.add('has-value');
                }
            });
        })();

        /* ══════════════════════════════════════════════
           GRADES TABLE
        ══════════════════════════════════════════════ */
        window.addEventListener('DOMContentLoaded', function () {
            var raw = document.getElementById('<%= hfGradeData.ClientID %>').value;
            if (raw && raw !== '[]' && raw !== '') {
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

            placeholder.classList.add('hidden');

            if (rows.length === 0) {
                tableWrap.classList.add('hidden');
                emptyState.classList.remove('hidden');
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
                    var isLate = r.dueRaw && new Date(r.submittedAt) > new Date(r.dueRaw);
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
        }
    </script>
</asp:Content>