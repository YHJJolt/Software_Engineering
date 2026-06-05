<%@ Page Title="Grades" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master"
    AutoEventWireup="true" CodeBehind="StudentIndivGrades.aspx.cs" Inherits="SchoolSystem.StudentIndivGrades" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<asp:HiddenField ID="hfGradeData" runat="server" />

<div class="sig-page">

    <!-- Performance Banner -->
    <div class="sig-banner" id="sigBanner">
        <div class="sig-banner-left">
            <div class="sig-banner-label">My Performance</div>
            <div class="sig-status-pill" id="sigPill">
                <i class="fas fa-circle-info"></i> No data yet
            </div>
            <div class="sig-legend">
                <div class="sig-legend-row"><div class="sig-legend-dot dot-excellent"></div>Excellent 90–100%</div>
                <div class="sig-legend-row"><div class="sig-legend-dot dot-good"></div>Good 70–89%</div>
                <div class="sig-legend-row"><div class="sig-legend-dot dot-average"></div>Average 60–69%</div>
                <div class="sig-legend-row"><div class="sig-legend-dot dot-atrisk"></div>At Risk 50–59%</div>
                <div class="sig-legend-row"><div class="sig-legend-dot dot-fail"></div>Fail 0–49%</div>
            </div>
        </div>

        <div class="sig-banner-divider"></div>

        <div class="sig-banner-right">
            <div class="sig-metric">
                <div class="sig-metric-label">Graded only</div>
                <div class="sig-bar-track"><div class="sig-bar-fill" id="sigBarGraded" style="width:0%"></div></div>
                <div class="sig-metric-val" id="sigValGraded">—</div>
                <div class="sig-metric-sub" id="sigSubGraded"></div>
            </div>
            <div class="sig-metric">
                <div class="sig-metric-label">Overall total</div>
                <div class="sig-bar-track"><div class="sig-bar-fill" id="sigBarOverall" style="width:0%"></div></div>
                <div class="sig-metric-val" id="sigValOverall">—</div>
                <div class="sig-metric-sub" id="sigSubOverall"></div>
            </div>
        </div>
    </div>

    <!-- Toolbar -->
    <div class="sig-toolbar">
        <div class="sig-search-wrap">
            <i class="fas fa-search"></i>
            <input type="text" class="sig-search" id="sigSearch"
                   placeholder="Search assignments..." oninput="renderTable()" />
        </div>
        <div class="sig-sort-group">
            <button class="sig-sort-btn active" id="sortName" onclick="setSort('name')">Name A–Z</button>
            <button class="sig-sort-btn" id="sortDue" onclick="setSort('due')">Due Date</button>
            <button class="sig-sort-btn" id="sortScore" onclick="setSort('score')">Score</button>
        </div>
    </div>

    <!-- Table -->
    <div class="sig-table-card">
        <div id="sigEmpty" class="sig-empty" style="display:none;">
            <i class="fas fa-inbox"></i>
            <p id="sigEmptyMsg">No assignments found.</p>
        </div>
        <table class="sig-table" id="sigTable">
            <thead>
                <tr>
                    <th>Assignment</th>
                    <th>Due Date</th>
                    <th>Submitted</th>
                    <th>Score</th>
                </tr>
            </thead>
            <tbody id="sigBody"></tbody>
            <tfoot>
                <tr class="sig-total-row" id="sigTotalRow">
                    <td colspan="3"><strong>Total</strong></td>
                    <td id="sigTotalCell">—</td>
                </tr>
            </tfoot>
        </table>
    </div>

</div>

<script>
    var allRows = [];
    var sortMode = localStorage.getItem('sigGradeSort') || 'name';

    // ── Bootstrap data from code-behind ──────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        var raw = document.getElementById('<%= hfGradeData.ClientID %>').value;
        if (raw && raw.trim() !== '' && raw !== '[]') {
            allRows = JSON.parse(raw);
        }
        document.getElementById('sortName').classList.toggle('active', sortMode === 'name');
        document.getElementById('sortDue').classList.toggle('active', sortMode === 'due');
        document.getElementById('sortScore').classList.toggle('active', sortMode === 'score');
        renderTable();
        updateBanner();
    });

    // ── Sort ─────────────────────────────────────────────────────────
    function setSort(mode) {
        sortMode = mode;
        localStorage.setItem('sigGradeSort', mode);
        document.getElementById('sortName').classList.toggle('active', mode === 'name');
        document.getElementById('sortDue').classList.toggle('active', mode === 'due');
        document.getElementById('sortScore').classList.toggle('active', mode === 'score');
        renderTable();
    }

    // ── Render table ─────────────────────────────────────────────────
    function renderTable() {
        var q = document.getElementById('sigSearch').value.toLowerCase().trim();

        var rows = allRows.filter(function (r) {
            return !q || r.title.toLowerCase().includes(q);
        });

        rows.sort(function (a, b) {
            if (sortMode === 'name') return a.title.localeCompare(b.title);
            if (sortMode === 'due') {
                if (!a.dueRaw && !b.dueRaw) return 0;
                if (!a.dueRaw) return 1; if (!b.dueRaw) return -1;
                return new Date(a.dueRaw) - new Date(b.dueRaw);
            }
            if (sortMode === 'score') {
                var sa = a.score !== null && a.score !== '' ? parseFloat(a.score) / parseInt(a.maxScore) : -1;
                var sb = b.score !== null && b.score !== '' ? parseFloat(b.score) / parseInt(b.maxScore) : -1;
                return sb - sa; // highest first
            }
            return 0;
        });

        var body = document.getElementById('sigBody');
        var table = document.getElementById('sigTable');
        var emptyDiv = document.getElementById('sigEmpty');

        if (rows.length === 0) {
            table.style.display = 'none';
            emptyDiv.style.display = 'block';
            document.getElementById('sigEmptyMsg').textContent = allRows.length === 0
                ? 'No assignments have been created for this course yet.'
                : 'No assignments match your search.';
            return;
        }

        table.style.display = 'table';
        emptyDiv.style.display = 'none';

        var totalScore = 0, totalMax = 0, hasScore = false;

        body.innerHTML = rows.map(function (r) {
            // ── Score cell ──
            var scoreHtml;
            if (!r.published) {
                scoreHtml = '<span class="sig-unpublished"><i class="fas fa-lock"></i> Not released</span>';
                totalMax += parseInt(r.maxScore) || 0;
            } else if (r.score !== null && r.score !== '') {
                var s = parseFloat(r.score);
                var max = parseInt(r.maxScore) || 0;
                var pct = max > 0 ? (s / max) * 100 : 0;
                var barColor = pct >= 70 ? '#22c55e' : pct >= 50 ? '#f59e0b' : '#ef4444';
                totalScore += s; totalMax += max; hasScore = true;
                scoreHtml =
                    '<span class="sig-score">' + s.toFixed(1) +
                    ' <span class="sig-score-max">/ ' + max + '</span></span>' +
                    '<div class="sig-score-bar">' +
                    '<div class="sig-score-bar-fill" style="width:' + Math.min(pct, 100).toFixed(1) + '%;background:' + barColor + ';"></div>' +
                    '</div>';
            } else {
                totalMax += parseInt(r.maxScore) || 0;
                scoreHtml = '<span class="sig-score-none">—<span class="sig-score-max"> / ' + r.maxScore + '</span></span>';
            }

            // ── Submission cell ──
            var subHtml;
            if (r.submittedAt) {
                var isLate = r.dueRaw && r.submittedRaw && new Date(r.submittedRaw) > new Date(r.dueRaw);
                subHtml = (isLate
                    ? '<span class="sig-badge badge-late">Late</span>'
                    : '<span class="sig-badge badge-submitted">Submitted</span>') +
                    '<div class="sig-date">' + r.submittedAt + '</div>';
            } else {
                var isPast = r.dueRaw && new Date(r.dueRaw) < new Date();
                subHtml = isPast
                    ? '<span class="sig-badge badge-missing">Not Submitted</span>'
                    : '<span class="sig-badge badge-pending">Pending</span>';
            }

            // ── Due cell ──
            var dueHtml = r.due
                ? '<div class="sig-date">' + r.due + '</div>'
                : '<span class="sig-score-none">—</span>';

            return '<tr>' +
                '<td><span class="sig-assign-title">' + r.title + '</span>' +
                '<span class="sig-type-badge">' + r.type + '</span></td>' +
                '<td>' + dueHtml + '</td>' +
                '<td>' + subHtml + '</td>' +
                '<td>' + scoreHtml + '</td>' +
                '</tr>';
        }).join('');

        // ── Total row ──
        var pct = totalMax > 0 && hasScore ? ((totalScore / totalMax) * 100) : null;
        document.getElementById('sigTotalCell').innerHTML =
            '<span class="sig-total-score">' +
            (hasScore ? totalScore.toFixed(1) + ' / ' + totalMax : '— / ' + totalMax) +
            '</span>' +
            (pct !== null ? '<span class="sig-total-pct">(' + pct.toFixed(1) + '%)</span>' : '') +
            (pct !== null ? '<div class="sig-total-outof">Out of 100%: <strong>' + Math.min(pct, 100).toFixed(1) + '%</strong></div>' : '');
    }

    // ── Performance banner ────────────────────────────────────────────
    function updateBanner() {
        var gradedScore = 0, gradedMax = 0, gradedCount = 0;
        var overallMax = 0, overallScore = 0;

        allRows.forEach(function (r) {
            if (!r.published) return;
            var max = parseInt(r.maxScore) || 0;
            overallMax += max;
            if (r.score !== null && r.score !== '') {
                var s = parseFloat(r.score);
                gradedScore += s; gradedMax += max;
                overallScore += s; gradedCount++;
            }
        });

        var banner = document.getElementById('sigBanner');
        var pill = document.getElementById('sigPill');
        var barG = document.getElementById('sigBarGraded');
        var barO = document.getElementById('sigBarOverall');
        var valG = document.getElementById('sigValGraded');
        var valO = document.getElementById('sigValOverall');
        var subG = document.getElementById('sigSubGraded');
        var subO = document.getElementById('sigSubOverall');

        // Clear previous tier classes
        ['tier-excellent', 'tier-good', 'tier-average', 'tier-atrisk', 'tier-fail'].forEach(function (t) {
            banner.classList.remove(t); pill.classList.remove(t);
            barG.classList.remove(t); barO.classList.remove(t);
        });

        if (gradedCount === 0) {
            pill.innerHTML = '<i class="fas fa-circle-info"></i> No graded assignments yet';
            valG.textContent = '—'; valO.textContent = '—';
            subG.textContent = ''; subO.textContent = '';
            barG.style.width = '0%'; barO.style.width = '0%';
            return;
        }

        var gradedPct = gradedMax > 0 ? (gradedScore / gradedMax) * 100 : 0;
        var overallPct = overallMax > 0 ? (overallScore / overallMax) * 100 : 0;
        var tierPct = gradedPct;

        var tier;
        if (tierPct >= 90) tier = { key: 'excellent', icon: 'fa-trophy', label: 'Excellent' };
        else if (tierPct >= 70) tier = { key: 'good', icon: 'fa-thumbs-up', label: 'Good' };
        else if (tierPct >= 60) tier = { key: 'average', icon: 'fa-chart-line', label: 'Average' };
        else if (tierPct >= 50) tier = { key: 'atrisk', icon: 'fa-triangle-exclamation', label: 'At Risk' };
        else tier = { key: 'fail', icon: 'fa-circle-xmark', label: 'Failing' };

        banner.classList.add('tier-' + tier.key);
        pill.classList.add('tier-' + tier.key);
        pill.innerHTML = '<i class="fas ' + tier.icon + '"></i> ' + tier.label;

        barG.classList.add('tier-' + tier.key);
        barO.classList.add('tier-' + tier.key);

        barG.style.width = Math.min(gradedPct, 100).toFixed(1) + '%';
        valG.textContent = gradedPct.toFixed(1) + '%';
        subG.textContent = 'Based on ' + gradedCount + ' graded assignment' + (gradedCount === 1 ? '' : 's');

        barO.style.width = Math.min(overallPct, 100).toFixed(1) + '%';
        valO.textContent = overallPct.toFixed(1) + '%';
        subO.textContent = overallScore.toFixed(1) + ' / ' + overallMax + ' pts including unsubmitted';
    }
</script>

</asp:Content>
