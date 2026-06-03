<%@ Page Title="Course Assignments" Language="C#" MasterPageFile="~/Student/StudentCourseMaster.Master" AutoEventWireup="true" CodeBehind="StudentCourseAssignments.aspx.cs" Inherits="SchoolSystem.StudentCourseAssignments" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <div class="toast-container position-fixed top-0 end-0 p-4" style="z-index: 1100;">
        <div id="successToast" class="toast align-items-center text-white bg-success border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body fs-6">
                    <i class="fas fa-check-circle me-2"></i> <span id="toastMessage">Success!</span>
                </div>
                <button type="button" class="btn-close btn-close-white me-3 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    </div>

    <div class="container-fluid py-4">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="text-primary">
                <asp:Label ID="lblCourseBreadcrumb" runat="server" Text="Course"></asp:Label>
                <span class="text-muted"> > Assignments</span>
            </h3>
            
            <div class="d-flex gap-2">
                <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select shadow-sm w-auto" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                    <asp:ListItem Text="Due Date: Earliest" Value="ASC"></asp:ListItem>
                    <asp:ListItem Text="Due Date: Latest" Value="DESC"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <asp:UpdatePanel ID="upnlAssignments" runat="server">
            <ContentTemplate>
                
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="text-center py-5 empty-state-container" Visible="true">
                    <i class="fas fa-file-signature fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No Assignments Yet</h4>
                    <p class="text-secondary">Your lecturer hasn't posted any assignments for this course.</p>
                </asp:Panel>

                <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
                    <asp:Repeater ID="rptAssignments" runat="server" OnItemDataBound="rptAssignments_ItemDataBound">
                        <ItemTemplate>
                            <div class="card shadow-sm border-0 mb-3">
                                <div class="card-body p-4">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <div class="d-flex align-items-center gap-3">
                                            <div class="bg-light rounded-circle p-3 text-center" style="width: 60px; height: 60px;">
                                                <i class="fas fa-file-alt text-primary fa-lg mt-1"></i>
                                            </div>
                                            <div>
                                                <h5 class="mb-1 fw-bold"><%# Eval("title") %></h5>
                                                <p class="text-muted mb-0 small">
                                                    <i class="far fa-calendar-alt me-1"></i> Due: <%# Convert.ToDateTime(Eval("due_date")).ToString("dd MMM yyyy, hh:mm tt") %>
                                                    <span class="ms-2 badge <%# GetBadgeClass(Eval("assignment_type").ToString()) %>"><%# Eval("assignment_type") %></span>
                                                </p>
                                            </div>
                                        </div>
                                        <asp:Label ID="lblStatusBadge" runat="server" CssClass="badge rounded-pill fs-6 px-3 py-2"></asp:Label>
                                    </div>

                                    <asp:Panel runat="server" Visible='<%# Eval("description") != DBNull.Value && !string.IsNullOrWhiteSpace(Eval("description").ToString()) %>' CssClass="p-3 bg-light rounded text-secondary small mb-3 border">
                                        <%# Eval("description") %>
                                    </asp:Panel>
                                    
                                    <div class="d-flex align-items-center justify-content-between border-top pt-3 mt-2">
                                        <div class="d-flex align-items-center gap-3">
                                            <%# GetGuidelineLink(Eval("attachment_path"), Eval("title")) %>
                                            <span class="fw-bold text-dark">Max Marks: <%# Eval("max_marks") %></span>
                                        </div>
                                        
                                        <div class="d-flex align-items-center gap-3">
                                            <asp:Panel ID="pnlGradeInfo" runat="server" Visible="false" CssClass="fw-bold text-success fs-5">
                                                Score: <asp:Literal ID="litScore" runat="server"></asp:Literal> / <%# Eval("max_marks") %>
                                            </asp:Panel>

                                            <asp:Button ID="btnOpenSubmit" runat="server" CssClass="btn btn-primary fw-bold" Text="Submit Work" UseSubmitBehavior="false"/>                                        </div>
                                    </div>

                                    <asp:Panel ID="pnlFeedback" runat="server" Visible="false" CssClass="alert alert-info mt-3 mb-0 border-0 shadow-sm">
                                        <h6 class="fw-bold text-dark mb-1"><i class="fas fa-comment-dots text-info me-2"></i> Lecturer Feedback:</h6>
                                        <asp:Literal ID="litFeedback" runat="server"></asp:Literal>
                                    </asp:Panel>

                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

                <div class="modal fade" id="submitModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header bg-light">
                                <h5 class="modal-title fw-bold">Submit Assignment: <span id="modalAssignmentTitle" class="text-primary"></span></h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body p-4">
                                <asp:HiddenField ID="hfSelectedAssignmentId" runat="server" ClientIDMode="Static" />
                
                                <div class="custom-dropzone text-center p-4 border rounded bg-light">
                                    <i id="fileUploadIcon" class="fas fa-cloud-upload-alt fa-3x text-primary mb-3"></i>
                                    <h5 id="fileNameDisplay" class="fw-bold text-secondary">Select your assignment file</h5>
                                    <p class="text-muted small">Allowed files: .pdf, .docx, .png, .jpg</p>
                                    <label for="fuSubmission" class="btn btn-outline-primary mt-2">Browse Files</label>
                                    <asp:FileUpload ID="fuSubmission" runat="server" ClientIDMode="Static" CssClass="hidden-upload-absolute" onchange="updateFileName(this, 'fileNameDisplay', 'fileUploadIcon')" />
                    
                                    <div id="localPreviewContainer" class="mt-3" style="display: none;">
                                        <button type="button" class="btn btn-sm btn-info fw-bold text-white shadow-sm" onclick="previewLocalFile('fuSubmission')">
                                            <i class="fas fa-eye me-1"></i> Preview Selected File
                                        </button>
                                    </div>

                                </div>
                            </div>
                            <div class="modal-footer border-0 bg-light p-3">
                                <asp:Button ID="btnSubmitWork" runat="server" Text="Upload Submission" CssClass="btn btn-success px-4 fw-bold" OnClick="btnSubmitWork_Click" UseSubmitBehavior="false" />
                            </div>
                        </div>
                    </div>
                </div>

            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="ddlSort" EventName="SelectedIndexChanged" />
                <asp:PostBackTrigger ControlID="btnSubmitWork" />
            </Triggers>
        </asp:UpdatePanel>

        <div id="customPreviewOverlay" class="custom-preview-overlay">
            <div class="custom-preview-modal">
                <div class="custom-preview-header">
                    <h5 style="margin: 0; font-weight: bold;"><i class="fas fa-file-alt me-2 text-info"></i> <span id="customPreviewTitle">Document Preview</span></h5>
                    <button type="button" class="custom-preview-close" onclick="closeCustomPreview()"><i class="fas fa-times"></i></button>
                </div>
                <div id="customPreviewContainer" class="custom-preview-body"></div>
            </div>
        </div>

    </div>

    <script>
        function openSubmitModal(id, title) {
            document.getElementById('hfSelectedAssignmentId').value = id;
            document.getElementById('modalAssignmentTitle').innerText = title;

            // Reset the dropzone when opening a new modal
            document.getElementById('fileNameDisplay').innerText = 'Select your assignment file';
            document.getElementById('fileNameDisplay').classList.replace('text-success', 'text-secondary');
            document.getElementById('fileUploadIcon').classList.replace('fa-check-circle', 'fa-cloud-upload-alt');
            document.getElementById('fileUploadIcon').classList.replace('text-success', 'text-primary');
            document.getElementById('localPreviewContainer').style.display = 'none';

            var submitModal = new bootstrap.Modal(document.getElementById('submitModal'));
            submitModal.show();
        }

        // 1. Show the preview button when a file is selected
        function updateFileName(input, displayId, iconId) {
            var display = document.getElementById(displayId);
            var icon = document.getElementById(iconId);
            var previewBtn = document.getElementById('localPreviewContainer');

            if (input.files && input.files.length > 0) {
                display.innerText = input.files[0].name;
                display.classList.replace('text-secondary', 'text-success');
                icon.classList.replace('fa-cloud-upload-alt', 'fa-check-circle');
                icon.classList.replace('text-primary', 'text-success');
                previewBtn.style.display = 'block'; // Reveal the preview button!
            } else {
                display.innerText = 'Select your assignment file';
                display.classList.replace('text-success', 'text-secondary');
                icon.classList.replace('fa-check-circle', 'fa-cloud-upload-alt');
                icon.classList.replace('text-success', 'text-primary');
                previewBtn.style.display = 'none'; // Hide it if they cancel
            }
        }

        // 2. Generate the temporary local browser URL
        let currentObjectUrl = null;
        function previewLocalFile(inputId) {
            const input = document.getElementById(inputId);
            if (input.files && input.files.length > 0) {
                const file = input.files[0];
                const fileName = file.name;
                const ext = fileName.split('.').pop().toLowerCase(); // Grab extension from the real filename

                // Clean up old memory if they preview multiple times
                if (currentObjectUrl) { URL.revokeObjectURL(currentObjectUrl); }

                // Create a fake, temporary URL for the local file
                currentObjectUrl = URL.createObjectURL(file);

                // Send it to the previewer!
                openCustomPreview(currentObjectUrl, "Local Preview: " + fileName, ext);
            }
        }

        // 3. Modified Previewer (Now accepts the 'fileExt' parameter)
        function openCustomPreview(fileUrl, fileTitle, fileExt = null) {
            document.getElementById('customPreviewTitle').innerText = fileTitle;

            // Use the passed extension, OR try to grab it from the URL if it's a server file
            const ext = fileExt ? fileExt.toLowerCase() : fileUrl.split('.').pop().toLowerCase();

            const container = document.getElementById('customPreviewContainer');
            container.innerHTML = '';

            if (ext === 'pdf' || ext === 'txt') {
                container.innerHTML = `<object data="${fileUrl}" type="application/pdf" width="100%" height="100%" style="display: block; border: none;"><iframe src="${fileUrl}" width="100%" height="100%" style="border: none;">Preview Unavailable</iframe></object>`;
            }
            else if (ext === 'jpg' || ext === 'png' || ext === 'jpeg') {
                container.innerHTML = `<div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #212529;"><img src="${fileUrl}" style="max-width: 95%; max-height: 95%; object-fit: contain; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" /></div>`;
            }
            else if (ext === 'docx' || ext === 'doc') {
                container.innerHTML = `<div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #f8f9fa;"><i class="fas fa-file-word text-primary mb-3" style="font-size: 70px;"></i><h3 class="fw-bold text-dark">File submitted in .docx format.</h3><p class="text-muted mt-2">Please download the file to review it.</p><a href="${fileUrl}" target="_blank" class="btn btn-primary px-4 mt-3 shadow-sm"><i class="fas fa-download me-2"></i> Download File</a></div>`;
            }
            else {
                container.innerHTML = `<div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #f8f9fa;"><i class="fas fa-file-download text-secondary mb-3" style="font-size: 60px;"></i><h3 class="fw-bold text-dark">Browser Cannot Preview .${ext}</h3><a href="${fileUrl}" target="_blank" class="btn btn-primary px-4 mt-3 shadow-sm"><i class="fas fa-download me-2"></i> Download File</a></div>`;
            }

            document.getElementById('customPreviewOverlay').style.display = 'flex';
        }

        function closeCustomPreview() {
            document.getElementById('customPreviewOverlay').style.display = 'none';
            document.getElementById('customPreviewContainer').innerHTML = '';
        }
    </script>
</asp:Content>