<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleSelect.aspx.cs" Inherits="SchoolSystem.RoleSelect" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Role - School System</title>
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

        .page-content { flex: 1; display: flex; justify-content: center; align-items: center; padding: 60px 0; }
        
        .white-box { 
            background-color: #fff; 
            border-radius: 30px; 
            padding: 80px 60px; 
            width: 850px; /* Increased width to fill space */
            box-shadow: 0 10px 30px rgba(0,0,0,0.1); 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
            border: 1px solid rgba(0,0,0,0.05); 
        }

        .title-row { display: flex; align-items: center; gap: 20px; margin-bottom: 80px; }
        .title-row h1 { font-size: 48px; font-weight: bold; margin: 0; color: #333; }
        .user-icon { width: 45px; height: 45px; border-radius: 50%; border: 3px solid #333; display: flex; justify-content: center; align-items: center; color: #333; font-weight: bold; font-size: 24px; }

        .roles-grid { display: flex; gap: 100px; justify-content: center; width: 100%; }
        .role-button { background: none; border: none; padding: 0; cursor: pointer; text-decoration: none; color: inherit; display: flex; flex-direction: column; align-items: center; transition: all 0.3s ease; }
        .role-button:hover { transform: translateY(-10px); }

        .role-icon-img { width: 180px; height: 180px; border-radius: 50%; object-fit: contain; margin-bottom: 25px; }
        .role-label { font-size: 28px; font-weight: bold; text-align: center; color: #444; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="gradient-bg">
            <div class="page-content">
                <div class="white-box">
                    <div class="title-row">
                        <h1>Select Role</h1>
                        <div class="user-icon">👤</div> 
                    </div>
                    <div class="roles-grid">
                        <asp:LinkButton ID="btnHOP" runat="server" OnClick="btnRole_Click" CommandArgument="HOP" CssClass="role-button">
                            <asp:Image ID="imgHop" runat="server" ImageUrl="https://img.icons8.com/color/180/manager.png" CssClass="role-icon-img" />
                            <div class="role-label">HOP</div>
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnLecturer" runat="server" OnClick="btnRole_Click" CommandArgument="Lecturer" CssClass="role-button">
                            <asp:Image ID="imgLecturer" runat="server" ImageUrl="https://img.icons8.com/color/180/teacher.png" CssClass="role-icon-img" />
                            <div class="role-label">Lecturer</div>
                        </asp:LinkButton>
                        
                        <asp:LinkButton ID="btnStudent" runat="server" OnClick="btnRole_Click" CommandArgument="Student" CssClass="role-button">
                            <asp:Image ID="imgStudent" runat="server" ImageUrl="https://img.icons8.com/color/180/student-male.png" CssClass="role-icon-img" />
                            <div class="role-label">Student</div>
                        </asp:LinkButton>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>