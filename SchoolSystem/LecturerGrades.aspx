<%@ Page Title="" Language="C#" MasterPageFile="~/LecturerCourseMaster.Master" AutoEventWireup="true"
    CodeBehind="Grades.aspx.cs" Inherits="SchoolSystem.Grades" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .grades-page { padding: 24px 32px; font-family: 'Segoe UI', sans-serif; }

        /* ── Header row ── */
        .grades-header {
            display: flex; align-items: center;
            justify-content: space-between; flex-wrap: wrap;
            gap: 12px; margin-bottom: 24px;
        }
        .grades-header h2 { font-size: 1.35rem; font-weight: 600; color: #1e293b; margin: 0; }
        .btn-print {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 16px; border-radius: 8px;
            border: 1px solid #e2e8f0; background: #fff;
            color: #475569; font-size: 13px; cursor: pointer;
            text-decoration: none; transition: background 0.15s;
        }
        .btn-print:hover { background: #f8fafc; }
        .btn-print i { font-size: 14px; }

        /* ── Filters row ── */
        .filters-row {
            display: flex; align-items: center;
            gap: 12px; margin-bottom: 20px; flex-wrap: wrap;
        }
        .filter-group { display: flex; flex-direction: column; gap: 4px; }
        .filter-group label { font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px; }

        .filter-select, .search-input {
            padding: 8px 12px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #1e293b; background: #fff;
            outline: none; min-width: 180px;
        }
        .filter-select:focus, .search-input:focus { border-color: #94a3b8; }

        /* ── Searchable student dropdown ── */
        .student-search-wrap { position: relative; min-width: 220px; }
        .student-search-input {
            width: 100%; padding: 8px 32px 8px 12px;
            border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 13px; color: #94a3b8; background: #fff;
            outline: none; box-sizing: border-box; cursor: pointer;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .student-search-input:focus { border-color: #94a3b8; }
        .student-search-input.has-value { color: #1e293b; }
        .student-caret {
            position: absolute; right: 10px; top: 50%;
            transform: translateY(-50%); pointer-events: none;
            font-size: 11px; color: #94a3b8; transition: transform 0.15s;
        }
        .student-caret.open { transform: translateY(-50%) rotate(180deg); }
        .student-dropdown {
            display: none; position: absolute; top: calc(100% + 4px); left: 0;
            width: 100%; background: #fff; border: 1px solid #e2e8f0;
            border-radius: 8px; box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            z-index: 999; max-height: 220px; overflow: hidden;
        }
        .student-dropdown.open { display: flex; flex-direction: column; }
        .student-dropdown-search {
            padding: 8px 10px; border: none; border-bottom: 1px solid #f1f5f9;
            width: 100%; font-size: 13px; outline: none; color: #1e293b;
            box-sizing: border-box; flex-shrink: 0;
        }
        .student-dropdown-search::placeholder { color: #94a3b8; }
        .student-options-list { overflow-y: auto; flex: 1; }
        .student-option {
            padding: 9px 14px; font-size: 13px; color: #334155;
            cursor: pointer; transition: background 0.1s;
        }
        .student-option:hover { background: #f8fafc; }
        .student-option.selected { background: #f1f5f9; font-weight: 600; color: #1e293b; }
        .student-option.no-results { color: #94a3b8; font-style: italic; cursor: default; }
        .student-option.no-results:hover { background: transparent; }

        .search-wrap { position: relative; }
        .search-wrap i { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); font-size: 13px; color: #94a3b8; }
        .search-wrap .search-input { padding-left: 32px; min-width: 200px; }

        .sort-group { display: flex; align-items: flex-end; gap: 8px; }
        .btn-sort {
            padding: 8px 14px; border-radius: 8px;
            border: 1px solid #e2e8f0; background: #fff;
            font-size: 13px; color: #475569; cursor: pointer;
            transition: background 0.15s; white-space: nowrap;
        }
        .btn-sort.active { background: #1e293b; color: #fff; border-color: #1e293b; }
        .btn-sort:hover:not(.active) { background: #f8fafc; }

        /* ── Table ── */
        .table-wrap {
            background: #fff; border-radius: 10px;
            border: 1px solid #e2e8f0; overflow: hidden; margin-bottom: 0;
        }
        .grades-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .grades-table thead tr { background: #f8fafc; border-bottom: 2px solid #e2e8f0; }
        .grades-table th { padding: 11px 16px; text-align: left; font-weight: 600; color: #64748b; white-space: nowrap; }
        .grades-table tbody tr { border-bottom: 1px solid #f1f5f9; transition: background 0.12s; }
        .grades-table tbody tr:last-child { border-bottom: none; }
        .grades-table tbody tr:hover { background: #f8fafc; }
        .grades-table td { padding: 12px 16px; color: #334155; vertical-align: middle; }

        .assign-name { font-weight: 500; color: #1e293b; display: block; margin-bottom: 2px; }
        .assign-type { font-size: 11px; color: #94a3b8; }
        .date-cell { font-size: 12px; color: #64748b; line-height: 1.5; }

        .badge { display: inline-block; padding: 2px 9px; border-radius: 20px; font-size: 11px; font-weight: 500; }
        .badge-submitted { background: #dcfce7; color: #16a34a; }
        .badge-late      { background: #fef9c3; color: #854d0e; }
        .badge-missing   { background: #fee2e2; color: #dc2626; }
        .badge-ungraded  { background: #f1f5f9; color: #64748b; }

        .score-cell { font-weight: 600; color: #1e293b; }
        .score-max  { font-size: 11px; color: #94a3b8; font-weight: 400; }
        .score-none { color: #cbd5e1; font-style: italic; }

        .total-row { background: #f8fafc !important; border-top: 2px solid #e2e8f0 !important; }
        .total-row td { font-weight: 700; color: #1e293b; padding: 14px 16px; }
        .total-score { font-size: 1rem; color: #1e293b; }
        .total-pct   { font-size: 13px; color: #64748b; font-weight: 500; margin-left: 6px; }

        .empty-state { text-align: center; padding: 60px 20px; color: #94a3b8; }
        .empty-state i { font-size: 2rem; display: block; margin-bottom: 10px; }

        .placeholder-state {
            text-align: center; padding: 80px 20px; color: #94a3b8;
            background: #fff; border-radius: 10px; border: 1px solid #e2e8f0;
        }
        .placeholder-state i { font-size: 2.5rem; display: block; margin-bottom: 12px; color: #e2e8f0; }

        .hidden { display: none !important; }
        .print-header { display: none; }

        @media print {
            @page { size: A4 portrait; margin: 0; }
            html, body { margin: 0 !important; padding: 0 !important; background: #fff !important; }
            #sidebar, #topbar, .filters-row, .btn-print,
            .placeholder-state, .empty-state { display: none !important; }
            #main-wrapper { margin-left: 0 !important; width: 100% !important; box-shadow: none !important; }
            #main-content  { padding: 0 !important; width: 100% !important; }
            .grades-page {
                padding: 18mm !important; width: auto !important;
                max-width: none !important; margin: 0 !important; box-sizing: border-box !important;
            }
            .print-header {
                display: block !important; text-align: center;
                margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #1e293b;
            }
            .print-header h1 { font-size: 18px; font-weight: 700; color: #1e293b; margin: 0 0 4px 0; letter-spacing: 0.3px; }
            .print-header p  { font-size: 11px; color: #64748b; margin: 0; text-transform: uppercase; letter-spacing: 1px; }
            .grades-header { display: none !important; }
            .table-wrap { width: 100% !important; border: 1px solid #cbd5e1 !important; border-radius: 0 !important; box-shadow: none !important; }
            .grades-table { width: 100% !important; font-size: 12px !important; }
            .grades-table th { background: #f8fafc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .total-row { background: #f8fafc !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .badge-submitted { color: #16a34a !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .badge-missing   { color: #dc2626 !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
