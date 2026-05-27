<%@ Page Title="" Language="C#" MasterPageFile="~/LecturerMaster.Master" AutoEventWireup="true"
    CodeBehind="LecturerCourses.aspx.cs" Inherits="SchoolSystem.LecturerCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* ── Page ── */
        .courses-page { padding: 24px 28px; }

        /* ── Topbar ── */
        .courses-topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
        }
        .courses-topbar h2 {
            font-size: 1.4rem;
            font-weight: 600;
            color: #1e293b;
            margin: 0;
        }
        .topbar-controls { display: flex; align-items: center; gap: 10px; }

        /* ── Search ── */
        .search-wrap { position: relative; }
        .search-wrap i {
            position: absolute; left: 10px; top: 50%;
            transform: translateY(-50%);
            font-size: 14px; color: #94a3b8;
        }
        .search-wrap input {
            padding: 7px 12px 7px 32px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 13px;
            width: 210px;
            outline: none;
            background: #fff;
            color: #1e293b;
        }
        .search-wrap input:focus { border-color: #94a3b8; }

        /* ── View toggle ── */
        .view-toggle {
            display: flex;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            overflow: hidden;
        }
        .view-btn {
            background: #fff;
            border: none;
            padding: 7px 12px;
            cursor: pointer;
            color: #94a3b8;
            font-size: 16px;
            transition: background 0.15s;
            line-height: 1;
        }
        .view-btn.active { background: #f1f5f9; color: #334155; }

        /* ── Table ── */
        .table-wrap {
            background: #fff;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }
        .courses-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .courses-table thead tr { background: #f8fafc; border-bottom: 1px solid #e2e8f0; }
        .courses-table th {
            padding: 11px 14px;
            text-align: left;
            font-weight: 600;
            color: #64748b;
            white-space: nowrap;
            user-select: none;
        }
        .courses-table th.sortable { cursor: pointer; }
        .courses-table th.sortable:hover { color: #1e293b; }
        .sort-icon { margin-left: 4px; font-size: 11px; color: #cbd5e1; }
        .sort-icon.asc::after  { content: ' ▲'; }
        .sort-icon.desc::after { content: ' ▼'; }
        .sort-icon.none::after { content: ' ⇅'; }

        .courses-table tbody tr { border-bottom: 1px solid #f1f5f9; transition: background 0.12s; }
        .courses-table tbody tr:last-child { border-bottom: none; }
        .courses-table tbody tr:hover { background: #f8fafc; }
        .courses-table td { padding: 11px 14px; color: #334155; vertical-align: middle; }

        /* ── Star ── */
        .star-btn {
            background: none; border: none; cursor: pointer;
            font-size: 1rem; color: #cbd5e1; padding: 0;
            transition: color 0.2s, transform 0.15s; line-height: 1;
        }
        .star-btn:hover { transform: scale(1.2); }
        .star-btn.starred { color: #f59e0b; }

        /* ── Course dot ── */
        .course-dot {
            display: inline-block; width: 9px; height: 9px;
            border-radius: 50%; margin-right: 7px; flex-shrink: 0;
        }
        .dot-open { background: #22c55e; }
        .dot-ongoing { background: #f97316; }
        .dot-closed { background: #94a3b8; }

        .course-link { color: #3b82f6; text-decoration: none; display: inline-flex; align-items: center; }
        .course-link:hover { text-decoration: underline; }

        /* ── Badges ── */
        .badge-code {
            display: inline-block; padding: 2px 8px; border-radius: 20px;
            font-size: 11px; font-weight: 500;
            background: #f1f5f9; color: #475569;
        }
        .badge-role {
            display: inline-block; padding: 2px 9px; border-radius: 20px;
            font-size: 11px; font-weight: 500;
            background: #ede9fe; color: #7c3aed;
        }
        .badge-yes {
            display: inline-block; padding: 2px 9px; border-radius: 20px;
            font-size: 11px; font-weight: 500;
            background: #dcfce7; color: #16a34a;
        }
        .badge-no {
            display: inline-block; padding: 2px 9px; border-radius: 20px;
            font-size: 11px; font-weight: 500;
            background: #fee2e2; color: #dc2626;
        }
        .student-count { display: inline-flex; align-items: center; gap: 4px; font-size: 13px; color: #64748b; }
        .student-count i { font-size: 14px; }

        /* ── Grid ── */
        .grid-view {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 14px;
        }
        .course-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            overflow: hidden;
            cursor: pointer;
            transition: border-color 0.15s;
        }
        .course-card:hover { border-color: #94a3b8; }
        .card-img-wrap {
            width: 100%; height: 110px;
            background: #f1f5f9;
            display: flex; align-items: center; justify-content: center;
            font-size: 2.5rem; color: #cbd5e1;
            overflow: hidden;
        }
        .card-img-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .card-body { padding: 12px 14px; }
        .card-top {
            display: flex; align-items: center;
            justify-content: space-between; margin-bottom: 6px;
        }
        .card-name { font-size: 14px; font-weight: 600; color: #1e293b; margin-bottom: 8px; line-height: 1.3; }
        .card-meta { display: flex; flex-direction: column; gap: 5px; }
        .card-row {
            display: flex; align-items: center;
            justify-content: space-between; font-size: 12px; color: #64748b;
        }
        .card-row span { display: flex; align-items: center; gap: 4px; }
        .card-row i { font-size: 13px; }

        /* ── Empty ── */
        .empty-state { text-align: center; padding: 50px 20px; color: #94a3b8; }
        .empty-state i { font-size: 2rem; margin-bottom: 10px; display: block; }

        .hidden { display: none !important; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="courses-page">

        <div class="courses-topbar">
            <h2>All Courses</h2>
            <div class="topbar-controls">
                <div class="search-wrap">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Search courses..." oninput="applyFilters()" />
                </div>
                <div class="view-toggle">
                    <button type="button" class="view-btn active" id="btnTable" onclick="setView('table')" title="Table view">
                        <i class="fas fa-list"></i>
                    </button>
                    <button type="button" class="view-btn" id="btnGrid" onclick="setView('grid')" title="Grid view">
                        <i class="fas fa-th-large"></i>
                    </button>
                </div>
            </div>
        </div>

        <%-- TABLE VIEW --%>
        <div id="tableView" class="table-wrap">
            <table class="courses-table" id="coursesTable">
                <thead>
                    <tr>
                        <th class="sortable" style="width:46px;" onclick="sortBy('fav')" title="Sort by Favourite">
                            Favourite <span class="sort-icon none" id="sort-fav"></span>
                        </th>
                        <th class="sortable" onclick="sortBy('name')">
                            Course <span class="sort-icon none" id="sort-name"></span>
                        </th>
                        <th class="sortable" onclick="sortBy('code')">
                            Code <span class="sort-icon none" id="sort-code"></span>
                        </th>
                        <th class="sortable" onclick="sortBy('sem')">
                            Semester <span class="sort-icon none" id="sort-sem"></span>
                        </th>
                        <th class="sortable" onclick="sortBy('students')">
                            Students <span class="sort-icon none" id="sort-students"></span>
                        </th>
                        <th>Enrolled as</th>
                        <th class="sortable" onclick="sortBy('published')">
                            Published <span class="sort-icon none" id="sort-published"></span>
                        </th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                </tbody>
            </table>
        </div>

        <%-- GRID VIEW --%>
        <div id="gridView" class="grid-view hidden"></div>

        <%-- EMPTY STATE --%>
        <div id="emptyState" class="empty-state hidden">
            <i class="fas fa-book-open"></i>
            <p>No courses found.</p>
        </div>

        <%-- Hidden data island from server --%>
        <asp:HiddenField ID="hfCourseData" runat="server" />

    </div>

    <script>
        /* ── Data from server ── */
        var courses = JSON.parse(document.getElementById('<%= hfCourseData.ClientID %>').value || '[]');

        /* ── State ── */
        var currentView = localStorage.getItem('lcView') || 'table';
        var sortCol = null;
        var sortDir = {};

        /* ── Init ── */
        setView(currentView, true);
        render();

        /* ════════════════════════════════
           VIEW TOGGLE
        ════════════════════════════════ */
        function setView(v, silent) {
            currentView = v;
            if (!silent) localStorage.setItem('lcView', v);
            document.getElementById('btnTable').classList.toggle('active', v === 'table');
            document.getElementById('btnGrid').classList.toggle('active', v === 'grid');
            document.getElementById('tableView').classList.toggle('hidden', v !== 'table');
            document.getElementById('gridView').classList.toggle('hidden', v !== 'grid');
            render();
        }

        /* ════════════════════════════════
           SORT
        ════════════════════════════════ */
        var sortKeys = ['fav', 'name', 'code', 'sem', 'students', 'published'];

        function sortBy(col) {
            var cur = sortDir[col] || 'none';
            sortDir = {};
            if (cur === 'none') sortDir[col] = 'asc';
            else if (cur === 'asc') sortDir[col] = 'desc';
            else sortDir[col] = 'none';
            sortCol = sortDir[col] === 'none' ? null : col;
            updateSortIcons();
            render();
        }

        function updateSortIcons() {
            sortKeys.forEach(function (k) {
                var el = document.getElementById('sort-' + k);
                if (!el) return;
                var d = sortDir[k] || 'none';
                el.className = 'sort-icon ' + d;
            });
        }

        function getSortValue(c, col) {
            switch (col) {
                case 'fav':       return c.fav ? 0 : 1;
                case 'name':      return c.name.toLowerCase();
                case 'code':      return c.code.toLowerCase();
                case 'sem':       return c.semNum;
                case 'students':  return c.students;
                case 'published': return c.published ? 0 : 1;
                default:          return '';
            }
        }

        function getFiltered() {
            var q = document.getElementById('searchInput').value.toLowerCase().trim();
            var list = courses.filter(function (c) {
                return !q || c.name.toLowerCase().includes(q) || c.code.toLowerCase().includes(q);
            });

            if (sortCol) {
                var dir = sortDir[sortCol];
                list.sort(function (a, b) {
                    var av = getSortValue(a, sortCol);
                    var bv = getSortValue(b, sortCol);
                    if (typeof av === 'number') return dir === 'asc' ? av - bv : bv - av;
                    return dir === 'asc'
                        ? av.localeCompare(bv, undefined, { numeric: true })
                        : bv.localeCompare(av, undefined, { numeric: true });
                });
            }
            return list;
        }

        /* ════════════════════════════════
           RENDER
        ════════════════════════════════ */
        function applyFilters() { render(); }

        function render() {
            var list = getFiltered();
            var empty = list.length === 0;
            document.getElementById('emptyState').classList.toggle('hidden', !empty);
            renderTable(list);
            renderGrid(list);
        }

        /* ── Helpers ── */
        function dotClass(s) {
            return s === 'Open' ? 'dot-open' : s === 'Ongoing' ? 'dot-ongoing' : 'dot-closed';
        }
        function pubBadge(p) {
            return p ? '<span class="badge-yes">Yes</span>' : '<span class="badge-no">No</span>';
        }
        function starHtml(fav, id) {
            return '<button type="button" class="star-btn' + (fav ? ' starred' : '') + '" onclick="event.stopPropagation();toggleFav(this,' + id + ')" title="' + (fav ? 'Remove favourite' : 'Add favourite') + '">'
                + '<i class="' + (fav ? 'fas' : 'far') + ' fa-star"></i></button>';
        }

        /* ── Table ── */
        function renderTable(list) {
            var tv = document.getElementById('tableView');
            var tb = document.getElementById('tableBody');
            tv.classList.toggle('hidden', list.length === 0 || currentView !== 'table');
            tb.innerHTML = list.map(function (c) {
                return '<tr>'
                    + '<td style="text-align:center">' + starHtml(c.fav, c.id) + '</td>'
                    + '<td><span class="course-dot ' + dotClass(c.status) + '"></span>'
                    + '<a href="LecturerAnnouncement.aspx?id=' + c.id + '" class="course-link">' + c.name + '</a></td>'
                    + '<td><span class="badge-code">' + c.code + '</span></td>'
                    + '<td>' + c.sem + '</td>'
                    + '<td><span class="student-count"><i class="fas fa-users"></i>' + c.students + '</span></td>'
                    + '<td><span class="badge-role">Lecturer</span></td>'
                    + '<td>' + pubBadge(c.published) + '</td>'
                    + '</tr>';
            }).join('');
        }

        /* ── Grid ── */
        function renderGrid(list) {
            var gv = document.getElementById('gridView');
            gv.classList.toggle('hidden', list.length === 0 || currentView !== 'grid');
            gv.innerHTML = list.map(function (c) {
                var imgSrc = c.img ? c.img : 'Images/default-course.png';
                var imgHtml = '<img src="' + imgSrc + '" alt="' + c.name + '" onerror="this.src=\'Images/default-course.png\';" />';
                return '<div class="course-card" onclick="window.location.href=\'LecturerAnnouncement.aspx?id=' + c.id + '\'">'
                    + '<div class="card-img-wrap">' + imgHtml + '</div>'
                    + '<div class="card-body">'
                    + '<div class="card-top">'
                    + '<span class="badge-code">' + c.code + '</span>'
                    + starHtml(c.fav, c.id)
                    + '</div>'
                    + '<p class="card-name">' + c.name + '</p>'
                    + '<div class="card-meta">'
                    + '<div class="card-row">'
                    + '<span><i class="fas fa-users"></i>' + c.students + ' students</span>'
                    + '<span><i class="fas fa-calendar-alt"></i>' + c.sem + '</span>'
                    + '</div>'
                    + '<div class="card-row" style="margin-top:5px">'
                    + '<span class="badge-role">Lecturer</span>'
                    + pubBadge(c.published)
                    + '</div>'
                    + '</div>'
                    + '</div>'
                    + '</div>';
            }).join('');
        }

        /* ════════════════════════════════
           FAVOURITE TOGGLE (AJAX)
        ════════════════════════════════ */
        function toggleFav(btn, id) {
            var isFav = btn.classList.contains('starred');

            // Optimistic UI update — feels instant
            btn.classList.toggle('starred', !isFav);
            btn.querySelector('i').className = isFav ? 'far fa-star' : 'fas fa-star';
            btn.title = isFav ? 'Add favourite' : 'Remove favourite';

            // Update local data array so re-renders stay correct
            var course = courses.find(function (c) { return c.id === id; });
            if (course) course.fav = !isFav;

            // AJAX call to update database
            fetch('LecturerCourses.aspx/ToggleFavourite', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ courseId: id, email: '<%= Session["UserEmail"] %>' })
            })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    if (data.d === 'error') {
                        // Revert on failure
                        btn.classList.toggle('starred', isFav);
                        btn.querySelector('i').className = isFav ? 'fas fa-star' : 'far fa-star';
                        btn.title = isFav ? 'Remove favourite' : 'Add favourite';
                        if (course) course.fav = isFav;
                        alert('Failed to update favourite. Please try again.');
                    }
                })
                .catch(function () {
                    // Revert on network error
                    btn.classList.toggle('starred', isFav);
                    btn.querySelector('i').className = isFav ? 'fas fa-star' : 'far fa-star';
                    btn.title = isFav ? 'Remove favourite' : 'Add favourite';
                    if (course) course.fav = isFav;
                });
        }
    </script>
</asp:Content>