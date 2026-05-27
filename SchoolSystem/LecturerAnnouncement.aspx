<%@ Page Title="Announcement" Language="C#" MasterPageFile="~/LecturerCourseMaster.Master" AutoEventWireup="true" CodeBehind="LecturerAnnouncement.aspx.cs" Inherits="SchoolSystem.LecturerAnnouncement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="announcement-page">
        <div class="header">
            <div class="search-wrapper" style="max-width: 420px; flex: 1;">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="announceSearch" class="search-input" 
                       placeholder="Search by title..." onkeyup="filterData()" />
            </div>
            
            <button type="button" class="btn-create" onclick="openAnnounceModal()">
                + New Announcement
            </button>
        </div>

        <div class="announcement-container">
            <div id="announcementsList"></div>
        </div>

        <!-- Modal -->
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
                        <textarea id="txtContent" class="google-input" rows="6" placeholder="Add description" style="resize: none;"></textarea>
                    </div>
                </div>

                <div class="form-row">
                    <i class="fa-solid fa-tag"></i>
                    <div class="input-container">
                        <div class="type-selector">
                            <div class="type-pill active" data-cat="General">General</div>
                            <div class="type-pill" data-cat="Academic">Academic</div>
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
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
    // @ts-nocheck
    let rawData = [];
    let currentCourseId = <%= Request.QueryString["id"] ?? "0" %>;

        $(document).ready(function () {
            if (currentCourseId == 0) {
                alert("Course ID is missing in URL. Please access via course dashboard.");
                return;
            }
            loadAnnouncements();

            $(".type-pill").click(function () {
                $(".type-pill").removeClass("active");
                $(this).addClass("active");
                $("#selectedCategory").val($(this).data("cat"));
            });
        });

        function loadAnnouncements() {
            $.ajax({
                url: 'LecturerAnnouncement.aspx/GetAnnouncements',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ courseId: currentCourseId }),
                success: function (res) {
                    rawData = res.d;
                    filterData();
                }
            });
        }

        function filterData() {
            const query = $("#announceSearch").val().toLowerCase();
            const filtered = rawData.filter(a =>
                a.Title.toLowerCase().includes(query)  
            );
            renderList(filtered);
        }

        function renderList(data) {
            let html = "";
            if (data.length === 0) {
                html = '<div style="text-align:center; padding:50px; color:#999;">No announcements found.</div>';
            } else {
                data.forEach(a => {
                    const maxLen = 120;
                    const isLong = a.Content.length > maxLen;
                    const shortContent = isLong ? a.Content.substring(0, maxLen) + '...' : a.Content;

                    html += `
                    <div class="announcement-card" onclick="window.location.href='LecturerAnnouncementDetail.aspx?id=${a.Announcement_id}&course_id=${currentCourseId}'" style="cursor:pointer;">
                        <div class="announcement-avatar"><i class="fa-solid fa-bullhorn"></i></div>
                        <div class="announcement-content">
                            <span class="cat-tag cat-${a.Category}">${a.Category}</span>
                            <div class="announcement-title">${a.Title}</div>
                            <div class="announcement-body">
                                ${shortContent}
                                ${isLong ? `<span style="color:#1967d2; font-weight:600; cursor:pointer;"> Read more</span>` : ''}
                            </div>
                            <div class="announcement-meta">
                                <strong>${a.Lecturer_name}</strong> &nbsp;·&nbsp; ${a.Created_at} at ${a.Created_time}
                            </div>
                        </div>
                        <div class="card-actions">
                            <button type="button" class="action-btn btn-edit" onclick="editAnnouncement(${a.Announcement_id}, event)"><i class="fa-solid fa-pencil"></i></button>
                            <button type="button" class="action-btn btn-delete" onclick="deleteAnnouncement(${a.Announcement_id}, event)"><i class="fa-solid fa-trash-can"></i></button>
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
            $("#announceModal").css("display", "flex").hide().fadeIn(200); // ✅
        }

        function closeAnnounceModal() {
            $("#announceModal").css("display", "none");
        }

        function saveAnnouncement() {
            const editId = parseInt($("#editId").val()) || 0; // ✅ capture BEFORE modal closes
            const payload = {
                id: editId,
                title: $("#txtTitle").val(),
                content: $("#txtContent").val(),
                category: $("#selectedCategory").val(),
                courseId: currentCourseId
            };

            if (!payload.title || !payload.content) {
                Swal.fire({ icon: 'warning', title: 'Missing Fields', text: 'Please fill in title and content.', confirmButtonColor: '#121420' });
                return;
            }

            $.ajax({
                url: 'LecturerAnnouncement.aspx/SaveAnnouncement',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(payload),
                success: function (res) {
                    if (res.d) {
                        closeAnnounceModal();
                        Swal.fire({
                            icon: 'success',
                            title: editId !== 0 ? 'Announcement Updated!' : 'Announcement Posted!',
                            text: editId !== 0 ? 'Your announcement has been updated successfully.' : 'Your announcement has been posted successfully.',
                            confirmButtonColor: '#121420',
                            timer: 2000,
                            showConfirmButton: false
                        }).then(() => loadAnnouncements());
                    } else {
                        Swal.fire({ icon: 'error', title: 'Failed', text: 'Could not save announcement. Please try again.', confirmButtonColor: '#121420' });
                    }
                },
                error: function () {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Something went wrong. Please try again.', confirmButtonColor: '#121420' });
                }
            });
        }

        function editAnnouncement(id, e) {
            e.stopPropagation();  // ✅ prevent card navigation
            e.preventDefault();
            const item = rawData.find(x => x.Announcement_id == id);  // ✅ was x.announcement_id
            if (!item) return;

            $("#editId").val(id);
            $("#txtTitle").val(item.Title);        // ✅ was item.title
            $("#txtContent").val(item.Content);    // ✅ was item.content
            $(".type-pill").removeClass("active");
            $(`.type-pill[data-cat='${item.Category}']`).addClass("active");  // ✅ was item.category
            $("#selectedCategory").val(item.Category);  // ✅ was item.category
            $("#modalTitle").text("Update Announcement");
            $("#btnSubmit").text("Update");
            $("#announceModal").css("display", "flex");  // ✅ was fadeIn
        }

        function deleteAnnouncement(id, e) {
            e.stopPropagation();
            e.preventDefault();
            Swal.fire({
                title: 'Delete Announcement?',
                text: 'This action cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d93025',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, delete it'
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: 'LecturerAnnouncement.aspx/DeleteAnnouncement',
                        type: 'POST',
                        contentType: 'application/json; charset=utf-8',
                        data: JSON.stringify({ id: id, courseId: currentCourseId }),
                        success: function () {
                            Swal.fire({
                                icon: 'success',
                                title: 'Deleted!',
                                text: 'Announcement has been deleted.',
                                confirmButtonColor: '#121420',
                                timer: 1500,
                                showConfirmButton: false
                            }).then(() => loadAnnouncements());
                        }
                    });
                }
            });
        }
    </script>
</asp:Content>