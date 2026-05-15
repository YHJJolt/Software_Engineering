<%@ Page Title="Program Management" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Program.aspx.cs" Inherits="SchoolSystem.Program" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <style>
        /* General styles */
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
        }

        .search-group, .button-group {
            display: flex;
            gap: 10px;
        }

        .header-button-grp {
            display: flex;
            gap: 10px;
        }

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

        /* Buttons */
        .btn {
            padding: 9px 18px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-primary   { background: #C5A059; color: white; }
        .btn-primary:hover   { background: #CCB68B; }
        .btn-secondary { background: #7D8AFF; color: white; }
        .btn-secondary:hover { background: #B4B9F0; }
        .btn-tertiary  { background: #90B3D1; color: white; }
        .btn-tertiary:hover  { background: #C2D6F0; }
        .btn-warning   { background: #CC4343; color: white; }
        .btn-warning:hover   { background: #ff5c5c; }

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
        }
        .course-table tr:last-child td { border-bottom: none; }
        .course-table tr:hover td     { background: #f8fafc; }

        /* Status badges */
        .badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .badge-active   { background: #d4edda; color: #155724; }
        .badge-discontinued { background: #f8d7da; color: #721c24; }

        /* Action buttons */
        .action-container {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        /* Edit Program */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.65);
            display: flex; justify-content: center; align-items: center;
            z-index: 1000;
        }
        .modal-form {
            background: #fff;
            padding: 35px 40px;
            border-radius: 12px;
            width: 500px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            animation: fadeInModal 0.3s ease;
        }
        @keyframes fadeInModal {
            from { opacity: 0; transform: scale(0.95); }
            to   { opacity: 1; transform: scale(1); }
        }
        .modal-form h3 {
            margin: 0 0 25px 0;
            color: #2c3e50;
            font-size: 24px;
            font-weight: 600;
            text-align: center;
        }
        .form-group { margin-bottom: 22px; }
        .form-group label {
            display: block;
            font-size: 14px;
            color: #555;
            margin-bottom: 8px;
            font-weight: 500;
        }
        .form-control {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.3s;
            box-sizing: border-box;
        }
        .form-control:focus {
            border-color: #C5A059;
            box-shadow: 0 0 0 3px rgba(197,160,89,0.15);
            outline: none;
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
    <%-- Header --%>
    <div class="header">
        <h1>Program Management</h1>
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

</asp:Content>
