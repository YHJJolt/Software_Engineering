<%@ Page Title="CourseAllocation" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="CourseAllocation.aspx.cs" Inherits="SchoolSystem.CourseAllocation" %>
<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="course-assign-page">

    <%-- ===== PAGE HEADER ===== --%>
    <div class="header">
        <h1><i class="fas fa-chalkboard-teacher"></i>Course Allocation</h1>
    </div>

    <%-- ===== GLOBAL SESSION FILTER ===== --%>
    <div class="session-filter-bar">
        <div class="session-filter-inner">
            <i class="fas fa-filter session-filter-icon"></i>
            <label class="session-label">Academic Session:</label>
            <span class="session-badge">
                <asp:Literal ID="litActiveSession" runat="server" Text="JAN 2026" />
            </span>
        </div>
    </div>

    <%-- Single UpdatePanel covers both the form and the table so edit can repopulate dropdowns --%>
    <asp:UpdatePanel ID="upWorkspace" runat="server" UpdateMode="Conditional">
        <ContentTemplate>

    <%-- ===== SPLIT WORKSPACE ===== --%>
    <div class="assign-workspace">

        <%-- ===== LEFT: ASSIGNMENT FORM ===== --%>
        <div class="assign-form-panel">
            <div class="panel-header">
                <i class="fas fa-plus-circle"></i>
                <h2>Create Assignment</h2>
            </div>

            <asp:HiddenField ID="hdnEditAssignId" runat="server" Value="0" />
            <asp:HiddenField ID="hdnDeleteId"     runat="server" />

            <%-- Hidden button — real postback target for SweetAlert delete confirm --%>
            <asp:Button ID="btnDeleteConfirm" runat="server" Text="" Style="display:none;"
                OnClick="BtnDeleteAssign_Click" CausesValidation="false" />

            <div class="form-group">
                <label><i class="fas fa-book-open form-icon"></i> Course</label>
                <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-control" />
                <asp:RequiredFieldValidator ID="rfvCourse" runat="server"
                    ControlToValidate="ddlCourse" InitialValue="0"
                    CssClass="field-error" ErrorMessage="Please select a course."
                    ValidationGroup="AssignForm" Display="Dynamic" />
            </div>

            <div class="form-group">
                <label><i class="fas fa-user-tie form-icon"></i> Lecturer</label>
                <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-control" />
                <asp:RequiredFieldValidator ID="rfvLecturer" runat="server"
                    ControlToValidate="ddlLecturer" InitialValue="0"
                    CssClass="field-error" ErrorMessage="Please select a lecturer."
                    ValidationGroup="AssignForm" Display="Dynamic" />
            </div>

            <div class="form-group">
                <label><i class="fas fa-toggle-on form-icon"></i> Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                    <asp:ListItem Text="Active"   Value="Active" />
                    <asp:ListItem Text="Inactive" Value="Inactive" />
                </asp:DropDownList>
            </div>

            <div class="form-actions">
                <asp:Button ID="btnAssign" runat="server" Text="Assign Lecturer"
                    CssClass="btn btn-primary btn-assign"
                    OnClick="BtnAssign_Click"
                    ValidationGroup="AssignForm" />
                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                    CssClass="btn btn-secondary" Visible="false"
                    OnClick="BtnCancelEdit_Click" CausesValidation="false" />
            </div>
        </div>

        <%-- ===== RIGHT: ALLOCATIONS TABLE ===== --%>
        <div class="assign-table-panel">
            <asp:GridView ID="gvAssignments" runat="server" CssClass="assign-table"
                AutoGenerateColumns="False" GridLines="None"
                OnRowCommand="GvAssignments_RowCommand">
                <EmptyDataRowStyle CssClass="empty-row" />
                <Columns>
                    <asp:BoundField DataField="course_code"   HeaderText="Course Code" />
                    <asp:BoundField DataField="course_name"   HeaderText="Course Name" />
                    <asp:BoundField DataField="lecturer_name" HeaderText="Assigned Lecturer" />

                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge badge-<%# Eval("assign_status").ToString().ToLower() %>'>
                                <%# Eval("assign_status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="action-container">
                                <asp:LinkButton ID="btnEdit" runat="server"
                                    CssClass="btn-icon btn-edit" ToolTip="Edit"
                                    CommandName="EditAssign"
                                    CommandArgument='<%# Eval("assign_id") %>'>
                                    <i class="fas fa-pencil-alt"></i>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server"
                                    CssClass="btn-icon btn-delete" ToolTip="Remove"
                                    CommandName="DeleteAssign"
                                    CommandArgument='<%# Eval("assign_id") %>'
                                    OnClientClick='<%# "return confirmRemove(" + Eval("assign_id") + ");" %>'>
                                    <i class="fas fa-trash-alt"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <i class="fas fa-inbox empty-icon"></i>
                <p>No allocations for this session.</p>
                <small>Use the form on the left to create the first assignment.</small>
            </asp:Panel>
        </div>

    </div><%-- end assign-workspace --%>

        </ContentTemplate>
    </asp:UpdatePanel>

</div><%-- end course-assign-page --%>

<script>
    // @ts-nocheck
    function confirmRemove(assignId) {
        Swal.fire({
            title: 'Remove Assignment?',
            text: 'This will unlink the lecturer from the course for this session.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#E74C3C',
            cancelButtonColor: '#94a3b8',
            confirmButtonText: 'Yes, remove it!'
        }).then(function (result) {
            if (result.isConfirmed) {
                document.getElementById('<%= hdnDeleteId.ClientID %>').value = assignId;
                __doPostBack('<%= btnDeleteConfirm.UniqueID %>', '');
            }
        });
    return false;
}
</script>
</asp:Content>
