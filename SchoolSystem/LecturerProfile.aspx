<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/LecturerMaster.Master" AutoEventWireup="true" CodeBehind="LecturerProfile.aspx.cs" Inherits="SchoolSystem.LecturerProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-container">
        <div class="left-col">
            <asp:Image ID="imgBigProfile" runat="server" CssClass="profile-main-img" ImageUrl="~/Images/default-avatar.png" />
            <br />
            <asp:FileUpload ID="fileUploadImg" runat="server" style="display:none;" onchange="this.form.submit();" />
            <button type="button" class="upload-btn" onclick="document.getElementById('<%= fileUploadImg.ClientID %>').click();">Edit Profile Picture</button>
        </div>

        <div class="right-col">
            <h1 style="text-transform: uppercase; color: var(--navy-accent); font-weight: 800; margin-top: 0;"><asp:Literal ID="litFullName" runat="server" /></h1>
            
            <span class="info-label">Contact</span>
            <p style="color: rgba(18, 20, 32, 0.6); font-weight: 600;"><asp:Literal ID="litEmail" runat="server" /></p>

            <span class="info-label">Biography</span>
            <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" CssClass="bio-box" placeholder="Tell us about yourself..."></asp:TextBox>

            <div class="action-buttons">
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout" CausesValidation="false">
                    <i class="fas fa-power-off"></i> Log Out
                </asp:LinkButton>
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click" CssClass="btn-save" />
            </div>
        </div>
    </div>
</asp:Content>