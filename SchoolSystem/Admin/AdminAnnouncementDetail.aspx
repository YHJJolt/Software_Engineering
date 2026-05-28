<%@ Page Title="Announcement Detail" Language="C#" MasterPageFile="~/Admin/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminAnnouncementDetail.aspx.cs" Inherits="SchoolSystem.AdminAnnouncementDetail" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <link href="~/Admin/Admin.css" rel="stylesheet" type="text/css" />

    <div style="max-width: 800px; margin: 0 auto; font-family: 'Inter', sans-serif;">

        <button type="button" onclick="history.back()"
                style="background:none; border:none; cursor:pointer; color:#555; font-size:14px; margin-bottom:20px; padding:0;">
            <i class="fa-solid fa-arrow-left"></i> Back to Announcements
        </button>

        <div style="background:white; border-radius:12px; padding:32px; box-shadow:0 2px 8px rgba(0,0,0,0.06);">
            <span id="lblCategory" runat="server" 
                  style="font-size:10px; font-weight:800; text-transform:uppercase; padding:4px 10px; border-radius:20px; display:inline-block;"></span>

            <h2 id="lblTitle" runat="server" 
                style="margin:12px 0 8px; font-size:1.6rem; color:#121420;"></h2>

            <p style="font-size:12px; color:#999; margin-bottom:24px;">
                <strong><asp:Literal ID="lblPostedBy" runat="server" /></strong>
                &nbsp;·&nbsp;
                <asp:Literal ID="lblDate" runat="server" />
                at
                <asp:Literal ID="lblTime" runat="server" />
            </p>

            <hr style="border:none; border-top:1px solid #eee; margin-bottom:24px;" />

            <div id="lblContent" runat="server" 
                 style="color:#444; font-size:15px; line-height:1.8; white-space:pre-wrap;"></div>
        </div>

    </div>
</asp:Content>