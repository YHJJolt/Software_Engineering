<%@ Page Title="Create Courses" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="CreateCourses.aspx.cs" Inherits="SchoolSystem.CreateCourses" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* ====================== FORM STYLES ====================== */
        .header{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .form-container { 
            background: #E0E0E0; 
            padding: 30px; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
            max-width: 800px; 
            margin: 20px auto; 
        }
        .form-row { 
            display: flex; 
            gap: 20px; 
            margin-bottom: 20px; 
        }
        .form-group { 
            flex: 1; 
            display: flex; 
            flex-direction: column; 
        }
        .form-group label { 
            font-size: 14px; 
            color: #555; 
            margin-bottom: 8px; 
            font-weight: 500; 
        }
        .form-control { 
            padding: 10px; 
            border: 1px solid #ddd; 
            border-radius: 6px; 
            font-size: 14px; 
        }

        /* Button Style */
        .btn { 
            padding: 9px 18px; 
            border: none; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 14px; 
            margin-right: 10px;
        }
        .btn-primary   { background: #C5A059; color: white; }
        .btn-primary:hover { background: #CCB68B; }
        .btn-secondary { background: #7D8AFF; color: white; }
        .btn-secondary:hover { background: #B4B9F0; }
    </style>

    <div class="header">
        <h1>Create New Course</h1>
    </div>

    <div class="form-container">
        <div class="form-row">
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
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Credit Hours</label>
                <asp:TextBox ID="txtCreditHours" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 3" />
            </div>

            <div class="form-group">
                <label>Course Fee (RM)</label>
                <asp:TextBox ID="txtCourseFee" runat="server" CssClass="form-control" TextMode="Number" Step="0.01" placeholder="e.g. 1500.00" />
            </div>
        </div>

        <div class="form-row">
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
            </div>
        </div>

        <div class="form-group" style="margin-bottom: 20px;">
            <label>Lecturer</label>
            <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-control">
                <asp:ListItem Text="-- Select Lecturer --" Value="0"></asp:ListItem>
            </asp:DropDownList>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLecturer"
                InitialValue="0" ErrorMessage="Please select a lecturer" ForeColor="Red" Display="Dynamic" />
        </div>

        <div class="form-group" style="margin-bottom: 20px;">
            <label>Program</label>
            <asp:DropDownList ID="ddlProgram" runat="server" CssClass="form-control">
                <asp:ListItem Text="-- Select Program --" Value="0"></asp:ListItem>
            </asp:DropDownList>
            <asp:RequiredFieldValidator ID="rfvProgram" runat="server" ControlToValidate="ddlProgram" 
                InitialValue="0" ErrorMessage="Please select a program" ForeColor="Red" Display="Dynamic" />
        </div>

        <asp:Button ID="btnSubmit" runat="server" Text="Add Course" CssClass="btn btn-primary" OnClick="BtnSubmit_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="BtnCancel_Click" CausesValidation="false" />
    </div>
</asp:Content>