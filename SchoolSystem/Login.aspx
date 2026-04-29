<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SchoolSystem.Login" %>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - School System</title>
    <style>
        * { box-sizing: border-box; }
        body, html { margin: 0; padding: 0; height: 100%; width: 100%; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        .gradient-bg { 
            width: 100%; 
            min-height: 100vh; 
            background: linear-gradient(to bottom right, #f7f1c1, #c8e6f5); 
            display: flex; 
            flex-direction: column; 
            background-attachment: fixed;
        }

        .top-nav { width: 100%; padding: 30px; }
        .nav-left { text-decoration: none; color: #555; font-weight: bold; font-size: 18px; margin-left: 20px; transition: color 0.2s; }
        .nav-left:hover { color: #000; }

        .page-content { flex: 1; display: flex; justify-content: center; align-items: center; padding: 60px 0; }
        
        .white-box { 
            background-color: #fff; 
            border-radius: 30px; 
            padding: 80px 60px; 
            width: 500px; /* Wider login box */
            box-shadow: 0 10px 30px rgba(0,0,0,0.1); 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            border: 1px solid rgba(0,0,0,0.05); 
        }

        .title-row h1 { font-size: 42px; font-weight: bold; margin: 0; margin-bottom: 50px; color: #333; }

        .form-group { width: 100%; margin-bottom: 30px; text-align: left; }
        .form-label { font-size: 14px; color: #666; margin-bottom: 10px; display: block; font-weight: bold; text-transform: uppercase; letter-spacing: 1px; }
        .form-input { 
            width: 100%; 
            padding: 15px; 
            border: 2px solid #eee; 
            background-color: #f9f9f9; 
            border-radius: 10px; 
            box-sizing: border-box; 
            font-size: 16px; 
            transition: border-color 0.2s;
        }
        .form-input:focus { border-color: #4a69bd; outline: none; background-color: #fff; }

        .login-btn { 
            width: 100%; /* Full width button for a stronger look */
            background-color: #4a69bd; 
            color: #fff; 
            border: none; 
            border-radius: 10px; 
            padding: 15px; 
            font-size: 18px; 
            cursor: pointer; 
            margin-top: 20px; 
            font-weight: bold; 
            box-shadow: 0 4px 15px rgba(74, 105, 189, 0.3);
            transition: background-color 0.2s;
        }
        .login-btn:hover { background-color: #3e58a2; }

        .error-label { color: #e74c3c; font-size: 14px; margin-top: 20px; text-align: center; display: block; font-weight: 500; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="gradient-bg">
            <div class="top-nav">
                <asp:HyperLink ID="lnkBack" runat="server" CssClass="nav-left" NavigateUrl="~/RoleSelect.aspx"> < Back to Roles</asp:HyperLink>
            </div>

            <div class="page-content">
                <div class="white-box">
                    <div class="title-row">
                        <h1>Log In</h1>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" placeholder="e.g. name@school.com"></asp:TextBox>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input" TextMode="Password" placeholder="••••••••"></asp:TextBox>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" CssClass="error-label" Visible="false"></asp:Label>
                    
                    <asp:Button ID="btnLogin" runat="server" Text="Log In" CssClass="login-btn" OnClick="btnLogin_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>