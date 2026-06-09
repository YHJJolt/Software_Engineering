<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="SchoolSystem.StudentProfile" %>
<%-- MasterPageFile above is the default; it is overridden in Page_PreInit when course_id is present --%>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .user-profile-page { background: white; padding: 40px; border-radius: 12px; box-shadow: var(--shadow-sm); border: 1px solid #eee; }
        .profile-container { display: flex; gap: 40px; }
        .left-col { width: 300px; text-align: center; border-right: 1px solid #eee; padding-right: 40px; }
        .profile-main-img { width: 200px; height: 200px; border-radius: 50%; object-fit: cover; border: 4px solid var(--antique-gold); margin-bottom: 20px; box-shadow: var(--shadow-md); }
        .upload-btn { background: var(--antique-gold); color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; width: 100%; transition: background 0.3s; }
        .upload-btn:hover { background: #b08d4b; }
        .right-col { flex-grow: 1; }
        .info-label { font-size: 13px; color: var(--text-muted); font-weight: 700; text-transform: uppercase; margin-top: 20px; display: block; }
        .bio-box { width: 100%; min-height: 150px; padding: 15px; border: 1px solid #ddd; border-radius: 8px; font-family: inherit; resize: vertical; margin-bottom: 30px; }
        
        /* FIXED: Added justify-content: flex-end to push buttons to the right */
        .action-buttons { display: flex; justify-content: flex-end; gap: 15px; border-top: 1px solid #eee; padding-top: 20px; }
        
        .btn-logout { background: #fee2e2; color: #dc2626; padding: 12px 25px; border-radius: 6px; text-decoration: none; font-weight: 600; transition: background 0.3s; display: inline-flex; align-items: center; gap: 6px; }
        .btn-logout:hover { background: #fca5a5; color: #dc2626; }
        .btn-save { background: var(--navy-accent); color: white; border: none; padding: 12px 30px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: background 0.3s; }
        .btn-save:hover { background: #0a0c14; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="user-profile-page">
        <h1 style="margin-bottom: 30px; color: var(--navy-accent); font-weight: 800;">My Profile</h1>
        
        <div class="profile-container">
            <div class="left-col">
                <h3 style="color: var(--text-muted); margin-top: 0;">User Image</h3>
                <asp:Image ID="imgBigProfile" runat="server" CssClass="profile-main-img" ImageUrl="~/Images/default-avatar.png" />
                <br />
                <asp:FileUpload ID="fileUploadImg" runat="server" style="display:none;" onchange="this.form.submit();" />
                <button type="button" class="upload-btn" onclick="document.getElementById('<%= fileUploadImg.ClientID %>').click();">Edit Profile Picture</button>
            </div>

            <div class="right-col">
                <h1 style="text-transform: uppercase; color: var(--navy-accent); font-weight: 800; margin-top: 0;">
                    <asp:Literal ID="litFullName" runat="server" />
                </h1>
                
                <span class="info-label">Contact Email</span>
                <p style="color: var(--navy-accent); font-weight: 600; margin: 5px 0 20px 0; font-size: 18px;">
                    <asp:Literal ID="litEmail" runat="server" />
                </p>

                <span class="info-label">Biography</span>
                <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" CssClass="bio-box" placeholder="Tell us about yourself..."></asp:TextBox>

                <div class="action-buttons">
                    <asp:LinkButton ID="btnLogout" runat="server" CssClass="btn-logout" OnClick="btnLogout_Click">
                        <i class="fas fa-power-off"></i> Log Out
                    </asp:LinkButton>
    
                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile" CssClass="btn-save" OnClick="btnSaveProfile_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>