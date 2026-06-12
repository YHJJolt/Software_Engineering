<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminProfile.aspx.cs" Inherits="SchoolSystem.AdminProfile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />
        <style>
            .input-box { width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-family: inherit; margin-bottom: 12px; box-sizing: border-box; }
            .pw-section { border-top: 1px solid #eee; margin-top: 25px; padding-top: 10px; }
        </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="user-profile-page">
    <h1 style="margin-bottom: 30px; color: var(--navy-accent); font-weight: 800;">My Profile</h1>
    
    <div class="profile-container">
        <div class="left-col">
            <h3>User Profile</h3>
            <asp:Image ID="imgBigProfile" runat="server" CssClass="profile-main-img" ImageUrl="~/Images/default-avatar.png" />
            <br />
            <asp:FileUpload ID="fileUploadImg" runat="server" style="display:none;" onchange="this.form.submit();" />
            <button type="button" class="upload-btn" onclick="document.getElementById('<%= fileUploadImg.ClientID %>').click();">Edit Profile Picture</button>
        </div>

        <div class="right-col">
            <h1 style="text-transform: uppercase; color: var(--navy-accent); font-weight: 800; margin-top: 0;"><asp:Literal ID="litFullName" runat="server" /></h1>
            
            <span class="info-label">Email</span>
            <p style="color: rgba(18, 20, 32, 0.6); font-weight: 600;"><asp:Literal ID="litEmail" runat="server" /></p>

            <span class="info-label">Contact Number</span>
            <asp:TextBox ID="txtContact" runat="server" CssClass="input-box" placeholder="e.g. 012-3456789"></asp:TextBox>

            <span class="info-label">Biography</span>
            <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" CssClass="bio-box" placeholder="Tell us about yourself..."></asp:TextBox>

            <div class="pw-section">
                <span class="info-label">Change Password</span>
                <asp:TextBox ID="txtCurrentPw" runat="server" TextMode="Password" CssClass="input-box" placeholder="Current password"></asp:TextBox>
                <asp:TextBox ID="txtNewPw" runat="server" TextMode="Password" CssClass="input-box" placeholder="New password (min 6 characters)"></asp:TextBox>
                <asp:TextBox ID="txtConfirmPw" runat="server" TextMode="Password" CssClass="input-box" placeholder="Confirm new password"></asp:TextBox>
                <asp:Button ID="btnChangePw" runat="server" Text="Change Password" CssClass="btn-save" OnClick="btnChangePw_Click" CausesValidation="false" />
            </div>

            <div class="action-buttons">
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout" CausesValidation="false">
                    <i class="fas fa-power-off"></i> Log Out
                </asp:LinkButton>

                <asp:Button ID="btnSaveBio" runat="server" Text="Save Profile" CssClass="btn-save" OnClick="btnSaveBio_Click" />
            </div>
        </div>
    </div>
</div>
</asp:Content>