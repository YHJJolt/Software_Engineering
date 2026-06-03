<%@ Page Title="People" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master"
    AutoEventWireup="true" CodeBehind="StudentCoursePeople.aspx.cs" Inherits="SchoolSystem.StudentCoursePeople" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="cp-toolbar">
        <input type="text" id="cpSearch" class="cp-search"
               placeholder="Search name, code or email…" oninput="filterPeople()" />
        <div class="cp-sort-wrap">
            <button type="button" class="cp-sort-btn" onclick="toggleSort(event)" title="Sort">
                <i class="fas fa-filter"></i>
            </button>
            <div class="cp-sort-panel" id="cpSortPanel">
                <div class="cp-sort-lbl">Name</div>
                <button type="button" class="cp-sort-opt active" onclick="pickSort('name-asc',this,event)"><i class="fas fa-arrow-up"></i> A → Z</button>
                <button type="button" class="cp-sort-opt" onclick="pickSort('name-desc',this,event)"><i class="fas fa-arrow-down"></i> Z → A</button>
                <div class="cp-sort-lbl mt2">Code</div>
                <button type="button" class="cp-sort-opt" onclick="pickSort('code-asc',this,event)"><i class="fas fa-arrow-up"></i> Ascending</button>
                <button type="button" class="cp-sort-opt" onclick="pickSort('code-desc',this,event)"><i class="fas fa-arrow-down"></i> Descending</button>
            </div>
        </div>
    </div>

    <div class="cp-table-wrap" id="cpTableWrap">
        <table class="cp-table">
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Code</th>
                    <th>Email</th>
                    <th>Program</th>
                    <th>Sem</th>
                </tr>
            </thead>
            <tbody id="cpBody">
                <asp:Repeater ID="rptPeople" runat="server">
                    <ItemTemplate>
                        <tr data-name="<%# Eval("student_name").ToString().ToLower() %>"
                            data-code="<%# Eval("student_code").ToString().ToLower() %>"
                            data-email="<%# Eval("student_email").ToString().ToLower() %>">
                            <td>
                                <div class="cp-name-cell">
                                    <div class="cp-avatar"><%# Eval("student_name").ToString().Substring(0,1).ToUpper() %></div>
                                    <span class="cp-name-text"><%# Eval("student_name") %></span>
                                    <%# Eval("is_me").ToString() == "1" ? "<span class=\"cp-you-badge\">You</span>" : "" %>
                                </div>
                            </td>
                            <td><%# Eval("student_code") %></td>
                            <td style="color:var(--text-muted); font-size:14px;"><%# Eval("student_email") %></td>
                            <td><%# Eval("program_name") %></td>
                            <td style="text-align:center;"><%# Eval("student_sem") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <div id="cpNoResults" style="display:none; text-align:center; padding:40px; color:#64748b; font-size:15px; font-weight:600;">
        <i class="fas fa-search" style="font-size:32px; display:block; margin-bottom:12px; opacity:0.3;"></i>
        No results found
    </div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="cp-empty-panel">
        <i class="fas fa-users-slash"></i>No students enrolled in this course yet
    </asp:Panel>

    <script>
    function toggleSort(e) {
        e.stopPropagation();
        var p = document.getElementById('cpSortPanel');
        p.style.display = p.style.display === 'block' ? 'none' : 'block';
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.cp-sort-wrap'))
            document.getElementById('cpSortPanel').style.display = 'none';
    });
    function pickSort(val, btn, e) {
        e.stopPropagation();
        document.querySelectorAll('.cp-sort-opt').forEach(function(b){ b.classList.remove('active'); });
        btn.classList.add('active');
        document.getElementById('cpSortPanel').style.display = 'none';
        sortTable(val);
    }
    function sortTable(val) {
        var tbody = document.getElementById('cpBody');
        var rows  = Array.from(tbody.querySelectorAll('tr[data-name]'));
        var col   = val.startsWith('name') ? 'name' : 'code';
        var dir   = val.endsWith('asc') ? 1 : -1;
        rows.sort(function(a, b){ return a.dataset[col].localeCompare(b.dataset[col]) * dir; });
        rows.forEach(function(r){ tbody.appendChild(r); });
    }
    function filterPeople() {
        var search  = document.getElementById('cpSearch').value.toLowerCase();
        var rows    = document.querySelectorAll('#cpBody tr[data-name]');
        var visible = 0;
        rows.forEach(function(row) {
            var ok = !search || row.dataset.name.includes(search)
                             || row.dataset.code.includes(search)
                             || row.dataset.email.includes(search);
            row.style.display = ok ? '' : 'none';
            if (ok) visible++;
        });
        var noResults = visible === 0 && rows.length > 0;
        document.getElementById('cpNoResults').style.display = noResults ? '' : 'none';
        document.getElementById('cpTableWrap').style.display = noResults ? 'none' : '';
    }
    window.addEventListener('DOMContentLoaded', function() { sortTable('name-asc'); });
    </script>

</asp:Content>
