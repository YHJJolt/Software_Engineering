<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SchoolSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - School System</title>
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />

</head>
<body>
    <form id="form1" runat="server">
        <div class="login-page">
        <div class="page-wrapper">
            <div class="top-navigation">
                <asp:HyperLink ID="lnkBack" runat="server" CssClass="back-link" NavigateUrl="~/RoleSelect.aspx">
                    <i class="fas fa-chevron-left"></i> Back to Roles
                </asp:HyperLink>
            </div>

            <div class="content-area">
                <div class="login-card">
                    <div class="login-header">
                        <h1>Log In</h1>
                    </div>
                    
                    <div class="input-group">
                        <label class="field-label">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="text-field" placeholder="name@school.com"></asp:TextBox>
                    </div>
                    
                    <div class="input-group">
                        <label class="field-label">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="text-field" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" CssClass="msg-label" Visible="false"></asp:Label>
                    
                    <asp:Button ID="btnLogin" runat="server" Text="Access System" CssClass="action-button" OnClick="btnLogin_Click" />
                </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>