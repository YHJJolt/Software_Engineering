<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/Student/StudentMaster.Master" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="SchoolSystem.StudentProfile" %>
<%-- MasterPageFile above is the default; it is overridden in Page_PreInit when course_id is present --%>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .pw-wrap { position: relative; margin-bottom: 12px; }
        .pw-wrap .pw-input { margin-bottom: 0; padding-right: 42px; }
        .pw-toggle { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #888; font-size: 15px; }
        .pw-toggle:hover { color: var(--navy-accent); }
    </style>
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
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtCurrentPw" runat="server" TextMode="Password" CssClass="input-box pw-input" placeholder="Current password"></asp:TextBox>
                        <i class="fas fa-eye pw-toggle" onclick="togglePw(this)"></i>
                    </div>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtNewPw" runat="server" TextMode="Password" CssClass="input-box pw-input" placeholder="New password (min 6 characters)"></asp:TextBox>
                        <i class="fas fa-eye pw-toggle" onclick="togglePw(this)"></i>
                    </div>
                    <div class="pw-wrap">
                        <asp:TextBox ID="txtConfirmPw" runat="server" TextMode="Password" CssClass="input-box pw-input" placeholder="Confirm new password"></asp:TextBox>
                        <i class="fas fa-eye pw-toggle" onclick="togglePw(this)"></i>
                    </div>
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
</asp:Content>