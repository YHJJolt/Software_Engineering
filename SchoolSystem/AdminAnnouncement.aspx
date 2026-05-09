<%@ Page Title="Announcements Management" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminAnnouncement.aspx.cs" Inherits="SchoolSystem.AdminAnnouncement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />

    <style>
        .announcement-container { width: 900px; margin: 20px auto; font-family: 'Inter', sans-serif; }
        
        /* Header & Main UI */
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn-create { background: #121420; color: white; padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; transition: 0.3s; }
        .btn-create:hover { background: #2a2e45; }

        .filter-section { background: white; border: 1px solid #eee; padding: 20px; border-radius: 12px; margin-bottom: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); }
        .search-wrapper { position: relative; margin-bottom: 15px; }
        .search-input { width: 100%; padding: 12px 40px 12px 15px; border: 1px solid #ddd; border-radius: 8px; box-sizing: border-box; outline: none; transition: 0.3s; }
        .search-icon { position: absolute; right: 15px; top: 13px; color: #aaa; }

        .tab-group { display: flex; gap: 8px; }
        .nav-tab { padding: 8px 16px; cursor: pointer; font-size: 14px; font-weight: 600; color: #666; border-radius: 20px; transition: 0.2s; background: #f5f5f5; }
        .nav-tab.active { background: #121420; color: white; }

        /* Announcement Cards */
        .announcement-card { background: white; border: 1px solid #eee; border-radius: 12px; padding: 20px; margin-bottom: 20px; position: relative; display: flex; gap: 20px; transition: 0.2s; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .announcement-card:hover { transform: translateY(-3px); }
        .announcement-avatar { width: 50px; height: 50px; background: #e0e0e0; border-radius: 50%; flex-shrink: 0; display: flex; align-items: center; justify-content: center; color: #888; }
        .cat-tag { font-size: 10px; font-weight: 800; text-transform: uppercase; padding: 4px 10px; border-radius: 20px; margin-bottom: 8px; display: inline-block; }
        .cat-General { background: #e8f0fe; color: #1967d2; }
        .cat-Academic { background: #fce8e6; color: #d93025; }
        .cat-Finance { background: #e6ffed; color: #1e8e3e; }
        .cat-Co-curriculum { background: #f3e8fd; color: #9334e6; }
        .announcement-title { font-weight: 700; font-size: 1.1rem; color: #121420; }
        .announcement-body { color: #555; font-size: 14px; line-height: 1.5; }
        .announcement-meta { font-size: 11px; color: #999; margin-top: 10px; }
        .card-actions { position: absolute; right: 20px; top: 20px; display: flex; gap: 12px; }
        .action-btn { background: none; border: none; cursor: pointer; font-size: 16px; opacity: 0.4; }
        .action-btn:hover { opacity: 1; }
        .btn-edit { color: #1967d2; }
        .btn-delete { color: #d93025; }

        /* MODAL UPGRADES (Google Calendar Style) */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.4); }
        .modal-content { background: white; width: 440px; margin: 10% auto; padding: 24px; border-radius: 8px; box-shadow: 0 24px 38px 3px rgba(0,0,0,0.14); }
        
        .modal-header { margin-bottom: 20px; }
        .modal-header h3 { margin: 0; font-size: 22px; font-weight: 600; color: #3c4043; }

        .form-row { display: flex; align-items: flex-start; gap: 20px; margin-bottom: 20px; }
        .form-row i { color: #5f6368; font-size: 18px; margin-top: 10px; width: 20px; text-align: center; }
        .input-container { flex-grow: 1; }

        .google-input { 
            width: 100%; border: none; border-bottom: 1px solid #ddd; 
            padding: 8px 0; font-size: 16px; outline: none; transition: 0.2s;
            font-family: inherit; color: #3c4043;
        }
        .google-input:focus { border-bottom: 2px solid #121420; }
        
        /* Category Pills */
        .type-selector { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 5px; }
        .type-pill { padding: 6px 14px; border: 1px solid #dadce0; border-radius: 20px; cursor: pointer; font-size: 13px; color: #3c4043; transition: 0.2s; }
        .type-pill.active[data-cat="General"] { background: #e8f0fe; color: #1967d2; border-color: #1967d2; }
        .type-pill.active[data-cat="Academic"] { background: #fce8e6; color: #d93025; border-color: #d93025; }
        .type-pill.active[data-cat="Finance"] { background: #e6ffed; color: #1e8e3e; border-color: #1e8e3e; }
        .type-pill.active[data-cat="Co-curriculum"] { background: #f3e8fd; color: #9334e6; border-color: #9334e6; }

        .modal-footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 30px; }
        .btn-flat { background: none; border: none; padding: 10px 24px; border-radius: 4px; cursor: pointer; font-weight: 500; color: #5f6368; }
        .btn-flat:hover { background: #f1f3f4; }
    </style>

    <div class="announcement-container">
        <div class="page-header">
            <h2>Announcements</h2>
            <button type="button" class="btn-create" onclick="openAnnounceModal()">+ New Announcement</button>
        </div>

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
</asp:Content>