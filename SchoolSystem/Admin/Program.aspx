<%@ Page Title="Program Management" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Program.aspx.cs" Inherits="SchoolSystem.Program" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="program-mgmt-page">
    <%-- Header --%>
    <div class="header">
        <h1><i class="fas fa-graduation-cap"></i>Program Management</h1>
    </div>

    <%-- Action Bar --%>
    <div class="action-bar">
        <div class="search-group">
            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="filter-dropdown"
                AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Status</asp:ListItem>
                <asp:ListItem Value="1">Active</asp:ListItem>
                <asp:ListItem Value="0">Discontinued</asp:ListItem>
            </asp:DropDownList>

            <asp:DropDownList ID="ddlLevelFilter" runat="server" CssClass="filter-dropdown"
                AutoPostBack="true" OnSelectedIndexChanged="ddlLevelFilter_SelectedIndexChanged">
                <asp:ListItem Value="">All Levels</asp:ListItem>
            </asp:DropDownList>

            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box"
                placeholder="Search ..."
                onkeyup="if(event.keyCode===13) document.getElementById('<%= btnSearch.ClientID %>').click();">
            </asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search"
                CssClass="btn btn-primary" OnClick="BtnSearchProgram_Click" />
        </div>

        <%-- Export Button --%>
        <div class="header-button-grp">
            <asp:Button ID="btnExport" runat="server" Text="Export"
                CssClass="btn btn-secondary" OnClick="BtnExport_Click" />
            <asp:Button ID="btnCreateProgram" runat="server" Text="+ Create Program"
                CssClass="btn btn-primary" OnClick="BtnCreateProgram_Click" />
        </div>
    </div>

    <%-- Program Gridview --%>
    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:GridView ID="gvCourses" runat="server" CssClass="course-table"
                AutoGenerateColumns="False"
                EmptyDataText="No programs found."
                AllowPaging="False"
                OnRowCommand="EditCoursePopUpForm">
                <Columns>

                    <%-- Checkbox column for export --%>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <input type="checkbox" id="checkAll" onclick="toggleAll(this)" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="checkRow" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="program_code"        HeaderText="Program Code" />
                    <asp:BoundField DataField="program_name"        HeaderText="Program Name" />
                    <asp:BoundField DataField="program_level"       HeaderText="Level" />
                    <asp:BoundField DataField="program_fee"         HeaderText="Fee (RM)" />
                    <asp:BoundField DataField="program_semester"    HeaderText="Total Semester" />
                    <asp:BoundField DataField="program_credits"     HeaderText="Total Credit Hours (CH)" />
                    <asp:BoundField DataField="lecturer_name"       HeaderText="Head of Program" />
                    <asp:BoundField DataField="hop_name"            HeaderText="Head of Program" />
                    <asp:BoundField DataField="student_count"       HeaderText="No. of Students" />

                    <%-- Status Badge --%>
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge badge-<%# Eval("program_status").ToString().ToLower() %>'>
                                <%# Eval("program_status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <%-- Action Column--%>
                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <div class="action-container">
                                <asp:LinkButton ID="btnEdit" runat="server"
                                    CssClass="btn btn-tertiary"
                                    ToolTip="Edit Program"
                                    CommandName="EditCourse"
                                    CommandArgument='<%# Eval("program_id") %>'>
                                    <i class="fa fa-pencil"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlStatusFilter" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="ddlLevelFilter"  EventName="SelectedIndexChanged" />
        </Triggers>
    </asp:UpdatePanel>

    <%-- Rows per page control--%>
    <div class="paging-container">
        <span>Rows per page:</span>
        <asp:TextBox ID="txtPageSize" runat="server" Text="10" CssClass="page-dropdown" Width="50px" MaxLength="4"
            onkeyup="if(event.keyCode===13) document.getElementById('<%= BtnApplyPageSize.ClientID %>').click();" />
        <asp:Button ID="BtnApplyPageSize" runat="server" OnClick="BtnApplyPageSize_Click" style="display:none;" />
        <asp:Label ID="TotalRows" runat="server" Text="of 0 rows"></asp:Label>
    </div>

    <%-- Edit Program Model (Pop-up) --%>
    <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel ID="popUpForm" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-form">
                    <h3>Edit Program</h3>
                    <asp:HiddenField ID="hdnEditProgramId" runat="server" />

                    <%-- Form Fields --%>
                    <div class="form-group">
                        <label>Program Code</label>
                        <asp:TextBox ID="txtEditCode" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Program Name</label>
                        <asp:TextBox ID="txtEditName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Level</label>
                        <asp:TextBox ID="txtEditLevel" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Fee (RM)</label>
                        <asp:TextBox ID="txtEditFee" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="form-group">
                        <label>Semester</label>
                        <asp:TextBox ID="txtEditSemester" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="form-group">
                        <label>Credit Hours</label>
                        <asp:TextBox ID="txtEditCreditHours" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="1">Active</asp:ListItem>
                            <asp:ListItem Value="0">Discontinued</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Program Coordinator (Lecturer)</label>
                        <asp:DropDownList ID="ddlEditLecturer" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Head of Program (Admin)</label>
                        <asp:DropDownList ID="ddlEditHOP" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>

                    <div style="margin-top:30px; display:flex; gap:12px; justify-content:center;">
                        <asp:Button ID="btnSaveUpdate" runat="server" Text="Update Program"
                            CssClass="btn btn-primary" OnClick="BtnSaveUpdate_Click" />
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel"
                            CssClass="btn btn-secondary" OnClick="BtnCancelEdit_Click" />
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

<script>
    // Select / deselect all checkboxes
    // @ts-ignore
    function toggleAll(checkAll) {
        var checkboxes = document.querySelectorAll("input[id*='checkRow']");
        // @ts-ignore
        checkboxes.forEach(function (cb) { cb.checked = checkAll.checked; });
    }
</script>
</div>
</asp:Content>
