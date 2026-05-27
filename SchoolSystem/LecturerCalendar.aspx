<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCalendar.aspx.cs" 
         Inherits="SchoolSystem.LecturerCalendar" MasterPageFile="~/LecturerMaster.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<div class="calendar-page">
    <div class="header">
        <h1><i class="fas fa-calendar-alt"></i> Calendar</h1>
    </div>

    <div class="calendar-container">
        <button type="button" class="btn-add-event" onclick="prepareAddModal()">
            <i class="fa-solid fa-plus"></i> Add New Event
        </button>

        <div style="display: flex; gap: 30px; align-items: flex-start; justify-content: center; margin-bottom: 30px;">
            <!-- Main Calendar -->
            <div class="calendar-main-box">
                <div id="calendar" runat="server"></div>

                <!-- Upcoming & Past -->
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

            <!-- Sidebar -->
            <div id="dateSidebar" class="calendar-sidebar">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #7B61FF; padding-bottom: 10px;">
                    <div id="selectedDateTitle" style="font-weight: 700;">Select a date</div>
                    <button type="button" onclick="closeSidebar()" style="background:none;border:none;font-size:24px;color:#999;">×</button>
                </div>
                <div id="sidebarEventsList"></div>
            </div>
        </div>
    </div>

    <!-- Event Modal -->
    <div id="eventModal" class="modal">
        <div class="modal-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-plus" style="font-size: 14px; color: #5f6368;"></i>
                    <h3 id="modalHeaderTitle" style="margin: 0; font-weight: 500; font-size: 18px; color: #3c4043;">Add Event</h3>
                </div>
                <button type="button" onclick="closeModal()" style="background: none; border: none; font-size: 22px; cursor: pointer; color: #5f6368;">×</button>
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
                <textarea id="desc" placeholder="Add description" class="modern-input" style="height: 80px;"></textarea>
            </div>

            <p class="type-picker-label">Event Category</p>
            <div id="typePicker" class="type-tags-container">
                <div class="type-tag active" data-type="General">General</div>
                <div class="type-tag" data-type="Exam">Exam</div>
                <div class="type-tag" data-type="Assignment">Assignment</div>
                <div class="type-tag" data-type="Enrolment">Enrolment</div>
                <div class="type-tag" data-type="Meeting">Meeting</div>
            </div>

            <div class="modal-footer">
                <button type="button" onclick="closeModal()" class="modern-btn btn-cancel">Cancel</button>
                <button type="button" id="saveEvent" class="modern-btn btn-save">Save</button>
                <button type="button" id="updateEventBtn" style="display:none;" onclick="updateEvent()" class="modern-btn btn-save">Update Changes</button>
            </div>
        </div>
    </div>
</div>

<!-- Libraries -->
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
        "General": "#6366f1", "Exam": "#f87171", "Assignment": "#4ade80",
        "Enrolment": "#c084fc", "Meeting": "#60a5fa"
    };

    // ====================== MODAL ======================
    function openModal() {
        document.getElementById("eventModal").style.display = "block";
    }
    function closeModal() {
        document.getElementById("eventModal").style.display = "none";
    }
    function closeSidebar() {
        $("#dateSidebar").fadeOut(300);
    }

    function prepareAddModal() {
        $("#modalHeaderTitle").text("Add Event");
        $("#saveEvent").show();
        $("#updateEventBtn").hide();

        $("#editEventId, #title, #desc, #startDate, #endDate").val("");
        $("#typePicker .type-tag").removeClass("active").first().addClass("active");
        $("#eventType").val("General");

        openModal();
    }

    // ====================== SIDEBAR ======================
    function showSidebar(dateStr) {
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
                "General": { bg: "#e0e7ff", text: "#6366f1" },
                "Exam": { bg: "#fee2e2", text: "#f87171" },
                "Assignment": { bg: "#dcfce7", text: "#4ade80" },
                "Enrolment": { bg: "#f3e8ff", text: "#c084fc" },
                "Meeting": { bg: "#dbeafe", text: "#60a5fa" }
            };

            dayEvents.forEach(event => {
                const type = event.extendedProps.type || "General";
                const style = colorStyles[type] || colorStyles["General"];
                listContainer.append(`
                <div style="background: ${style.bg}; border-radius: 8px; padding: 12px; margin-bottom: 12px; border: 1px solid rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                        <span style="font-weight: 700; color: ${style.text}; font-size: 14px;">${event.title}</span>
                        <span style="font-size: 10px; font-weight: 800; text-transform: uppercase; background: rgba(255,255,255,0.5); padding: 2px 6px; border-radius: 4px; color: ${style.text};">${type}</span>
                    </div>
                    <div style="font-size: 12px; color: #444; margin-top: 6px; line-height: 1.4;">
                        ${event.extendedProps.description || "No description."}
                    </div>
                </div>
            `);
            });
        }
    }

    // ====================== DOCUMENT READY ======================
    $(document).ready(function () {
        $("#dateSidebar").hide();

        $(".type-tag").click(function () {
            if ($(this).closest("#typePicker").length) {
                $("#typePicker .type-tag").removeClass("active");
                $(this).addClass("active");
                $("#eventType").val($(this).data("type"));
            }
        });

        $("#saveEvent").click(() => saveEvent());

        var calendarEl = document.getElementById('MainContent_calendar') || document.querySelector('[id$="calendar"]');

        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            height: 'auto',
            aspectRatio: 1.8,           // Better aspect ratio
            dayMaxEvents: 4,
            eventDisplay: 'block',

            dateClick: function (info) {
                showSidebar(info.dateStr);
            },

            events: function (fetchInfo, successCallback) {
                $.when(
                    $.ajax({ url: 'LecturerCalendar.aspx/GetEvents', type: 'POST', contentType: 'application/json', data: '{}' }),
                    $.ajax({ url: 'LecturerCalendar.aspx/GetAdminEvents', type: 'POST', contentType: 'application/json', data: '{}' })
                ).done(function (lRes, aRes) {
                    const lecturerEvents = lRes[0].d || [];
                    const adminEvents = Array.isArray(aRes[0].d) ? aRes[0].d : [];

                    const allEvents = lecturerEvents.concat(adminEvents).map(event => {
                        let formattedEnd = event.end;
                        if (event.end && event.end !== event.start) {
                            let endDate = new Date(event.end);
                            endDate.setDate(endDate.getDate() + 1);
                            formattedEnd = endDate.toISOString().split('T')[0];
                        }
                        return {
                            ...event,
                            end: formattedEnd,
                            color: typeColorMap[event.type] || "#7B61FF",
                            textColor: "#ffffff",
                            editable: event.isOwner === true
                        };
                    });

                    successCallback(allEvents);
                    renderEventCards(allEvents);
                });
            }
        });

        calendar.render();
    });

    // ====================== CRUD ======================
    function saveEvent() {
        const titleVal = $("#title").val().trim();
        const startDate = $("#startDate").val();

        if (!titleVal) {
            Swal.fire({
                icon: 'warning',
                title: 'Title Required',
                text: 'Please enter a title for your event.',
                confirmButtonColor: '#7B61FF'
            });
            return;
        }

        if (!startDate) {
            Swal.fire({
                icon: 'warning',
                title: 'Missing Date',
                text: 'Please select a start date for your event.',
                confirmButtonColor: '#7B61FF'
            });
            return;
        }

        $.ajax({
            url: 'LecturerCalendar.aspx/AddEvent',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                title: titleVal,
                desc: $("#desc").val(),
                start: startDate,
                end: $("#endDate").val(),
                type: $("#eventType").val(),
                visibility: "Private"
            }),
            success: function (res) {
                if (res.d.status === "success") {
                    closeModal();
                    calendar.refetchEvents();
                    Swal.fire({
                        icon: 'success',
                        title: 'Event Created!',
                        text: 'Your new event has been added to the calendar.',
                        confirmButtonColor: '#7B61FF',
                        timer: 2500,
                        timerProgressBar: true,
                        showConfirmButton: false
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Failed to Create Event',
                        text: res.d.message || 'Something went wrong. Please try again.',
                        confirmButtonColor: '#7B61FF'
                    });
                }
            },
            error: function () {
                Swal.fire({
                    icon: 'error',
                    title: 'Network Error',
                    text: 'Unable to connect to the server. Please try again.',
                    confirmButtonColor: '#7B61FF'
                });
            }
        });
    }

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
            var isOwner = event.isOwner === true;
            var actionBtns = isOwner
                ? '<div class="card-actions">' +
                '<button type="button" class="action-btn btn-edit" onclick="openEditModal(\'' + event.id + '\')"><i class="fa-solid fa-pencil"></i></button>' +
                '<button type="button" class="action-btn btn-delete" onclick="deleteEvent(\'' + event.id + '\')"><i class="fa-solid fa-trash-can"></i></button>' +
                '</div>'
                : '';
            var sourceTag = event.source === 'admin'
                ? '<span style="font-size:10px;background:#f1f3f4;color:#555;padding:2px 6px;border-radius:4px;margin-left:6px;">Admin</span>'
                : '';
            var cardHtml =
                '<div class="event-card ' + (eventDate < today ? 'past-event' : '') + '" style="border-left: 6px solid ' + accentColor + ';">' +
                '<div class="event-card-date">' + dateRange + sourceTag + '</div>' +
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
        $("#startDate").val(eventObj.startStr);

        // ✅ FullCalendar end date is exclusive, subtract 1 day for display
        var endVal = eventObj.endStr || eventObj.startStr;
        if (eventObj.endStr) {
            var d = new Date(eventObj.endStr);
            d.setDate(d.getDate() - 1);
            endVal = d.toISOString().split('T')[0];
        }
        $("#endDate").val(endVal);

        var savedType = eventObj.extendedProps.type || "General";
        $("#eventType").val(savedType);
        $("#typePicker .type-tag").removeClass("active");
        $(`#typePicker .type-tag[data-type='${savedType}']`).addClass("active");

        $("#modalHeaderTitle").text("Edit Event");
        $("#saveEvent").hide();
        $("#updateEventBtn").show();
        openModal();
    }

    function updateEvent() {
        const titleVal = $("#title").val().trim();
        if (!titleVal) {
            Swal.fire({ icon: 'warning', title: 'Title Required', confirmButtonColor: '#7B61FF' });
            return;
        }

        $.ajax({
            url: 'LecturerCalendar.aspx/UpdateEvent',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                id: parseInt($("#editEventId").val(), 10),
                title: titleVal,
                desc: $("#desc").val(),
                start: $("#startDate").val(),
                end: $("#endDate").val(),
                type: $("#eventType").val(),
                visibility: "Private"
            }),
            success: function (res) {
                if (res.d.status === "success") {
                    closeModal();
                    calendar.refetchEvents();
                    Swal.fire({
                        icon: 'success',
                        title: 'Event Updated!',
                        confirmButtonColor: '#7B61FF',
                        timer: 2000,
                        showConfirmButton: false
                    });
                } else {
                    Swal.fire({ icon: 'error', title: 'Update Failed', text: res.d.message, confirmButtonColor: '#7B61FF' });
                }
            },
            error: function () {
                Swal.fire({ icon: 'error', title: 'Network Error', confirmButtonColor: '#7B61FF' });
            }
        });
    }

    function deleteEvent(id) {
        Swal.fire({
            title: 'Delete Event?',
            text: 'This event will be permanently removed from your calendar.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d93025',
            cancelButtonColor: '#7B61FF',
            confirmButtonText: '<i class="fa-solid fa-trash-can"></i> Delete',
            cancelButtonText: 'Cancel'
        }).then(function (result) {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'LecturerCalendar.aspx/DeleteEvent',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ id: parseInt(id, 10) }),
                    success: function (response) {
                        if (response.d && response.d.status === "success") {
                            calendar.refetchEvents();
                            Swal.fire({
                                icon: 'success',
                                title: 'Event Deleted',
                                text: 'The event has been removed from your calendar.',
                                confirmButtonColor: '#7B61FF',
                                timer: 2500,
                                timerProgressBar: true,
                                showConfirmButton: false
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Delete Failed',
                                text: (response.d && response.d.message) || 'You may not have permission to delete this event.',
                                confirmButtonColor: '#7B61FF'
                            });
                        }
                    },
                    error: function (xhr) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Network Error',
                            text: 'An unexpected error occurred. Please try again.',
                            confirmButtonColor: '#7B61FF'
                        });
                    }
                });
            }
        });
    }
</script>
</asp:Content>