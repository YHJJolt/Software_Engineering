<%@ Page Title="Announcements Management" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminAnnouncement.aspx.cs" Inherits="SchoolSystem.AdminAnnouncement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <link href="Admin.css" rel="stylesheet" type="text/css" />

    <div class="announcement-page">
    <div class="header">
        <h1><i class="fas fa-bullhorn"></i>Announcements</h1>
    </div>
    <button type="button" class="btn-create" onclick="openAnnounceModal()">+ New Announcement</button>
    <div class="announcement-container">
        
        <div class="filter-section">
            <div class="search-wrapper">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="announceSearch" class="search-input" placeholder="Search by title..." onkeyup="filterData()" />
            </div>
            <div class="tab-group">
                <div class="nav-tab active" data-filter="All" onclick="changeTab(this)">All</div>
                <div class="nav-tab" data-filter="General" onclick="changeTab(this)">General</div>
                <div class="nav-tab" data-filter="Academic" onclick="changeTab(this)">Academic</div>
                <div class="nav-tab" data-filter="Finance" onclick="changeTab(this)">Finance</div>
                <div class="nav-tab" data-filter="Co-curriculum" onclick="changeTab(this)">Co-curriculum</div>
            </div>
        </div>

        <div id="announcementsList"></div>
    </div>

    <div id="announceModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 id="modalTitle">Create Announcement</h3>
                <input type="hidden" id="editId" />
            </div>
            
            <div class="form-row">
                <i class="fa-solid fa-heading"></i>
                <div class="input-container">
                    <input type="text" id="txtTitle" class="google-input" placeholder="Add title" />
                </div>
            </div>

            <div class="form-row">
                <i class="fa-solid fa-align-left"></i>
                <div class="input-container">
                    <textarea id="txtContent" class="google-input" rows="3" placeholder="Add description" style="resize: none;"></textarea>
                </div>
            </div>

            <div class="form-row">
                <i class="fa-solid fa-tag"></i>
                <div class="input-container">
                    <div class="type-selector">
                        <div class="type-pill active" data-cat="General">General</div>
                        <div class="type-pill" data-cat="Academic">Academic</div>
                        <div class="type-pill" data-cat="Finance">Finance</div>
                        <div class="type-pill" data-cat="Co-curriculum">Co-curriculum</div>
                    </div>
                    <input type="hidden" id="selectedCategory" value="General" />
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-flat" onclick="closeAnnounceModal()">Cancel</button>
                <button type="button" id="btnSubmit" class="btn-create" onclick="saveAnnouncement()">Post Announcement</button>
            </div>
        </div>
    </div>

    <script>
        let rawData = [];

        $(document).ready(function () {
            loadAnnouncements();

            $(".type-pill").click(function () {
                $(".type-pill").removeClass("active");
                $(this).addClass("active");
                $("#selectedCategory").val($(this).data("cat"));
            });
        });

        function changeTab(el) {
            $(".nav-tab").removeClass("active");
            $(el).addClass("active");
            filterData();
        }

        function filterData() {
            const query = $("#announceSearch").val().toLowerCase();
            const tab = $(".nav-tab.active").data("filter");
            const filtered = rawData.filter(a => {
                const matchSearch = a.title.toLowerCase().includes(query);
                const matchTab = (tab === "All" || a.category === tab);
                return matchSearch && matchTab;
            });
            renderList(filtered);
        }

        function loadAnnouncements() {
            $.ajax({
                url: 'AdminAnnouncement.aspx/GetAnnouncements',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: '{}',
                success: function (res) {
                    rawData = res.d;
                    filterData();
                }
            });
        }

        function renderList(data) {
            let html = "";
            if (data.length === 0) {
                html = '<div style="text-align:center; padding:50px; color:#999;">No announcements found.</div>';
            } else {
                data.forEach(a => {
                    html += `
                    <div class="announcement-card">
                        <div class="announcement-avatar"><i class="fa-solid fa-bullhorn"></i></div>
                        <div class="announcement-content">
                            <span class="cat-tag cat-${a.category}">${a.category}</span>
                            <div class="announcement-title">${a.title}</div>
                            <div class="announcement-body">${a.content}</div>
                            <div class="announcement-meta">Posted on: ${a.created_at} • Admin ID: ${a.admin_id}</div>
                        </div>
                        <div class="card-actions">
                            <button type="button" class="action-btn btn-edit" onclick="editAnnouncement(${a.announcement_id}, event)"><i class="fa-solid fa-pencil"></i></button>
                            <button type="button" class="action-btn btn-delete" onclick="deleteAnnouncement(${a.announcement_id}, event)"><i class="fa-solid fa-trash-can"></i></button>
                        </div>
                    </div>`;
                });
            }
            $("#announcementsList").html(html);
        }

        function openAnnounceModal() {
            $("#modalTitle").text("Create Announcement");
            $("#editId, #txtTitle, #txtContent").val("");
            $(".type-pill").removeClass("active");
            $(".type-pill[data-cat='General']").addClass("active");
            $("#selectedCategory").val("General");
            $("#btnSubmit").text("Post Announcement");
            $("#announceModal").fadeIn(200);
        }

        function closeAnnounceModal() { $("#announceModal").fadeOut(200); }

        function saveAnnouncement() {
            const payload = {
                id: parseInt($("#editId").val()) || 0,
                title: $("#txtTitle").val(),
                content: $("#txtContent").val(),
                category: $("#selectedCategory").val()
            };
            if (!payload.title || !payload.content) { alert("Please fill in all fields."); return; }
            $.ajax({
                url: 'AdminAnnouncement.aspx/SaveAnnouncement',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(payload),
                success: function () {
                    closeAnnounceModal();
                    loadAnnouncements();
                }
            });
        }

        function editAnnouncement(id, e) {
            e.preventDefault();
            const item = rawData.find(x => x.announcement_id == id);
            if (!item) return;
            $("#editId").val(id);
            $("#txtTitle").val(item.title);
            $("#txtContent").val(item.content);
            $(".type-pill").removeClass("active");
            $(`.type-pill[data-cat='${item.category}']`).addClass("active");
            $("#selectedCategory").val(item.category);
            $("#modalTitle").text("Update Announcement");
            $("#btnSubmit").text("Update");
            $("#announceModal").fadeIn(200);
        }

        function deleteAnnouncement(id, e) {
            e.preventDefault();
            if (confirm("Permanently delete this announcement?")) {
                $.ajax({
                    url: 'AdminAnnouncement.aspx/DeleteAnnouncement',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ id: id }),
                    success: function () { loadAnnouncements(); }
                });
            }
        }
    </script>
    </div>
</asp:Content>