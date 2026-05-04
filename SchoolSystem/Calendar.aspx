<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Calendar.aspx.cs" Inherits="SchoolSystem.Calendar" MasterPageFile="~/AdminMaster.Master"%>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<!-- 🔥 STYLES -->
<style>
.calendar-container {
    max-width: 1000px;
    margin: 20px auto;
}

/* Header */
.calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.calendar-title {
    font-size: 28px;
    font-weight: bold;
}

/* Add button */
.add-btn {
    background-color: #5b7db1;
    color: white;
    padding: 6px 14px;
    border-radius: 8px;
    border: none;
    cursor: pointer;
}

/* Event list */
.event-list {
    margin-top: 20px;
}

/* Yellow event card */
.event-card {
    background: #f5eecb;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    width: 300px;
    border: 1px solid #e0d8a5;
}

.event-title {
    font-weight: bold;
}

.event-time {
    font-size: 12px;
    color: #555;
}

.modal {
    display: none;
    position: fixed;
    z-index: 9999; 
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.5);
}

.modal-content {
    position: relative;
    z-index: 10000;
    background: white;
    padding: 20px;
    width: 300px;
    margin: 100px auto;
    border-radius: 10px;
}

.modal-content input,
.modal-content textarea,
.modal-content select {
    width: 100%;
    margin-bottom: 10px;
}

</style>

<!-- 🔥 HEADER -->
<div class="calendar-container">

    <div class="calendar-header">
        <div class="calendar-title">Calendar</div>
        <button type="button" class="add-btn" onclick="openModal()">Add Event</button>
    </div>

    <!-- CALENDAR -->
    <div id="calendar" runat="server"></div>

    <!-- 🔥 ADD EVENT MODAL -->
    <div id="eventModal" class="modal">
        <div class="modal-content">
            <h3>Add Event</h3>

            <input type="text" id="title" placeholder="Event Title" /><br />
            <textarea id="desc" placeholder="Description"></textarea><br />

            <input type="date" id="startDate" />
            <input type="date" id="endDate" /><br />

            <select id="eventType">
                <option value="General">General</option>
                <option value="Exam">Exam</option>
                <option value="Holiday">Holiday</option>
                <option value="Enrollment">Enrollment</option>
            </select><br />

            <button type="button" id="saveEvent">Save</button>
            <button onclick="closeModal()">Cancel</button>
        </div>
    </div>

    <!-- EVENT LIST -->
    <div class="event-list" id="eventList"></div>

</div>

<!-- LIBRARIES -->
<link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 🔥 SCRIPT -->
<script>

    function openModal() {
        document.getElementById("eventModal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("eventModal").style.display = "none";
    }

    $(document).ready(function () {

        $("#addEventBtn").click(function () {
            openModal();
        });

        $("#saveEvent").click(function () {

            var data = {
                title: $("#title").val(),
                desc: $("#desc").val(),
                start: $("#startDate").val(),
                end: $("#endDate").val(),
                type: $("#eventType").val()
            };

            $.ajax({
                url: 'Calendar.aspx/AddEvent',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(data),

                success: function () {
                    alert("Event Added!");
                    closeModal();

                    location.reload(); // 🔥 quick refresh
                }
            });
        });

        var calendarEl = document.getElementById('<%= calendar.ClientID %>');
    var eventListEl = document.getElementById('eventList');

    function renderEventList(events) {
        eventListEl.innerHTML = "";

        events.forEach(function (e) {
            var card = `
                <div class="event-card">
                    <div class="event-time">${e.start}</div>
                    <div class="event-title">${e.title}</div>
                    <div>${e.description || ''}</div>
                </div>
            `;
            eventListEl.innerHTML += card;
        });
    }

    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: 'dayGridMonth',
        height: 'auto',

        events: function (fetchInfo, successCallback, failureCallback) {
            $.ajax({
                url: 'Calendar.aspx/GetEvents',
                method: 'POST',
                contentType: 'application/json',
                success: function (response) {
                    var events = response.d;
                    successCallback(events);

                    // 🔥 also render bottom list
                    renderEventList(events);
                },
                error: function () {
                    failureCallback();
                }
            });
        },

        eventClick: function (info) {
            alert(
                "Event: " + info.event.title + "\n\n" +
                "Description: " + (info.event.extendedProps.description || "No details")
            );
        }
    });

    calendar.render();

});
</script>

</asp:Content>