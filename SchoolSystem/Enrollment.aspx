<%@ Page Title="Enrollment" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Enrollment.aspx.cs" Inherits="SchoolSystem.Enrollment" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* General styles*/
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .search-box { 
            padding: 8px 12px; 
            width: 250px; 
            border: 1px solid #ccc; 
            border-radius: 6px; 
            font-size: 14px;
        }

        .action-bar {
            display: flex;
            justify-content: space-between; 
            align-items: center;
            margin-bottom: 25px;
            width: 100%;
            flex-wrap: wrap;
            gap: 15px;
        }

        .search-group, .button-group {
            display: flex;
            gap: 10px; 
        }

        /* Naming - repeated names */
        .name-primary { font-weight: 600; color: #2c3e50; }
        .name-dim     { font-weight: 400; color: #bbb; }

        /* Paging */
        .paging-container {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
            font-size: 14px;
            color: #444;
        }
        .page-dropdown {
            padding: 4px 8px;
            border-radius: 20px;
            border: 1px solid #ccc;
            outline: none;
        }

        /* Tab */
        .tab-container {
            display: flex;
            border-bottom: 2px solid #e0e0e0;
            margin-bottom: 20px;
        }
        .tab-btn {
            padding: 10px 28px;
            background: transparent;
            border: none;
            font-size: 14px;
            font-weight: 600;
            color: #666;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .tab-btn:hover {
            color: #2c3e50;
            text-decoration: none;
        }
        .tab-active {
            background: #1a1a2e !important;
            color: white !important;
            border-left: 4px solid #C5A059 !important;
            text-decoration: none !important;
        }
        .tab-active:hover {
            color: white !important;
            text-decoration: none !important;
        }

        /* Button Style */
        .btn { 
            padding: 9px 18px; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 14px; 
        }
        .btn-primary   { background: #C5A059; color: white; }
        .btn-primary:hover { background: #CCB68B; }
        .btn-secondary { background: #7D8AFF; color: white; }
        .btn-secondary:hover { background: #B4B9F0; }
        .btn-success   { background: #28a745; color: white; }
        .btn-success:hover { background: #218838; }
        .btn-warning   { background: #CC4343; color: white; }
        .btn-warning:hover { background: #ff5c5c; }
        
        /* Action buttons in table – smaller */
        .btn-action {
            padding: 5px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
        }
        .btn-action:disabled {
            opacity: 0.45;
            cursor: not-allowed;
        }
        .btn-approve { background: #62D17B; color: white; }
        .btn-approve:hover { background: #218838; }
        .btn-reject  { background: #E89143; color: white; }
        .btn-reject:hover  { background: #E87713; }
        .btn-disenroll { background: #D15454; color:white; }
        .btn-disenroll:hover { background: #D62F2F;}
        .btn-delete { background: #4E52D9; color:white; }
        .btn-delete:hover { background: #465B80;}

        /* Table */
        .course-table { 
            width: 100%; 
            border-collapse: collapse; 
            background: white; 
            border-radius: 10px; 
            overflow: hidden; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.08); 
        }
        .course-table th { 
            background: #2c3e50; 
            color: white; 
            padding: 14px 16px; 
            text-align: center; 
            font-size: 14px; 
        }
        .course-table td { 
            padding: 13px 16px; 
            border-bottom: 1px solid #f0f0f0; 
            font-size: 14px; 
            color: #444;
            text-align: center;
        }
        .course-table tr:last-child td { border-bottom: none; }
        .course-table tr:hover td    { background: #f8fafc; }

        /* Status badges */
        .badge { 
            padding: 4px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600; 
        }
        .badge-pending  { background: #fff3cd; color: #856404; }
        .badge-approved { background: #d4edda; color: #155724; }
        .badge-rejected { background: #f8d7da; color: #721c24; }
        .badge-dropped  { background: #e9ecef; color: #495057; border: 1px solid #ced4da; }

        /* Action Buttons Container */
        .action-container {
            display: flex;
            gap: 8px; 
            align-items: center;
            justify-content: center;
        }

        .filter-group {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .bulk-actions {
            display: flex;
            gap: 10px;
        }

        /* Filter */
        .filter-dropdown {
            padding: 8px 12px;
            width: 140px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server"> 
    <div class="header">
        <h1>Enrollment Management</h1>
    </div>

    <div class="action-bar">
        <div class="filter-group">
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true"
                OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Status</asp:ListItem>
                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                <asp:ListItem Value="Approved">Approved</asp:ListItem>
                <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                <asp:ListItem Value="Dropped">Dropped</asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" placeholder="Search ..."
                onkeyup="if(event.keyCode===13) document.getElementById('<%= btnSearch.ClientID %>').click();">
            </asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search" 
                CssClass="btn btn-primary" OnClick="BtnSearchEnrollment_Click" />
        </div>
        
        <div class="bulk-actions">
            <asp:Button ID="btnApproveSelected" runat="server" Text="Approve in Bulk" 
                CssClass="btn btn-success" OnClick="BtnApproveSelected_Click"
                OnClientClick="return confirmEnrollment(this, 'Approved');" UseSubmitBehavior="false" />
            
            <asp:Button ID="btnRejectSelected" runat="server" Text="Reject in Bulk" 
                CssClass="btn btn-warning" OnClick="BtnRejectSelected_Click"
                OnClientClick="return confirmEnrollment(this, 'Rejected');" UseSubmitBehavior="false" />
                
            <asp:Button ID="btnDeleteSelected" runat="server" Text="Delete in Bulk" 
                CssClass="btn btn-delete" OnClick="BtnDeleteSelected_Click"
                OnClientClick="return confirmBulkDelete(this);" UseSubmitBehavior="false" />
        </div>
    </div>

    <asp:HiddenField ID="hdnActiveTab" runat="server" Value="Students" />
    <div class="tab-container">
        <asp:LinkButton ID="tabStudents" runat="server" CssClass="tab-btn tab-active"
            CommandArgument="Students" OnClick="Tab_Click">Students</asp:LinkButton>
        <asp:LinkButton ID="tabLecturers" runat="server" CssClass="tab-btn"
            CommandArgument="Lecturers" OnClick="Tab_Click">Lecturers</asp:LinkButton>
    </div>

    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Label ID="lblMessage" runat="server" Visible="false" 
                Style="display:block; margin-bottom:12px; padding:10px 16px; border-radius:6px; font-size:14px;" />

            <asp:GridView ID="Enrollments" runat="server" CssClass="course-table"
                AutoGenerateColumns="False" EmptyDataText="No enrollment records found."
                AllowPaging="True" PageSize="10"
                OnPageIndexChanging="Enrollments_PageIndexChanging"
                DataKeyNames="enrollment_id,status">

                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <input type="checkbox" id="checkAll" onclick="toggleAll(this)" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" runat="server" />
                            <asp:HiddenField ID="hdnEnrollmentId" runat="server" Value='<%# Eval("enrollment_id") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate>
                            <asp:Label ID="lblName" runat="server"
                                Text='<%# Eval("name") %>'
                                CssClass='<%# IsSameName(Container.DataItemIndex, Eval("name").ToString()) ? "name-dim" : "name-primary" %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="email"        HeaderText="Email" />
                    <asp:BoundField DataField="program_name"     HeaderText="Program Name" />
                    <asp:BoundField DataField="course_code"      HeaderText="Course Code" />
                    <asp:BoundField DataField="course_name"      HeaderText="Course Name" />
                    <asp:BoundField DataField="enrollment_date"  HeaderText="Enrollment Date" DataFormatString="{0:dd MMM yyyy}" />

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge badge-<%# Eval("status").ToString().ToLower() %>'>
                                <%# Eval("status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <div class="action-container">
                                <%-- Approve Button --%>
                                <asp:Button ID="btnApprove" runat="server" Text="Approve" CssClass="btn-action btn-approve"
                                    CommandArgument='<%# Eval("enrollment_id") %>' OnClick="BtnApprove_Click"
                                    Visible='<%# Eval("status").ToString().ToLower() == "pending" %>'
                                    OnClientClick="return confirmEnrollment(this, 'Approved');" UseSubmitBehavior="false" />

                                <%-- Reject Button --%>
                                <asp:Button ID="btnReject" runat="server" Text="Reject" CssClass="btn-action btn-reject"
                                    CommandArgument='<%# Eval("enrollment_id") %>' OnClick="BtnReject_Click"
                                    Visible='<%# Eval("status").ToString().ToLower() == "pending" %>'
                                    OnClientClick="return confirmEnrollment(this, 'Rejected');" UseSubmitBehavior="false" />

                                <%-- Disenroll Button --%>
                                <asp:Button ID="btnDisenroll" runat="server" Text="Disenroll" CssClass="btn-action btn-disenroll"
                                    CommandArgument='<%# Eval("enrollment_id") %>' OnClick="BtnDisenroll_Click"
                                    Visible='<%# Eval("status").ToString().ToLower() == "approved" %>'
                                    OnClientClick="return confirmDisenroll(this);" UseSubmitBehavior="false" />

                                <%-- Delete Button --%>
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn-action btn-delete"
                                    CommandArgument='<%# Eval("enrollment_id") %>' OnClick="BtnDeleteEnrollment_Click"
                                    Visible='<%# Eval("status").ToString().ToLower() == "rejected" || Eval("status").ToString().ToLower() == "dropped" %>'
                                    OnClientClick="return confirmDeleteEnrollment(this);" UseSubmitBehavior="false" />
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlStatusFilter" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="btnSearch"          EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnApproveSelected" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnRejectSelected"  EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnDeleteSelected"  EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>

    <div class="paging-container">
        <span>Rows per page:</span>
        <asp:TextBox ID="txtPageSize" runat="server" Text="10" CssClass="page-dropdown" Width="50px" />
        <asp:Button ID="BtnApplyPageSize" runat="server" OnClick="BtnApplyPageSize_Click" style="display:none;" />
        <asp:Label ID="TotalRows" runat="server" Text="of 0 rows" />
    </div>

    <script>
        // Show changes made message for 3 seconds
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
            var msg = document.getElementById('<%= lblMessage.ClientID %>');
            if (msg && msg.style.display !== 'none' && msg.innerText.trim() !== '') {
                setTimeout(() => msg.style.display = 'none', 3000);
            }
        });

        function toggleAll(src) {
            document.querySelectorAll("input[id*='chkSelect']").forEach(cb => cb.checked = src.checked);
        }

        function confirmEnrollment(btn, action) {
            var title = action === 'Approved' ? 'Approve Enrollment?' : 'Reject Enrollment?';
            var color = action === 'Approved' ? '#28a745' : '#CC4343';

            Swal.fire({
                title: title,
                text: 'This action cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: color,
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, I\'m sure!'
            }).then(function (result) {
                if (result.isConfirmed) {
                    if (typeof __doPostBack === 'function') {
                        __doPostBack(btn.name || btn.id, '');
                    } else {
                        btn.removeAttribute('onclick');
                        btn.click();
                    }
                }
            });
            return false;
        }

        function confirmDisenroll(btn) {
            Swal.fire({
                title: 'Disenroll Student?',
                text: 'This will change the status to Dropped and remove them from the course.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#CC4343',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, Disenroll'
            }).then(function (result) {
                if (result.isConfirmed) {
                    if (typeof __doPostBack === 'function') {
                        __doPostBack(btn.name || btn.id, '');
                    } else {
                        btn.removeAttribute('onclick');
                        btn.click();
                    }
                }
            });
            return false;
        }

        function confirmBulkDelete(btn) {
            Swal.fire({
                title: 'Bulk Delete?',
                text: 'This will permanently remove all selected records.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, Delete Them'
            }).then(function (result) {
                if (result.isConfirmed) {
                    if (typeof __doPostBack === 'function') {
                        __doPostBack(btn.name || btn.id, '');
                    } else {
                        btn.removeAttribute('onclick');
                        btn.click();
                    }
                }
            });
            return false;
        }

        function confirmDeleteEnrollment(btn) {
            Swal.fire({
                title: 'Permanently Delete?',
                text: 'This will remove the enrollment record from the system.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, Delete'
            }).then(function (result) {
                if (result.isConfirmed) {
                    if (typeof __doPostBack === 'function') {
                        __doPostBack(btn.name || btn.id, '');
                    } else {
                        btn.removeAttribute('onclick');
                        btn.click();
                    }
                }
            });
            return false;
        }
    </script>
</asp:Content>