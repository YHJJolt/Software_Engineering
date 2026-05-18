<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Calendar.aspx.cs" Inherits="SchoolSystem.Calendar" MasterPageFile="~/AdminMaster.Master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
<asp:ScriptManagerProxy runat="server" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
<link href="Admin.css" rel="stylesheet" type="text/css" />

<div class="calendar-page">
<div class="header">
    <h1><i class="fas fa-calendar-alt"></i>Calendar</h1>
</div>
<div class="calendar-container">
    
    <button type="button" class="btn-add-event" onclick="prepareAddModal()">
        <i class="fa-solid fa-plus"></i> Add New Event
    </button>

    <div style="display: flex; gap: 30px; align-items: flex-start; justify-content: center; margin-bottom: 30px;">
        <div class="calendar-main-box">
            <div id="calendar" runat="server"></div>

            <div style="margin-top: 40px; border-top: 1px solid rgba(18, 20, 32, 0.1); padding-top: 20px;">
                <div style="display: flex; gap: 30px; align-items: flex-start;">
                    <div style="flex: 1;">
                        <h3 style="display: flex; align-items: center; gap: 10px; font-weight: 700; color: #121420; margin-bottom: 20px;">
                            Upcoming Events <i class="fa-solid fa-calendar-day" style="font-size: 16px; opacity: 0.5;"></i>
                        </h3>
                        <div id="upcomingEventsContainer"></div>
                    </div>

                    <div style="flex: 1; border-left: 1px solid #eee; padding-left: 30px;">
                        <h3 style="display: flex; align-items: center; gap: 10px; font-weight: 700; color: #888; margin-bottom: 20px;">
                            Past Events <i class="fa-solid fa-clock-rotate-left" style="font-size: 16px; opacity: 0.5;"></i>
                        </h3>
                        <div id="pastEventsContainer"></div>
                    </div>
                </div>
            </div>
        </div>

        <div id="dateSidebar" class="calendar-sidebar">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #7B61FF; padding-bottom: 10px;">
                <div id="selectedDateTitle" style="font-weight: 700; font-size: 1.1rem; color: #121420;">Select a date</div>
                <button type="button" onclick="closeSidebar()" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #999; line-height: 1;">&times;</button>
            </div>
            <div id="sidebarEventsList">
                <p style="color: #888; font-size: 13px;">Click a date on the calendar to see details.</p>
            </div>
        </div>
    </div> 
</div>

<!-- MODAL -->
<div id="eventModal" class="modal">
    <div class="modal-content">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
            <div style="display: flex; align-items: center; gap: 10px;">
                <i class="fa-solid fa-plus" style="font-size: 14px; color: #5f6368;"></i>
                <h3 id="modalHeaderTitle" style="margin: 0; font-weight: 500; font-size: 18px; color: #3c4043;">Add Event</h3>
            </div>
            <button type="button" onclick="closeModal()" style="background: none; border: none; font-size: 22px; cursor: pointer; color: #5f6368;">&times;</button>
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
            <textarea id="desc" placeholder="Add description" class="modern-input" style="height: 80px; border: 1px solid #eee !important; border-radius: 8px; padding: 10px; margin-top: 5px;"></textarea>
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

<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    var calendar;
    const typeColorMap = {
        "General": "#1967d2",
        "Exam": "#d93025",
        "Holiday": "#1e8e3e",
        "Enrolment": "#9334e6"
    };

    function openModal() { document.getElementById("eventModal").style.display = "block"; }
    function closeModal() { document.getElementById("eventModal").style.display = "none"; }
    function closeSidebar() { $("#dateSidebar").fadeOut(300); }

    function prepareAddModal() {
        $("#modalHeaderTitle").text("Add schedule");
        $("#saveEvent").show();
        $("#updateEventBtn").hide();
        $("#editEventId, #title, #desc, #startDate, #endDate").val("");
        $(".type-tag").removeClass("active");
        $(".type-tag").first().addClass("active");
        $("#eventType").val("General");
        openModal();
    }

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
                "General": { bg: "#e8f0fe", text: "#1967d2" },
                "Exam": { bg: "#fce8e6", text: "#d93025" },
                "Holiday": { bg: "#e6ffed", text: "#1e8e3e" },
                "Enrolment": { bg: "#f3e8fd", text: "#9334e6" }
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

    function renderEventCounts(events) {
        $(".event-count-badge").remove();
        const counts = {};
        events.forEach(e => {
            const d = e.start.split('T')[0];
            counts[d] = (counts[d] || 0) + 1;
        });
        Object.keys(counts).forEach(date => {
            const cell = $(`.fc-daygrid-day[data-date="${date}"] .fc-daygrid-day-top`);
            if (cell.length > 0) {
                cell.append(`<span class="event-count-badge">${counts[date]} Event${counts[date] > 1 ? 's' : ''}</span>`);
            }
        });
    }

    $(document).ready(function () {
        $("#dateSidebar").hide();
        $(".type-tag").click(function () {
            $(".type-tag").removeClass("active");
            $(this).addClass("active");
            $("#eventType").val($(this).data("type"));
        });

        $("#saveEvent").click(function () { saveEvent(); });

        var calendarEl = document.getElementById('<%= calendar.ClientID %>');
        if (!calendarEl) return;

        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            height: 'auto',
            aspectRatio: 1.5,
            dateClick: function (info) { showSidebar(info.dateStr); },
            events: function (fetchInfo, successCallback) {
                $.ajax({
                    url: 'Calendar.aspx/GetEvents',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    data: '{}',
                    success: function (response) {
                        const rawEvents = response.d || [];
                        const coloredEvents = rawEvents.map(event => ({
                            ...event,
                            color: typeColorMap[event.type] || "#7B61FF"
                        }));
                        successCallback(coloredEvents);
                        renderEventCards(coloredEvents);
                        renderEventCounts(coloredEvents);
                    }
                });
            }
        });
        calendar.render();

        // DEEP LINKING LOGIC: Check URL for date parameter
        const urlParams = new URLSearchParams(window.location.search);
        const targetDate = urlParams.get('date');
        if (targetDate) {
            calendar.gotoDate(targetDate); // Jump to the month
            // Small delay to ensure events are loaded before opening sidebar
            setTimeout(() => { showSidebar(targetDate); }, 300);
        }
    });

    function saveEvent() {
        $.ajax({
            url: 'Calendar.aspx/AddEvent',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify({
                title: $("#title").val(),
                desc: $("#desc").val(),
                start: $("#startDate").val(),
                end: $("#endDate").val(),
                type: $("#eventType").val()
            }),
            success: function (response) {
                if (response.d.status === "success") {
                    closeModal();
                    calendar.refetchEvents();
                }
            }
        });
    }

    function renderEventCards(events) {
        const upcomingContainer = $("#upcomingEventsContainer");
        const pastContainer = $("#pastEventsContainer");
        upcomingContainer.empty();
        pastContainer.empty();
        events.sort((a, b) => new Date(a.start) - new Date(b.start));
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        events.forEach(event => {
            const eventDate = new Date(event.start);
            let dateRange = event.start;
            if (event.end && event.end !== event.start) dateRange += ` — ${event.end}`;
            const accentColor = typeColorMap[event.type] || "#7B61FF";
            const cardHtml = `
                <div class="event-card ${eventDate < today ? 'past-event' : ''}" style="border-left: 6px solid ${accentColor};">
                    <div class="event-card-date">${dateRange}</div>
                    <h4 class="event-card-title">${event.title}</h4>
                    <div class="event-card-desc">${event.description || "No description provided."}</div>
                    <div class="card-actions">
                        <button type="button" class="action-btn btn-edit" onclick="openEditModal('${event.id}')"><i class="fa-solid fa-pencil"></i></button>
                        <button type="button" class="action-btn btn-delete" onclick="deleteEvent('${event.id}')"><i class="fa-solid fa-trash-can"></i></button>
                    </div>
                </div>`;
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
        $("#endDate").val(eventObj.endStr ? eventObj.endStr : eventObj.startStr);
        var savedType = eventObj.extendedProps.type;
        $("#eventType").val(savedType);
        $(".type-tag").removeClass("active");
        $(`.type-tag[data-type='${savedType}']`).addClass("active");
        $("#modalHeaderTitle").text("Edit Event");
        $("#saveEvent").hide();
        $("#updateEventBtn").show();
        openModal();
    }

    function updateEvent() {
        $.ajax({
            url: 'Calendar.aspx/UpdateEvent',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify({
                id: $("#editEventId").val(),
                title: $("#title").val(),
                desc: $("#desc").val(),
                start: $("#startDate").val(),
                end: $("#endDate").val(),
                type: $("#eventType").val()
            }),
            success: function (response) {
                if (response.d.status === "success") {
                    closeModal();
                    calendar.refetchEvents();
                }
            }
        });
    }

    function deleteEvent(id) {
        if (confirm("Are you sure you want to delete this event?")) {
            $.ajax({
                url: 'Calendar.aspx/DeleteEvent',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ id: id }),
                success: function (response) {
                    if (response.d.status === "success") {
                        calendar.refetchEvents();
                    }
                }
            });
        }
    }
</script>
</div>
</asp:Content>