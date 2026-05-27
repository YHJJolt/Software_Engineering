<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Calendar.aspx.cs" Inherits="SchoolSystem.Calendar" MasterPageFile="~/AdminMaster.Master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<asp:ScriptManagerProxy runat="server" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />

<div class="calendar-page">
    <div class="header">
        <h1><i class="fas fa-calendar-alt"></i> Calendar</h1>
    </div>

    <div class="calendar-container">
        <button type="button" class="btn-add-event" onclick="prepareAddModal()">
            <i class="fa-solid fa-plus"></i> Add New Event
        </button>

        <div style="display: flex; gap: 30px; align-items: flex-start; justify-content: center; margin-bottom: 30px;">
            <div class="calendar-main-box">
                <div id="calendar" runat="server"></div>

                <div style="margin-top: 40px; border-top: 1px solid rgba(18, 20, 32, 0.1); padding-top: 20px;">
                    <div style="display: flex; gap: 30px;">
                        <div style="flex: 1;">
                            <h3>Upcoming Events <i class="fa-solid fa-calendar-day"></i></h3>
                            <div id="upcomingEventsContainer"></div>
                        </div>
                        <div style="flex: 1; border-left: 1px solid #eee; padding-left: 30px;">
                            <h3>Past Events <i class="fa-solid fa-clock-rotate-left"></i></h3>
                            <div id="pastEventsContainer"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="dateSidebar" class="calendar-sidebar">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #7B61FF;">
                    <div id="selectedDateTitle" style="font-weight: 700;">Select a date</div>
                    <button type="button" onclick="closeSidebar()" style="background:none;border:none;font-size:24px;color:#999;">×</button>
                </div>
                <div id="sidebarEventsList"></div>
            </div>
        </div>
    </div>

    <!-- Modal -->
    <div id="eventModal" class="modal">
        <div class="modal-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <h3 id="modalHeaderTitle">Add Event</h3>
                <button type="button" onclick="closeModal()" style="background:none;border:none;font-size:22px;">×</button>
            </div>

            <input type="hidden" id="editEventId" value="" />
            <input type="hidden" id="eventType" value="General" />

            <div class="input-row">
                <i class="fa-solid fa-pencil"></i>
                <input type="text" id="title" placeholder="Event title" class="modern-input" />
            </div>

            <div class="input-row">
                <i class="fa-solid fa-calendar"></i>
                <input type="date" id="startDate" class="modern-input" />
            </div>

            <div class="input-row">
                <i class="fa-solid fa-calendar-check"></i>
                <input type="date" id="endDate" class="modern-input" />
            </div>

            <div class="input-row" style="border: none;">
                <i class="fa-solid fa-align-left"></i>
                <textarea id="desc" placeholder="Add description" class="modern-input" style="height:80px;"></textarea>
            </div>

            <p class="type-picker-label">Event Category</p>
            <div id="typePicker" class="type-tags-container">
                <div class="type-tag active" data-type="General">General</div>
                <div class="type-tag" data-type="Exam">Exam</div>
                <div class="type-tag" data-type="Holiday">Holiday</div>
                <div class="type-tag" data-type="Enrolment">Enrolment</div>
            </div>

            <div class="modal-footer">
                <button type="button" onclick="closeModal()" class="modern-btn btn-cancel">Cancel</button>
                <button type="button" id="saveEvent" class="modern-btn btn-save">Save</button>
                <button type="button" id="updateEventBtn" style="display:none;" onclick="updateEvent()" class="modern-btn btn-save">Update Changes</button>
            </div>
        </div>
    </div>
</div>
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>
<script>
// @ts-nocheck
// ====================== CONFIG ======================
var calendar;
const typeColorMap = {
    "General": "#1967d2",
    "Exam": "#d93025",
    "Holiday": "#1e8e3e",
    "Enrolment": "#9334e6"
};

// ====================== MODAL ======================
function openModal() { document.getElementById("eventModal").style.display = "block"; }
function closeModal() { document.getElementById("eventModal").style.display = "none"; }
function closeSidebar() { $("#dateSidebar").fadeOut(300); }

function prepareAddModal() {
    $("#modalHeaderTitle").text("Add Event");
    $("#saveEvent").show();
    $("#updateEventBtn").hide();
    $("#editEventId, #title, #desc, #startDate, #endDate").val("");
    $(".type-tag").removeClass("active").first().addClass("active");
    $("#eventType").val("General");
    openModal();
}

// ====================== SIDEBAR ======================
function showSidebar(dateStr) {
    // (Same as before - kept your original logic)
    const sidebar = $("#dateSidebar");
    const listContainer = $("#sidebarEventsList");
    const title = $("#selectedDateTitle");

    const dateObj = new Date(dateStr);
    title.text(dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }));

    const dayEvents = calendar.getEvents().filter(e => e.startStr.split('T')[0] === dateStr);
    listContainer.empty();
    sidebar.fadeIn(300);

    if (dayEvents.length === 0) {
        listContainer.append('<p style="color: #999; margin-top:15px; font-size:13px;">No events for this day.</p>');
    } else {
        const colorStyles = {
            "General": { bg: "#e8f0fe", text: "#1967d2" },
            "Exam": { bg: "#fce8e6", text: "#d93025" },
            "Holiday": { bg: "#e6ffed", text: "#1e8e3e" },
            "Enrolment": { bg: "#f3e8fd", text: "#9334e6" }
        };

        dayEvents.forEach(event => {
            const type = event.extendedProps.type || "General";
            const style = colorStyles[type] || colorStyles["General"];
            listContainer.append(`
                <div style="background: ${style.bg}; border-radius: 8px; padding: 12px; margin-bottom: 12px;">
                    <div style="display: flex; justify-content: space-between;">
                        <span style="font-weight: 700; color: ${style.text};">${event.title}</span>
                        <span style="font-size:10px; padding:2px 6px; border-radius:4px; background:rgba(255,255,255,0.5); color:${style.text};">${type}</span>
                    </div>
                    <div style="font-size:12px; margin-top:6px;">${event.extendedProps.description || "No description."}</div>
                </div>
            `);
        });
    }
}

// ====================== MAIN INIT ======================
$(document).ready(function () {
    $("#dateSidebar").hide();

    $(".type-tag").click(function () {
        $(".type-tag").removeClass("active");
        $(this).addClass("active");
        $("#eventType").val($(this).data("type"));
    });

    $("#saveEvent").click(() => saveEvent());

    var calendarEl = document.getElementById('MainContent_calendar') || document.querySelector('[id$="calendar"]');
    if (!calendarEl) return;

    calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        height: 'auto',
        aspectRatio: 1.5,
        dayMaxEvents: 3,          // Show up to 3 pills, then "+N more"
        eventDisplay: 'block',
        eventMaxStack: 3,

        // Clicking a date still opens the sidebar
        dateClick: function (info) { showSidebar(info.dateStr); },

        // Clicking an event pill also opens the sidebar for that date
        eventClick: function (info) {
            info.jsEvent.stopPropagation();
            showSidebar(info.event.startStr.split('T')[0]);
        },

        // Render pill content: just the title (FullCalendar default is fine,
        // but we hook didMount to ensure no extra chrome)
        eventDidMount: function (info) {
            info.el.title = info.event.title;
        },

        events: function (fetchInfo, successCallback) {
            $.ajax({
                url: 'Calendar.aspx/GetEvents',
                type: 'POST',
                contentType: 'application/json',
                data: '{}',
                success: function (response) {
                    const rawEvents = response.d || [];
                    const coloredEvents = rawEvents.map(event => {
                        let end = event.end;
                        if (end && end !== event.start) {
                            let endDate = new Date(end);
                            endDate.setDate(endDate.getDate() + 1);
                            end = endDate.toISOString().split('T')[0];
                        }
                        return {
                            ...event,
                            end: end,
                            color: typeColorMap[event.type] || "#7B61FF",
                            textColor: "#ffffff",
                            extendedProps: {
                                description: event.description,
                                type: event.type
                            }
                        };
                    });

                    successCallback(coloredEvents);
                    renderEventCards(coloredEvents);
                }
            });
        }
    });

    calendar.render();
});

// ====================== EVENT CARDS ======================
function renderEventCards(events) {
    var upcomingContainer = $("#upcomingEventsContainer");
    var pastContainer = $("#pastEventsContainer");
    upcomingContainer.empty();
    pastContainer.empty();
    events.sort(function (a, b) { return new Date(a.start) - new Date(b.start); });
    var today = new Date();
    today.setHours(0, 0, 0, 0);

    events.forEach(function (event) {
        var eventDate = new Date(event.start);
        var dateRange = event.start;
        if (event.end && event.end !== event.start) dateRange += ' \u2014 ' + event.end;
        var accentColor = typeColorMap[event.type] || "#7B61FF";
        var actionBtns =
            '<div class="card-actions">' +
            '<button type="button" class="action-btn btn-edit" onclick="openEditModal(\'' + event.id + '\')"><i class="fa-solid fa-pencil"></i></button>' +
            '<button type="button" class="action-btn btn-delete" onclick="deleteEvent(\'' + event.id + '\')"><i class="fa-solid fa-trash-can"></i></button>' +
            '</div>';
        var cardHtml =
            '<div class="event-card ' + (eventDate < today ? 'past-event' : '') + '" style="border-left: 6px solid ' + accentColor + ';">' +
            '<div class="event-card-date">' + dateRange + '</div>' +
            '<h4 class="event-card-title">' + event.title + '</h4>' +
            '<div class="event-card-desc">' + (event.description || "No description provided.") + '</div>' +
            actionBtns +
            '</div>';
        if (eventDate < today) pastContainer.append(cardHtml);
        else upcomingContainer.append(cardHtml);
    });

    if (upcomingContainer.is(':empty')) upcomingContainer.append("<p style='color:#999;'>No upcoming events.</p>");
    if (pastContainer.is(':empty')) pastContainer.append("<p style='color:#999;'>No past events.</p>");
}

function openEditModal(id) {
    var eventObj = calendar.getEventById(id);
    if (!eventObj) return;
    $("#editEventId").val(id);
    $("#title").val(eventObj.title);
    $("#desc").val(eventObj.extendedProps.description);
    $("#startDate").val(eventObj.startStr.split('T')[0]);
    var endStr = eventObj.endStr ? eventObj.endStr.split('T')[0] : eventObj.startStr.split('T')[0];
    $("#endDate").val(endStr);
    var savedType = eventObj.extendedProps.type || "General";
    $("#eventType").val(savedType);
    $(".type-tag").removeClass("active");
    $(".type-tag[data-type='" + savedType + "']").addClass("active");
    $("#modalHeaderTitle").text("Edit Event");
    $("#saveEvent").hide();
    $("#updateEventBtn").show();
    openModal();
}

// ====================== CRUD with SweetAlert ======================
function saveEvent() {
    const startDate = $("#startDate").val();
    if (!startDate) {
        Swal.fire({ icon: 'warning', title: 'Missing Date', text: 'Please select a start date.' });
        return;
    }

    $.ajax({
        url: 'Calendar.aspx/AddEvent',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            title: $("#title").val(),
            desc: $("#desc").val(),
            start: startDate,
            end: $("#endDate").val(),
            type: $("#eventType").val()
        }),
        success: function (res) {
            if (res.d.status === "success") {
                closeModal();
                calendar.refetchEvents();
                Swal.fire({
                    icon: 'success',
                    title: 'Event Created!',
                    timer: 2000,
                    showConfirmButton: false
                });
            } else {
                Swal.fire({ icon: 'error', title: 'Failed', text: res.d.message });
            }
        }
    });
}

function updateEvent() {
    $.ajax({
        url: 'Calendar.aspx/UpdateEvent',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            id: $("#editEventId").val(),
            title: $("#title").val(),
            desc: $("#desc").val(),
            start: $("#startDate").val(),
            end: $("#endDate").val(),
            type: $("#eventType").val()
        }),
        success: function (res) {
            if (res.d.status === "success") {
                closeModal();
                calendar.refetchEvents();
                Swal.fire({ icon: 'success', title: 'Updated!', timer: 1500 });
            }
        }
    });
}

function deleteEvent(id) {
    Swal.fire({
        title: 'Delete Event?',
        text: "This action cannot be undone!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d93025',
        cancelButtonColor: '#7B61FF',
        confirmButtonText: 'Yes, Delete'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: 'Calendar.aspx/DeleteEvent',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ id: parseInt(id, 10) }),
                success: function (res) {
                    if (res.d.status === "success") {
                        calendar.refetchEvents();
                        Swal.fire({ icon: 'success', title: 'Deleted!', timer: 1500 });
                    }
                }
            });
        }
    });
}
</script>
</asp:Content>