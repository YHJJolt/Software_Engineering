<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleSelect.aspx.cs" Inherits="SchoolSystem.RoleSelect" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Role - School System</title>
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />

</head>
<body>
    <form id="form1" runat="server">
        <div class="role-selection-page">
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
        </div>
    </form>
</body>
</html>