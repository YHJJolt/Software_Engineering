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
            font-size: 12px; font-weight: 700; color: var(--soft-glow); 
            cursor: pointer; background: rgba(125, 138, 255, 0.1); 
            padding: 8px 18px; border-radius: 8px; 
            border: 1px solid var(--soft-glow); transition: 0.3s;
        }
        .upload-btn:hover { background: rgba(125, 138, 255, 0.2); color: var(--navy-accent); }

        .info-label { 
            font-weight: 800; color: var(--navy-accent); 
            margin-top: 25px; display: block; font-size: 14px; 
            text-transform: uppercase; letter-spacing: 1px;
            border-bottom: 2px solid var(--antique-gold); /* Structural Gold Line */
            padding-bottom: 5px; margin-bottom: 15px;
        }

        .bio-box { 
            width: 100%; height: 140px; margin-top: 10px; padding: 15px; 
            border: 1px solid rgba(18, 20, 32, 0.1); border-radius: 8px; 
            font-family: inherit; font-size: 14px; color: var(--navy-accent);
            background: #fdfaf6; resize: none;
        }
        .bio-box:focus { outline: none; border-color: var(--soft-glow); box-shadow: 0 0 5px rgba(125, 138, 255, 0.2); }

        /* Themed Save Button */
        .save-btn { 
            margin-top: 25px; background: var(--navy-accent); 
            color: var(--cream-base); border: 1px solid var(--antique-gold); 
            padding: 12px 30px; border-radius: 8px; cursor: pointer; 
            font-weight: 800; text-transform: uppercase; letter-spacing: 1px;
            transition: 0.3s;
        }
        .save-btn:hover { background: var(--antique-gold); color: var(--navy-accent); }

        h3 { color: var(--navy-accent); font-weight: 800; margin-top: 0; }
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
            
            <br />
            <asp:Button ID="IDbtnSaveBio" runat="server" Text="Save Biography" CssClass="save-btn" OnClick="btnSaveBio_Click" />
        </div>
    </div>
</asp:Content>