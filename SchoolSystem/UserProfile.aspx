<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="UserProfile.aspx.cs" Inherits="SchoolSystem.UserProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Profile Panel Styling - Jingliu Light Theme */
        .profile-container { 
            display: flex; gap: 50px; padding: 45px; 
            background: #ffffff; border-radius: 12px; 
            box-shadow: 0 4px 20px rgba(18, 20, 32, 0.05); 
            border: 1px solid rgba(18, 20, 32, 0.05);
        }

        .left-col { text-align: center; width: 250px; }
        .right-col { flex: 1; }

        .profile-main-img { 
            width: 180px; height: 180px; border-radius: 12px; 
            object-fit: cover; background: #fdfaf6; 
            margin-bottom: 20px; 
            border: 3px solid var(--antique-gold); /* Brass/Gold Accent */
        }

        /* Themed Upload Button */
        .upload-btn { 
            font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;
            color: var(--antique-gold); background: rgba(197, 160, 89, 0.1); 
            padding: 10px 20px; border: none; border-radius: 30px; cursor: pointer; transition: 0.2s;
        }
        .upload-btn:hover { background: var(--antique-gold); color: white; }

        /* Typography & Details */
        .info-label { font-size: 12px; font-weight: 700; text-transform: uppercase; color: rgba(18, 20, 32, 0.4); letter-spacing: 1px; margin-top: 25px; display: block; }
        .bio-box { 
            width: 100%; height: 120px; padding: 15px; border: 1px solid rgba(18, 20, 32, 0.1); 
            border-radius: 8px; font-size: 14px; font-family: inherit; color: var(--navy-accent); 
            background: #fcfcfc; resize: none; transition: 0.2s; box-sizing: border-box; margin-top: 5px;
        }
        .bio-box:focus { outline: none; border-color: var(--antique-gold); background: #ffffff; }

        /* Buttons Container */
        .action-buttons {
            margin-top: 30px; 
            display: flex; 
            justify-content: flex-end; 
            gap: 15px;
        }

        /* Action Buttons */
        .btn-save { 
            padding: 12px 30px; border: none; border-radius: 8px; 
            background: var(--navy-accent); color: white; font-size: 14px; font-weight: 600; 
            cursor: pointer; transition: 0.2s; 
        }
        .btn-save:hover { background: #2a2e45; box-shadow: 0 4px 15px rgba(18, 20, 32, 0.2); }

        /* New Modern Logout Button */
        .btn-logout {
            padding: 12px 25px; 
            border: none; 
            border-radius: 8px; 
            background: #ffeaea; 
            color: #e74c3c; 
            font-size: 14px; 
            font-weight: 600; 
            cursor: pointer; 
            text-decoration: none; 
            transition: 0.2s; 
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-logout:hover { 
            background: #ffcece; 
            color: #c0392b; 
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
            
            <span class="info-label">Contact</span>
            <p style="color: rgba(18, 20, 32, 0.6); font-weight: 600;"><asp:Literal ID="litEmail" runat="server" /></p>

            <span class="info-label">Biography</span>
            <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" CssClass="bio-box" placeholder="Tell us about yourself..."></asp:TextBox>

            <div class="action-buttons">
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout" CausesValidation="false">
                    <i class="fas fa-power-off"></i> Log Out
                </asp:LinkButton>
                
                <asp:Button ID="btnSaveBio" runat="server" Text="Save Bio" CssClass="btn-save" OnClick="btnSaveBio_Click" />
            </div>
        </div>
    </div>
</asp:Content>