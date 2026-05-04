<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SchoolSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - School System</title>
    <style>
        :root { 
            --cream-base: #fdfaf6;    /* Main Light Base */
            --navy-accent: #121420;   /* Primary Text/Button */
            --antique-gold: #c5a059;  /* Structural Highlights */
            --soft-glow: #7d8aff;     /* Input Focus Glow */
        }

        * { box-sizing: border-box; }
        body, html { 
            margin: 0; padding: 0; height: 100%; width: 100%; 
            font-family: 'Inter', 'Segoe UI', sans-serif; 
            background-color: var(--cream-base); 
        }
        
        .page-wrapper { 
            width: 100%; 
            min-height: 100vh; 
            display: flex; 
            flex-direction: column; 
        }

        .top-navigation { width: 100%; padding: 40px; }
        .back-link { 
            text-decoration: none; 
            color: var(--navy-accent); 
            font-weight: 800; 
            font-size: 14px; 
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .back-link:hover { color: var(--antique-gold); }

        .content-area { flex: 1; display: flex; justify-content: center; align-items: center; padding-bottom: 100px; }
        
        /* The "Keycap" Login Box */
        .login-card { 
            background-color: #ffffff; 
            border-radius: 20px; 
            padding: 60px 50px; 
            width: 480px; 
            box-shadow: 0 10px 30px rgba(18, 20, 32, 0.05); 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            border: 1px solid rgba(18, 20, 32, 0.03); 
            border-top: 5px solid var(--antique-gold); /* Brass Structural Accent */
        }

        .login-header h1 { 
            font-size: 36px; 
            font-weight: 800; 
            margin: 0; 
            margin-bottom: 40px; 
            color: var(--navy-accent); 
            text-transform: uppercase;
            letter-spacing: 2px;
            border-bottom: 2px solid var(--antique-gold);
            padding-bottom: 10px;
        }

        .input-group { width: 100%; margin-bottom: 25px; }
        .field-label { 
            font-size: 11px; 
            color: var(--navy-accent); 
            margin-bottom: 10px; 
            display: block; 
            font-weight: 800; 
            text-transform: uppercase; 
            letter-spacing: 1px; 
            opacity: 0.6;
        }
        .text-field { 
            width: 100%; 
            padding: 16px; 
            border: 2px solid #f0f0f0; 
            background-color: var(--cream-base); 
            border-radius: 10px; 
            font-size: 15px; 
            color: var(--navy-accent);
            transition: 0.3s;
        }
        .text-field:focus { 
            border-color: var(--soft-glow); 
            outline: none; 
            background-color: #fff; 
            box-shadow: 0 0 10px rgba(125, 138, 255, 0.15);
        }

        .action-button { 
            width: 100%; 
            background-color: var(--navy-accent); 
            color: var(--cream-base); 
            border: 1px solid var(--antique-gold); 
            border-radius: 10px; 
            padding: 16px; 
            font-size: 16px; 
            cursor: pointer; 
            margin-top: 20px; 
            font-weight: 800; 
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: 0.3s;
        }
        .action-button:hover { 
            background-color: var(--antique-gold); 
            color: var(--navy-accent);
            box-shadow: 0 4px 15px rgba(197, 160, 89, 0.2);
        }

        .msg-label { 
            font-size: 13px; 
            margin-top: 20px; 
            text-align: center; 
            display: block; 
            font-weight: 700; 
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
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
    </form>
</body>
</html>