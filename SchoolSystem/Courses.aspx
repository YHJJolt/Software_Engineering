<%@ Page Title="Courses" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="SchoolSystem.Courses" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* General styles */
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .search-box { padding: 8px 14px; width: 250px; border: 1px solid #e1e5eb; border-radius: 8px; font-size: 14px; transition: 0.2s; }
        .search-box:focus { border-color: #4A90E2; outline: none; box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1); }
        .action-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; width: 100%; }
        .search-group, .header-button-grp { display: flex; gap: 10px; align-items: center; }

        /* Button Style */
        .btn { padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 500; text-decoration: none; transition: all 0.2s; }
        .btn-primary   { background: #C5A059; color: white; }
        .btn-primary:hover { background: #b38f4a; transform: translateY(-1px); box-shadow: 0 4px 10px rgba(197, 160, 89, 0.3); }
        .btn-secondary { background: #f1f3f5; color: #495057; border: 1px solid #dee2e6; }
        .btn-secondary:hover { background: #e9ecef; color: #212529; }

        /* Icon Buttons */
        .btn-icon {
            padding: 8px 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            color: white;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            transition: 0.2s;
        }
        .btn-edit { background-color: #4A90E2; } 
        .btn-edit:hover { background-color: #357ABD; color: white; box-shadow: 0 2px 8px rgba(74, 144, 226, 0.3); }
        .btn-delete { background-color: #E74C3C; } 
        .btn-delete:hover { background-color: #C0392B; color: white; box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3); }

        /* =========================================
           CLASSIC DARK HEADER TABLE
           ========================================= */
        .course-table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .course-table th { background: #2c3e50; color: white; padding: 14px 16px; text-align: left; font-size: 14px; }
        .course-table td { padding: 13px 16px; border-bottom: 1px solid #f0f0f0; font-size: 14px; color: #444; }
        .course-table tr:last-child td { border-bottom: none; }
        .course-table tr:hover td { background: #f8fafc; }
        .action-container { display: flex; gap: 8px; align-items: center; }

        /* =========================================
           MODERN EDIT MODAL 
           ========================================= */
        .modal-overlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(15, 23, 42, 0.4); 
            backdrop-filter: blur(4px); 
            display: flex; justify-content: center; align-items: center; 
            z-index: 1000; 
            opacity: 0;
            animation: fadeIn 0.2s forwards ease-out;
        }
        
        .modal-form { 
            background: #ffffff; 
            border-radius: 16px; 
            width: 450px; 
            box-shadow: 0 20px 40px rgba(0,0,0,0.15); 
            overflow: hidden; 
            transform: translateY(20px);
            animation: slideUp 0.3s forwards ease-out;
        }

        .modal-header { padding: 20px 30px; background: #ffffff; border-bottom: 1px solid #f1f3f5; }
        .modal-header h3 { margin: 0; color: #1e293b; font-size: 20px; font-weight: 600; }
        .modal-body { padding: 25px 30px; background: #ffffff; }
        .modal-footer { padding: 20px 30px; background: #f8fafc; border-top: 1px solid #f1f3f5; display: flex; justify-content: flex-end; gap: 12px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; color: #64748b; margin-bottom: 8px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px; }
        .form-control { 
            width: 100%; 
            padding: 12px 14px; 
            border: 1px solid #cbd5e1; 
            border-radius: 8px; 
            box-sizing: border-box; 
            font-size: 15px; 
            color: #334155;
            background: #f8fafc;
            transition: all 0.2s; 
        }
        .form-control:focus { background: #ffffff; border-color: #C5A059; box-shadow: 0 0 0 4px rgba(197, 160, 89, 0.15); outline: none; }

        @keyframes fadeIn { to { opacity: 1; } }
        @keyframes slideUp { to { transform: translateY(0); } }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="header">
        <h1>Manage Courses</h1>
        <div class="header-button-grp">
            <a href="CreateCourses.aspx" class="btn btn-primary">+ New Course</a>
        </div>
    </div>

    <asp:UpdatePanel ID="upGridView" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="action-bar">
                <div class="search-group">
                    <asp:DropDownList ID="ddlProgramFilter" runat="server" CssClass="search-box" style="width: 220px;" AutoPostBack="true" OnSelectedIndexChanged="ddlProgramFilter_SelectedIndexChanged">
                        <asp:ListItem Text="All Programs" Value=""></asp:ListItem>
                    </asp:DropDownList>

                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-box" placeholder="Search courses..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="BtnApplyPageSize_Click" />
                </div>
            </div>

            <asp:HiddenField ID="hdnCourseId" runat="server" />

            <asp:GridView ID="gvCourses" runat="server" CssClass="course-table"
                AutoGenerateColumns="False" EmptyDataText="No courses found." OnRowCommand="gvCourses_RowCommand" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="course_code" HeaderText="Course Code" />
                    <asp:BoundField DataField="course_name" HeaderText="Course Name" />
                    <asp:BoundField DataField="program_name" HeaderText="Program" />
                    <asp:BoundField DataField="lecturer_name" HeaderText="Lecturer" />
                    <asp:BoundField DataField="course_fee" HeaderText="Fee (RM)" DataFormatString="{0:N2}" />

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>
                            <div class="action-container">
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-icon btn-edit" ToolTip="Edit Course"
                                    CommandName="EditCourse" CommandArgument='<%# Eval("course_id") %>'>
                                    <i class="fas fa-pencil-alt"></i>
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn-icon btn-delete" ToolTip="Delete Course"
                                    OnClientClick='<%# "return confirmDelete(this, " + Eval("course_id") + ");" %>'
                                    OnClick="BtnDeleteCourse_Click">
                                    <i class="fas fa-trash-alt"></i>
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <asp:Panel ID="pnlEditModal" runat="server" Visible="false" CssClass="modal-overlay">
                <div class="modal-form">
                    
                    <div class="modal-header">
                        <h3>Edit Course Details</h3>
                    </div>

                    <div class="modal-body">
                        <asp:HiddenField ID="hdnEditCourseId" runat="server" />
                        
                        <div class="form-group">
                            <label>Course Code</label>
                            <asp:TextBox ID="txtEditCode" runat="server" CssClass="form-control" />
                        </div>
                        <div class="form-group">
                            <label>Course Name</label>
                            <asp:TextBox ID="txtEditName" runat="server" CssClass="form-control" />
                        </div>
                        <div class="form-group" style="margin-bottom: 0;">
                            <label>Course Fee (RM)</label>
                            <asp:TextBox ID="txtEditFee" runat="server" CssClass="form-control" TextMode="Number" Step="0.01" />
                        </div>
                    </div>

                    <div class="modal-footer">
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="BtnCancelEdit_Click" CausesValidation="false" />
                        <asp:Button ID="btnSaveUpdate" runat="server" Text="Save Changes" CssClass="btn btn-primary" OnClick="BtnSaveUpdate_Click" />
                    </div>

                </div>
            </asp:Panel>

        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlProgramFilter" EventName="SelectedIndexChanged" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
        function confirmDelete(btn, courseId) {
            Swal.fire({
                title: 'Delete Course?',
                text: 'This action will remove the course and all connected enrollments. It cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#E74C3C',
                cancelButtonColor: '#94a3b8',
                confirmButtonText: 'Yes, I\'m sure!',
                customClass: {
                    confirmButton: 'btn btn-delete',
                    cancelButton: 'btn btn-secondary'
                }
            }).then(function (result) {
                if (result.isConfirmed) {
                    document.getElementById('<%= hdnCourseId.ClientID %>').value = courseId;

                    // FIX: Extract the hidden postback command from the LinkButton's href
                    var href = btn.getAttribute('href');
                    if (href && href.startsWith('javascript:')) {
                        eval(href.replace('javascript:', ''));
                    } else if (typeof __doPostBack === 'function') {
                        // Safe fallback
                        __doPostBack(btn.id.replace(/_/g, '$'), '');
                    }
                }
            });
            return false;
        }
    </script>
</asp:Content>