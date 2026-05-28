<%@ Page Title="Create Courses" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="CreateCourses.aspx.cs" Inherits="SchoolSystem.CreateCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="create-course-page">
        <div class="form-container">
            
            <div class="header">
                <h1>Create New Course</h1>
            </div>

            <div class="form-body">
                <div class="form-group" style="margin-bottom: 25px;">
                    <label>Course Cover Image (Optional)</label>
                    <div class="image-upload-container">
                        <img id="imgPreview" src="data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=" alt="Preview" class="img-preview" />
                        <div class="upload-controls">
                            <label for="fuCourseImage" class="btn btn-secondary btn-sm"><i class="fas fa-upload me-2"></i> Choose Image</label>
    
                            <asp:FileUpload ID="fuCourseImage" runat="server" ClientIDMode="Static" CssClass="hidden-upload-absolute" accept=".png,.jpg,.jpeg" onchange="previewImage(this);" />
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Course Code</label>
                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" placeholder="e.g. CS101" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCode" ErrorMessage="Code is required" ForeColor="Red" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label>Course Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. C# Development" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" ForeColor="Red" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label>Credit Hours</label>
                    <asp:TextBox ID="txtCreditHours" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 3" />
                </div>

                <div class="form-group">
                    <label>Course Fee (RM)</label>
                    <asp:TextBox ID="txtCourseFee" runat="server" CssClass="form-control" TextMode="Number" Step="0.01" placeholder="e.g. 1500.00" />
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                        <asp:ListItem Value="Open">Open</asp:ListItem>
                        <asp:ListItem Value="Ongoing">Ongoing</asp:ListItem>
                        <asp:ListItem Value="Closed">Closed</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlStatus" ErrorMessage="Status is required" ForeColor="Red" Display="Dynamic" />
                </div>

                <div class="form-group">
                    <label>Lecturer</label>
                    <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-control">
                        <asp:ListItem Text="-- Select Lecturer --" Value="0"></asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLecturer" InitialValue="0" ErrorMessage="Please select a lecturer" ForeColor="Red" Display="Dynamic" />
                </div>

                <div class="form-group" style="margin-bottom: 0;">
                    <label>Program</label>
                    <asp:DropDownList ID="ddlProgram" runat="server" CssClass="form-control">
                        <asp:ListItem Text="-- Select Program --" Value="0"></asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvProgram" runat="server" ControlToValidate="ddlProgram" InitialValue="0" ErrorMessage="Please select a program" ForeColor="Red" Display="Dynamic" />
                </div>
            </div>

            <div class="form-footer">
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="BtnCancel_Click" CausesValidation="false" />
                <asp:Button ID="btnSubmit" runat="server" Text="Add Course" CssClass="btn btn-primary" OnClick="BtnSubmit_Click" />
            </div>

        </div>
    </div>

    <script>
        // @ts-nocheck
        function previewImage(input) {
            var preview = document.getElementById('imgPreview');
            var fileNameLabel = document.getElementById('fileName');

            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                }
                reader.readAsDataURL(input.files[0]);
                fileNameLabel.textContent = input.files[0].name;
            } else {
                preview.src = "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=";
                fileNameLabel.textContent = "No file chosen";
            }
        }
    </script>
</asp:Content>