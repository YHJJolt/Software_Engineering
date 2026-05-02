# Software_Engineering
Bachelor in Computer Science, Year 2 Semester 2 Module: Software Engineering

---

# Installation Guide

1. Download this entire ZIP file.
2. Browse SQL file and run the code in SQL Server Management Studio 22.
3. Extract all the file, move the entire file under your Visual Studio Project directory.
4. Under WebConfig, change your database pathway.
5. Test and Run your code.

---

# Add new Page
1. On the first line
   ``` <%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="SchoolSystem.WebForm1" %>```
   
   Add:
   ```MasterPageFile="~/AdminMaster.Master"``` and ```CodeBehind="AdminDashboard.aspx.cs" ```// This 2 command is your sidebar.
   
   After:
   ```<%@ Page Title="PAGENAME" Language="C#" MasterPageFile="~/AdminMaster.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="SchoolSystem.Courses" %>```
   //This 2 command is your sidebar.
   
3. Under AdminMaster.Master file, make sure to add your PAGENAME.aspx
4. Remove default all HTML body, replace your page content with:

```
   <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

</asp:Content>

```

5. ENJOY
   
