<%@ Page Title="Courses" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="SchoolSystem.Courses" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        /* General styles*/
        .header{
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
            font-size: 14px;}

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

        /* Paging Scrolling Up & Down */
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
            border-radius: 20px; /* Matches the pill-shape in your image */
            border: 1px solid #ccc;
            outline: none;
        }

        /* Button Style */
        .btn { 
            padding: 9px 18px; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 14px; 
        }
        .btn-primary { background: #C5A059; color: white; }
        .btn-primary:hover { background: #CCB68B; }
        .btn-secondary { background: #7D8AFF; color: white; }
        .btn-secondary:hover { background: #B4B9F0; }
        .btn-tertiary { background: #90B3D1; color: white; }
        .btn-tertiary:hover { background: #C2D6F0; }
        .btn-warning{ background: #CC4343; color: white; }
        .btn-warning:hover{ background: #ff5c5c; }

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
        .course-table tr:last-child td { 
            border-bottom: none; 

        }
        .course-table tr:hover td { 
            background: #f8fafc; 

        }

        /* Status badges */
        .badge { 
            padding: 4px 12px; 
            border-radius: 20px; 
            font-size: 12px; 
            font-weight: 600; 

        }
        .badge-open    { background: #d4edda; color: #155724; }
        .badge-ongoing { background: #fff3cd; color: #856404; }
        .badge-closed  { background: #f8d7da; color: #721c24; }

        /* Action Buttons Container */
        .action-container{
            display: flex;
            gap: 8px; 
            align-items: center;
        }

        /* ====================== MODAL (Edit Course) ====================== */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.65); 
            display: flex; justify-content: center; align-items: center; 
            z-index: 1000;
        }
        .modal-form {
            background: #fff; 
            padding: 35px 40px; 
            border-radius: 12px; 
            width: 450px;
            max-height: 75vh;       
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            animation: fadeInModal 0.3s ease;
        }
        @keyframes fadeInModal {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }

        .modal-form h3 {
            margin: 0 0 25px 0;
            color: #2c3e50;
            font-size: 24px;
            font-weight: 600;
            text-align: center;
        }

        .form-group {
            margin-bottom: 22px;
        }
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
        }
        .form-control:focus {
            border-color: #C5A059;
            box-shadow: 0 0 0 3px rgba(197, 160, 89, 0.15);
            outline: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server"> 

    <%-- Header --%>
    <div class="header">
        <h1>Course Management</h1>
    </div>

    <div class="action-bar">
        <div class="search-group">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" 
                placeholder="Search ..." 
                onkeyup="if(event.keyCode === 13) document.getElementById('<%= btnSearch.ClientID %>').click();">
            </asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" Text="Search" 
                CssClass="btn btn-primary" OnClick="BtnSearchCourse_Click" />
        </div>

        <div class="header-button-grp">
            <asp:Button ID="btnExport" runat="server" Text="Export" 
                CssClass="btn btn-secondary" OnClick="BtnExport_Click" />
            <asp:Button ID="btnCreateCourse" runat="server" Text="+ Create Course" 
                CssClass="btn btn-primary" OnClick="BtnCreateCourse_Click" />
        </div>
</div>

    <%-- Course Table --%>
    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <input type="hidden" id="hdnCourseId" name="hdnCourseId" />
            <asp:GridView ID="gvCourses" runat="server" CssClass="course-table" AutoGenerateColumns="False" 
                          EmptyDataText="No courses found." AllowPaging="False"
                          OnRowCommand="EditCoursePopUpForm">
                <Columns>
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <input type="checkbox" id="checkAll" onclick="toggleAll(this)" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="checkRow" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField DataField="course_code" HeaderText="Course Code" />
                    <asp:BoundField DataField="course_name" HeaderText="Course Name" />
                    <asp:BoundField DataField="lecturer_name" HeaderText="Lecturer Name" />
                    <asp:BoundField DataField="Lecturer_email" HeaderText="Lecturer Email" />
                    <asp:BoundField DataField="program_name" HeaderText="Program Name" />
                    <asp:BoundField DataField="course_fee" HeaderText="Course Fee" />
                    <asp:BoundField DataField="credit_hours" HeaderText="Credit Hours" />
                    <asp:BoundField DataField="student_count" HeaderText="No. of Students" />
            
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate>
                            <span class='badge badge-<%# Eval("course_status").ToString().ToLower() %>'>
                                <%# Eval("course_status") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <div class="action-container">
                        
                                <asp:LinkButton ID="btnEdit" runat="server"
                                CssClass="btn btn-tertiary"
                                ToolTip="Edit Course"
                                CommandName="EditCourse" CommandArgument='<%# Eval("course_id") %>'>
                                    <i class="fa fa-pencil"></i> 
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnDelete" runat="server" 
                                    CssClass="btn btn-warning"
                                    ToolTip="Delete Course"
                                    OnClick="BtnDeleteCourse_Click"
                                    OnClientClick='<%# "return confirmDelete(this, \"" + Eval("course_id") + "\");" %>'>
                                    <i class="fa fa-trash"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
    </asp:UpdatePanel>
        
     <%-- Selection no. of rows per page --%>
    <div class="paging-container">
        <span>Rows per page:</span>
            <asp:TextBox ID="txtPageSize" runat="server" Text="10" CssClass="page-dropdown" Width="50px" MaxLength="4" 
                onkeyup="if(event.keyCode === 13) document.getElementById('<%= BtnApplyPageSize.ClientID %>').click();" />
        <asp:Button ID="BtnApplyPageSize" runat="server" OnClick="BtnApplyPageSize_Click" style="display:none;" />
        <asp:Label ID="TotalRows" runat="server" Text="of 0 rows"></asp:Label>
    </div>

    <%-- Pop-Up Form --%>
    <asp:UpdatePanel ID="upModal" runat="server" UpdateMode="Conditional"> 
        <ContentTemplate>
            <%-- Fields --%>
            <asp:Panel ID="popUpForm" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-form">
                    <h3>Edit Course</h3>
                    <asp:HiddenField ID="hdnEditCourseId" runat="server" />
                    
                    <div class="form-group">
                        <label>Course Code</label>
                        <asp:TextBox ID="txtEditCode" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Course Name</label>
                        <asp:TextBox ID="txtEditName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Course Fee</label>
                        <asp:TextBox ID="txtEditFee" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label>Credit Hours</label>
                        <asp:TextBox ID="txtEditCredits" runat="server" CssClass="form-control" TextMode="Number" />
                    </div>
                    <div class="form-group">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlEditStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Open">Open</asp:ListItem>
                            <asp:ListItem Value="Ongoing">Ongoing</asp:ListItem>
                            <asp:ListItem Value="Closed">Closed</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Lecturer</label>
                        <asp:DropDownList ID="ddlEditLecturer" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Program</label>
                        <asp:DropDownList ID="ddlEditProgram" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>

                    <div style="margin-top: 30px; display: flex; gap: 12px; justify-content: center;">
                        <asp:Button ID="btnSaveUpdate" runat="server" Text="Update Course" 
                            CssClass="btn btn-primary" OnClick="BtnSaveUpdate_Click" />
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" 
                            CssClass="btn btn-secondary" OnClick="BtnCancelEdit_Click" />
                    </div>
                </div>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <script>
    <%-- Selection of rows for export --%>
    function toggleAll(checkAll) {
        var checkboxes = document.querySelectorAll("input[id*='checkRow']");
        checkboxes.forEach(function (cb) {
            cb.checked = checkAll.checked;
        });
    }

    <%-- Confirmation dialog for deleting a course --%>
        function confirmDelete(btn, courseId) {
            Swal.fire({
                title: 'Delete Course?',
                text: 'This action cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#CC4343',
                cancelButtonColor: '#aaa',
                confirmButtonText: 'Yes, I\'m sure!'
            }).then(function (result) {
                if (result.isConfirmed) {
                    document.getElementById('hdnCourseId').value = courseId;
                    btn.removeAttribute('onclick');
                    btn.click();
                }
            });
            return false;
        }
    </script>
</asp:Content>