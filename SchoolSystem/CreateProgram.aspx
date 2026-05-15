<%@ Page Title="Create Programs" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="CreateProgram.aspx.cs" Inherits="SchoolSystem.CreatePrograms" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        /* Form styles */
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
        
        .header {
            margin-bottom: 25px;
            text-align: center;
        }
    </style>

    <div class="header">
        <h1>Create New Program</h1>
    </div>

    <div class="form-container">
        <div class="form-row">
            <%-- Program Code --%>
            <div class="form-group">
                <label>Program Code</label>
                <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" placeholder="e.g. BSE" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCode" ErrorMessage="Code is required" ForeColor="Red" Display="Dynamic" />
            </div>

            <%-- Program Name --%>
            <div class="form-group">
                <label>Program Name</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="e.g. Software Engineering" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" ForeColor="Red" Display="Dynamic" />
            </div>
        </div>

        <div class="form-row">
            <%-- Level --%>
            <div class="form-group">
                <label>Level</label>
                <asp:DropDownList ID="ddlLevel" runat="server" CssClass="form-control">
                    <asp:ListItem Value="">-- Select Level --</asp:ListItem>
                    <asp:ListItem Value="Diploma">Diploma</asp:ListItem>
                    <asp:ListItem Value="Degree">Degree</asp:ListItem>
                    <asp:ListItem Value="Master">Master</asp:ListItem>
                </asp:DropDownList>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLevel" ErrorMessage="Level is required" ForeColor="Red" Display="Dynamic" />
            </div>

            <%-- Fee --%>
            <div class="form-group">
                <label>Total Fee (RM)</label>
                <asp:TextBox ID="txtFee" runat="server" CssClass="form-control" TextMode="Number" Step="0.01" placeholder="e.g. 86000.00" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtFee" ErrorMessage="Fee is required" ForeColor="Red" Display="Dynamic" />
            </div>
        </div>

        <div class="form-row">
            <%-- Semesters --%>
            <div class="form-group">
                <label>Total Semesters</label>
                <asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 6" />
            </div>

            <%-- Credits --%>
            <div class="form-group">
                <label>Total Credits</label>
                <asp:TextBox ID="txtCredits" runat="server" CssClass="form-control" TextMode="Number" placeholder="e.g. 120" />
            </div>
        </div>

        <%-- Dropdown for Coordinator --%>
        <div class="form-group" style="margin-bottom: 20px;">
            <label>Program Coordinator</label>
            <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-control"></asp:DropDownList>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlLecturer" InitialValue="0" ErrorMessage="Please select a coordinator" ForeColor="Red" Display="Dynamic" />
        </div>

        <%-- Dropdown for HOP --%>
        <div class="form-group" style="margin-bottom: 20px;">
            <label>Head of Program</label>
            <asp:DropDownList ID="ddlAdmin" runat="server" CssClass="form-control"></asp:DropDownList>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlAdmin" InitialValue="0" ErrorMessage="Please select a Head of Program" ForeColor="Red" Display="Dynamic" />
        </div>

        <%-- Status dropdown --%>
        <div class="form-group" style="margin-bottom: 20px;">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                <asp:ListItem Value="1">Active</asp:ListItem>
                <asp:ListItem Value="0">Discontinued</asp:ListItem>
            </asp:DropDownList>
        </div>

        <%-- Action Buttons --%>
        <div style="margin-top: 25px; text-align: right;">
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary" OnClick="BtnCancel_Click" CausesValidation="false" />
            <asp:Button ID="btnSubmit" runat="server" Text="Add Program" CssClass="btn btn-primary" OnClick="BtnSubmit_Click" />
        </div>
    </div>
</asp:Content>