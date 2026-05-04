<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleSelect.aspx.cs" Inherits="SchoolSystem.RoleSelect" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Role - School System</title>
    <style>
        :root { 
            --cream-base: #fdfaf6;    /* Main Light Base */
            --navy-accent: #121420;   /* Text and Structure */
            --antique-gold: #c5a059;  /* Highlights */
            --soft-glow: #7d8aff;     /* Backlight Accent */
        }

        * { box-sizing: border-box; }
        body, html { 
            margin: 0; padding: 0; height: 100%; width: 100%; 
            font-family: 'Inter', 'Segoe UI', sans-serif; 
            background-color: var(--cream-base); 
        }
        
        .container-bg { 
            width: 100%; 
            min-height: 100vh; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            padding: 40px;
        }

        .role-card { 
            background-color: #ffffff; 
            border-radius: 20px; 
            padding: 60px; 
            width: 100%;
            max-width: 900px;
            box-shadow: 0 10px 30px rgba(18, 20, 32, 0.05); 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            border: 1px solid rgba(18, 20, 32, 0.03);
            border-top: 5px solid var(--antique-gold); /* Brass/Gold Structural Accent */
        }

        .header-row { 
            display: flex; 
            align-items: center; 
            gap: 20px; 
            margin-bottom: 60px; 
            border-bottom: 2px solid var(--antique-gold);
            padding-bottom: 15px;
        }
        .header-row h1 { 
            font-size: 42px; 
            font-weight: 800; 
            margin: 0; 
            color: var(--navy-accent); 
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .user-symbol { 
            width: 50px; height: 50px; 
            border-radius: 12px; 
            border: 3px solid var(--antique-gold); 
            display: flex; justify-content: center; align-items: center; 
            color: var(--navy-accent); font-size: 24px; 
            background: var(--cream-base);
        }

        .roles-flex { 
            display: flex; 
            gap: 60px; 
            justify-content: center; 
            width: 100%; 
        }
        
        .role-option { 
            background: none; 
            border: none; 
            padding: 20px; 
            cursor: pointer; 
            text-decoration: none; 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            transition: all 0.3s ease; 
            border-radius: 15px;
        }
        .role-option:hover { 
            background: rgba(125, 138, 255, 0.05); 
            transform: translateY(-8px); 
        }

        .role-image { 
            width: 160px; height: 160px; 
            border-radius: 50%; 
            object-fit: contain; 
            margin-bottom: 20px; 
            background: var(--cream-base);
            border: 4px solid #fff;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        
        .role-text { 
            font-size: 22px; 
            font-weight: 800; 
            text-align: center; 
            color: var(--navy-accent); 
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Active highlight for the specific icon inside the selected role */
        .role-option:hover .role-text { color: var(--soft-glow); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-bg">
            <div class="role-card">
                <div class="header-row">
                    <h1>Select Role</h1>
                    <div class="user-symbol">👤</div> 
                </div>
                <div class="roles-flex">
                    <asp:LinkButton ID="btnHOP" runat="server" OnClick="btnRole_Click" CommandArgument="HOP" CssClass="role-option">
                        <asp:Image ID="imgHop" runat="server" ImageUrl="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjoSbYswqoeNVkzReFBz1Lehvj1wS7CbD6mw&s" CssClass="role-image" />
                        <div class="role-text">HOP</div>
                    </asp:LinkButton>
                    
                    <asp:LinkButton ID="btnLecturer" runat="server" OnClick="btnRole_Click" CommandArgument="Lecturer" CssClass="role-option">
                        <asp:Image ID="imgLecturer" runat="server" ImageUrl="https://freesvg.org/img/publicdomainq-0007150sdzixo.png" CssClass="role-image" />
                        <div class="role-text">Lecturer</div>
                    </asp:LinkButton>
                    
                    <asp:LinkButton ID="btnStudent" runat="server" OnClick="btnRole_Click" CommandArgument="Student" CssClass="role-option">
                        <asp:Image ID="imgStudent" runat="server" ImageUrl="https://png.pngtree.com/png-clipart/20250209/original/pngtree-cute-style-cartoon-style-college-student-graduation-photo-png-image_20401093.png" CssClass="role-image" />
                        <div class="role-text">Student</div>
                    </asp:LinkButton>
                </div>
            </div>
        </div>
    </form>
</body>
</html>