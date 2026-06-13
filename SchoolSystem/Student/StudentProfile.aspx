<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="SchoolSystem.StudentProfile" %>
<%-- MasterPageFile above is the default; it is overridden in Page_PreInit when course_id is present --%>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
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
                    <asp:LinkButton ID="btnLogout" runat="server" CssClass="btn-logout" OnClick="btnLogout_Click">
                        <i class="fas fa-power-off"></i> Log Out
                    </asp:LinkButton>
    
                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile" CssClass="btn-save" OnClick="btnSaveProfile_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>