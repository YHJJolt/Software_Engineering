<%@ Page Title="Courses" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="Courses.aspx.cs" Inherits="SchoolSystem.Courses" %>

<asp:Content ID="Styling" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
    
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="course-mgmt-page">
    <div class="header">
        <h1><i class="fas fa-book"></i>Manage Courses</h1>
        <div class="header-button-grp">
            <a runat="server" href="~/Admin/CreateCourses.aspx" class="btn btn-primary">+ New Course</a>
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
                        
                    <div class="form-group" style="margin-bottom: 25px;">
                    <label>Course Cover Image</label>
                    <div class="image-upload-container">
                        <asp:Image ID="imgEditPreview" runat="server" ClientIDMode="Static" CssClass="img-preview" ImageUrl="data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=" />
        
                        <div class="upload-controls">
                            <label for="fuEditCourseImage" class="btn btn-secondary btn-sm"><i class="fas fa-upload me-2"></i> Change Image</label>
    
                            <asp:FileUpload ID="fuEditCourseImage" runat="server" ClientIDMode="Static" CssClass="hidden-upload-absolute" accept=".png,.jpg,.jpeg" onchange="previewEditImage(this);" />
                        </div>
                    </div>
                </div>

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
            
            <asp:PostBackTrigger ControlID="btnSaveUpdate" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
    // @ts-nocheck
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

        // Live preview script for the Edit Modal
        function previewEditImage(input) {
            var preview = document.getElementById('imgEditPreview');

            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
    </div>
</asp:Content>