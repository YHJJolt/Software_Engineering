<%@ Page Title="Course Modules" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master" AutoEventWireup="true" CodeBehind="StudentCourseModules.aspx.cs" Inherits="SchoolSystem.StudentCourseModules" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <div class="container-fluid py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="text-primary">
                <asp:Label ID="lblCourseBreadcrumb" runat="server" Text="Course"></asp:Label>
                <span class="text-muted"> > Modules</span>
            </h3>
            </div>

        <asp:UpdatePanel ID="upnlModules" runat="server">
            <ContentTemplate>
                
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="text-center py-5 empty-state-container" Visible="true">
                    <i class="fas fa-cubes fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No Modules Available</h4>
                    <p class="text-secondary">Your lecturer hasn't uploaded any content for this course yet.</p>
                </asp:Panel>
                
                <asp:Panel ID="pnlModules" runat="server" Visible="false" CssClass="module-scroll-container">
                    <div id="moduleAccordion">
                        <asp:Repeater ID="rptModules" runat="server" OnItemDataBound="rptModules_ItemDataBound">
                            <ItemTemplate>
                                <div class="custom-module-item mb-3 shadow-sm">
                                    
                                    <div class="custom-module-header d-flex bg-light">
                                        <button type="button" class="custom-module-btn bg-light fw-bold flex-grow-1" onclick="toggleCustomModule('content_<%# Eval("module_id") %>', 'icon_<%# Eval("module_id") %>')">
                                            <i id='icon_<%# Eval("module_id") %>' class="fas fa-caret-down me-2 custom-module-caret"></i> <%# Eval("module_name") %>
                                        </button>
                                    </div>
                                    
                                    <div id='content_<%# Eval("module_id") %>' style="display: block;">
                                        <div class="p-0">
                                            <asp:Panel runat="server" Visible='<%# !string.IsNullOrWhiteSpace(Eval("module_description").ToString()) %>' CssClass="p-3 bg-light border-bottom text-muted small">
                                                <%# Eval("module_description") %>
                                            </asp:Panel>
                                            
                                            <ul class="list-group list-group-flush">
                                                <asp:Repeater ID="rptFiles" runat="server">
                                                    <ItemTemplate>
                                                        <li class="list-group-item p-3 d-flex align-items-center border-0 border-bottom">
                                                            <div class="flex-grow-1">
                                                                <div class="d-flex align-items-center">
                                                                    <i class='<%# GetFileIcon(Eval("file_name").ToString()) %> fa-lg me-3'></i>
                                                                    <a href="javascript:void(0);" onclick='openCustomPreview("<%# ResolveUrl(Eval("file_path").ToString()) %>", "<%# Eval("file_title").ToString().Replace("\"", "\\\"").Replace("'", "\\'") %>")' class="text-decoration-none text-dark fw-bold hover-primary">
                                                                        <%# Eval("file_title") %>
                                                                    </a>
                                                                </div>
                                                                <p class="mb-0 mt-1 ms-4 text-muted small"><%# Eval("file_description") %></p>
                                                            </div>
                                                            </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </ul>
                                            </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>

            </ContentTemplate>
        </asp:UpdatePanel>

        <div id="customPreviewOverlay" class="custom-preview-overlay">
            <div class="custom-preview-modal">
                <div class="custom-preview-header">
                    <h5 style="margin: 0; font-weight: bold; color: white;">
                        <i class="fas fa-file-alt me-2 text-info"></i> <span id="customPreviewTitle">Document Preview</span>
                    </h5>
                    <button type="button" class="custom-preview-close" onclick="closeCustomPreview()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div id="customPreviewContainer" class="custom-preview-body"></div>
            </div>
        </div>

    </div>
    
    <script>
        function toggleCustomModule(contentId, iconId) {
            var content = document.getElementById(contentId);
            var icon = document.getElementById(iconId);

            if (content.style.display === "none") {
                content.style.display = "block";
                icon.classList.remove('collapsed');
            } else {
                content.style.display = "none";
                icon.classList.add('collapsed');
            }
        }

        // ADVANCED FILE PREVIEW INJECTION
        function openCustomPreview(fileUrl, fileTitle) {
            document.getElementById('customPreviewTitle').innerText = fileTitle;
            const ext = fileUrl.split('.').pop().toLowerCase();
            const container = document.getElementById('customPreviewContainer');

            container.innerHTML = '';
            
            if (ext === 'pdf' || ext === 'txt') {
                container.innerHTML = `
                    <object data="${fileUrl}" type="application/pdf" width="100%" height="100%" style="display: block; border: none;">
                        <iframe src="${fileUrl}" width="100%" height="100%" style="border: none;">
                            This browser does not support embedded PDFs.
                        </iframe>
                    </object>`;
            }
            else if (ext === 'jpg' || ext === 'png' || ext === 'jpeg' || ext === 'gif') {
                container.innerHTML = `
                    <div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #212529;">
                        <img src="${fileUrl}" style="max-width: 95%; max-height: 95%; object-fit: contain; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" />
                    </div>`;
            }
            else {
                container.innerHTML = `
                    <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #f8f9fa;">
                        <i class="fas fa-file-download text-secondary mb-3" style="font-size: 60px;"></i>
                        <h3 class="fw-bold text-dark">Preview Not Available</h3>
                        <p class="text-secondary mb-4">Web browsers cannot natively preview .${ext} files.</p>
                        <a href="${fileUrl}" target="_blank" class="btn btn-primary px-4 shadow-sm">
                            <i class="fas fa-download me-2"></i> Download File
                        </a>
                    </div>`;
            }

            document.getElementById('customPreviewOverlay').style.display = 'flex';
        }

        function closeCustomPreview() {
            document.getElementById('customPreviewOverlay').style.display = 'none';
            document.getElementById('customPreviewContainer').innerHTML = '';
        }
    </script>
</asp:Content>