<%@ Page Title="My Courses" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentCourses.aspx.cs" Inherits="SchoolSystem.StudentCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="courses-page">

        <!-- Toolbar -->
        <div class="courses-toolbar">
            <!-- Left: Title + Semester dropdown together -->
            <div class="toolbar-left">
                <span class="toolbar-title">All Courses</span>
                <asp:DropDownList ID="ddlSemester" runat="server" CssClass="sem-select"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlSemester_SelectedIndexChanged">
                </asp:DropDownList>
            </div>

            <!-- Right: Search -->
            <div class="search-wrapper">
                <i class="fas fa-search"></i>
                <input type="text" id="searchInput" class="search-input" placeholder="Search courses..." onkeyup="filterTable()" />
            </div>
        </div>

        <!-- Table Card -->
        <div class="table-card">
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <i class="fas fa-book-open"></i>
                <p>No courses found.</p>
            </asp:Panel>

            <asp:Panel ID="pnlTable" runat="server">
                <table class="courses-table" id="coursesTable">
                    <thead>
                        <tr>
                            <th style="width:46px;">Fav</th>
                            <th>Course Code</th>
                            <th>Course Name</th>
                            <th>Credit Hours</th>
                            <th>Lecturer</th>
                            <th class="col-sem">Semester</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptCourses" runat="server">
                            <ItemTemplate>
                                <tr onclick="window.location.href='StudentCourseHome.aspx?id=<%# Eval("course_id") %>'">
                                    <td style="text-align:center;">
                                        <button type="button"
                                            class="star-btn <%# Convert.ToInt32(Eval("is_favourite")) == 1 ? "starred" : "" %>"
                                            onclick="event.stopPropagation(); toggleFav(this, <%# Eval("course_id") %>)"
                                            title="<%# Convert.ToInt32(Eval("is_favourite")) == 1 ? "Remove favourite" : "Add favourite" %>">
                                            <i class="<%# Convert.ToInt32(Eval("is_favourite")) == 1 ? "fas" : "far" %> fa-star"></i>
                                        </button>
                                    </td>
                                    <td><span class="code-badge"><%# Eval("course_code") %></span></td>
                                    <td class="course-name-cell"><%# Eval("course_name") %></td>
                                    <td class="credit-hours"><%# Eval("credit_hours") %></td>
                                    <td class="lecturer-name"><%# Eval("lecturer_name") %></td>
                                    <td class="col-sem"><span class="sem-pill">Sem <%# Eval("enrolled_semester") %></span></td>
                                    <td>
                                        <span class="status-badge <%# GetStatusClass(Eval("status").ToString()) %>">
                                            <%# Eval("status") %>
                                        </span>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>

                <div class="table-footer">
                    Total Credit Hours: <strong><asp:Literal ID="litTotalCredits" runat="server">0</asp:Literal></strong>
                </div>
            </asp:Panel>
        </div>

    </div>

    <script>
        function filterTable() {
            var input = document.getElementById("searchInput").value.toLowerCase();
            var rows = document.querySelectorAll("#coursesTable tbody tr");
            rows.forEach(function (row) {
                row.style.display = row.textContent.toLowerCase().includes(input) ? "" : "none";
            });
        }

        // Hide the Semester column when a specific semester is selected (not "All")
        (function () {
            var ddl = document.getElementById('<%= ddlSemester.ClientID %>');
            function toggleSemCol() {
                var table = document.getElementById('coursesTable');
                if (!table) return;
                if (ddl.value === '0') {
                    table.classList.remove('hide-sem-col');
                } else {
                    table.classList.add('hide-sem-col');
                }
            }
            toggleSemCol();
            ddl.addEventListener('change', toggleSemCol);
        })();

        // ── Favourite toggle (AJAX) ──
        function toggleFav(btn, id) {
            var isFav = btn.classList.contains('starred');

            // Optimistic UI update — feels instant
            btn.classList.toggle('starred', !isFav);
            btn.querySelector('i').className = isFav ? 'far fa-star' : 'fas fa-star';
            btn.title = isFav ? 'Add favourite' : 'Remove favourite';

            fetch('StudentCourses.aspx/ToggleFavourite', {
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
                        alert('Failed to update favourite. Please try again.');
                    }
                })
                .catch(function () {
                    // Revert on network error
                    btn.classList.toggle('starred', isFav);
                    btn.querySelector('i').className = isFav ? 'fas fa-star' : 'far fa-star';
                    btn.title = isFav ? 'Remove favourite' : 'Add favourite';
                });
        }
    </script>

</asp:Content>
