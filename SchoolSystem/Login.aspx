<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SchoolSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - School System</title>
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" />
    <style>
        .pw-wrap { position: relative; }
        .pw-wrap .text-field { padding-right: 42px; }
        .pw-toggle { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #888; font-size: 15px; }
        .pw-toggle:hover { color: var(--navy-accent); }
    </style>
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
                        <div class="pw-wrap">
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="text-field" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                            <i class="fas fa-eye pw-toggle" onclick="togglePw(this)"></i>
                        </div>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" CssClass="msg-label" Visible="false"></asp:Label>
                    
                    <asp:Button ID="btnLogin" runat="server" Text="Access System" CssClass="action-button" OnClick="btnLogin_Click" />
                </div>
                </div>
            </div>
        </div>
    </form>
    <script>
        function togglePw(icon) {
            var input = icon.previousElementSibling;
            if (!input) return;
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>
</body>
</html>