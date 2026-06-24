<%@ Page Title="Enrollment" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Enrollment.aspx.cs" Inherits="SchoolSystem.Enrollment" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="ContentTitle" ContentPlaceHolderID="TopbarTitle" runat="server">
    <h1 style="margin: 0; font-size: 24px; color: #1e293b;">
        <i class="fas fa-user-plus" style="margin-right: 10px;"></i>Enrollment Management
    </h1>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="enrollment-page">

    <div class="action-bar">
        <div class="filter-group">
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true"
                OnSelectedIndexChanged="DdlStatusFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Status</asp:ListItem>
                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                <asp:ListItem Value="Approved">Approved</asp:ListItem>
                <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                <asp:ListItem Value="Dropped">Dropped</asp:ListItem>
            </asp:DropDownList>
            <asp:DropDownList ID="ddlSessionFilter" runat="server" CssClass="filter-dropdown" AutoPostBack="true"
                OnSelectedIndexChanged="DdlSessionFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Sessions</asp:ListItem>
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

            <asp:Button ID="btnExportSelected" runat="server" Text="Export to Excel"
                CssClass="btn btn-secondary" OnClick="BtnExportSelected_Click"
                OnClientClick="return confirmExportSelected();" CausesValidation="false" />
        </div>
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
                    <asp:BoundField DataField="email"             HeaderText="Email" />
                    <asp:BoundField DataField="program_name"      HeaderText="Program Name" />
    
                    <asp:BoundField DataField="academic_session" HeaderText="Session" ItemStyle-HorizontalAlign="Center" />
    
                    <asp:BoundField DataField="course_code"       HeaderText="Course Code" />
                    <asp:BoundField DataField="course_name"       HeaderText="Course Name" />
                    <asp:BoundField DataField="enrollment_date"   HeaderText="Enrollment Date" DataFormatString="{0:dd MMM yyyy}" />

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
            <asp:AsyncPostBackTrigger ControlID="ddlSessionFilter" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="btnSearch"          EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnApproveSelected" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnRejectSelected"  EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnDeleteSelected"  EventName="Click" />
            <asp:PostBackTrigger ControlID="btnExportSelected" />
        </Triggers>
    </asp:UpdatePanel>

    <div class="paging-container">
        <span>Rows per page:</span>
        <asp:TextBox ID="txtPageSize" runat="server" Text="10" CssClass="page-dropdown" Width="50px" />
        <asp:Button ID="BtnApplyPageSize" runat="server" OnClick="BtnApplyPageSize_Click" style="display:none;" />
        <asp:Label ID="TotalRows" runat="server" Text="of 0 rows" />
    </div>

    <script>
    // @ts-nocheck
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

function confirmExportSelected() {
    var anyChecked = Array.from(document.querySelectorAll("input[id*='chkSelect']")).some(cb => cb.checked);
    if (!anyChecked) {
        Swal.fire('No rows selected', 'Please select at least one row to export.', 'warning');
        return false;
    }
    return true;
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
    </div>
</asp:Content>