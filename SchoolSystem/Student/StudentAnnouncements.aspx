<%@ Page Title="Announcements" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master" AutoEventWireup="true" CodeBehind="StudentAnnouncements.aspx.cs" Inherits="SchoolSystem.Student.StudentAnnouncement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="announcement-page">
        <div class="header">
            <div class="search-wrapper" style="max-width: 420px; flex: 1;">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" id="announceSearch" class="search-input" 
                   style="padding-left: 36px;"
                   placeholder="Search by title..." onkeyup="filterData()" />
            </div>
            <!-- No "New Announcement" button — students are read-only -->
        </div>

        <div class="announcement-container">
            <div id="announcementsList"></div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
    // @ts-nocheck
    let rawData = [];
    let currentCourseId = <%= Request.QueryString["id"] ?? "0" %>;
let currentSession = '<%= Uri.EscapeDataString(Request.QueryString["session"] ?? "") %>';

$(document).ready(function () {
    if (currentCourseId == 0) {
        alert("Course ID is missing in URL. Please access via your course dashboard.");
        return;
    }
    loadAnnouncements();
});

function loadAnnouncements() {
    $.ajax({
        url: 'StudentAnnouncements.aspx/GetAnnouncements',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        data: JSON.stringify({ courseId: currentCourseId, session: decodeURIComponent(currentSession) }),
        success: function (res) {
            rawData = res.d;
            filterData();
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load announcements.', confirmButtonColor: '#121420' });
        }
    });
}

function filterData() {
    const query = $("#announceSearch").val().toLowerCase();
    const filtered = rawData.filter(a => a.Title.toLowerCase().includes(query));
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
                    <div class="announcement-card" onclick="window.location.href='StudentAnnouncementDetail.aspx?id=${a.Announcement_id}&course_id=${currentCourseId}&session=${currentSession}'" style="cursor:pointer;">
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
                        <!-- No edit/delete buttons — students are read-only -->
                    </div>`;
        });
    }
    $("#announcementsList").html(html);
}
</script>
</asp:Content>