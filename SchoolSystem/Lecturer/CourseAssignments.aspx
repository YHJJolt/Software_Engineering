<%@ Page Title="Course Assignments" Language="C#" MasterPageFile="~/Lecturer/LecturerCourseMaster.Master" AutoEventWireup="true" CodeBehind="CourseAssignments.aspx.cs" Inherits="SchoolSystem.CourseAssignments" %>

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
                
                <button type="button" class="btn btn-primary shadow-sm text-nowrap" data-bs-toggle="modal" data-bs-target="#addAssignmentModal">
                    <i class="fas fa-plus me-2"></i> Create Assignment
                </button>
            </div>
        </div>

        <asp:UpdatePanel ID="upnlAssignments" runat="server">
            <ContentTemplate>
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="text-center py-5 empty-state-container" Visible="true">
                    <i class="fas fa-file-signature fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No Assignments Yet</h4>
                </asp:Panel>

                <asp:Panel ID="pnlAssignments" runat="server" Visible="false">
                    <asp:Repeater ID="rptAssignments" runat="server">
                        <ItemTemplate>
                            <div class="card shadow-sm border-0 mb-3">
                                <div class="card-body d-flex align-items-center p-4">
                                    <div class="bg-light rounded-circle p-3 me-4 text-center" style="width: 60px; height: 60px;">
                                        <i class="fas fa-file-alt text-primary fa-lg mt-1"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <h5 class="mb-1 fw-bold"><%# Eval("title") %></h5>
                                        <p class="text-muted mb-1 small">
                                            <i class="far fa-calendar-alt me-1"></i> Due: <%# Convert.ToDateTime(Eval("due_date")).ToString("dd MMM yyyy, hh:mm tt") %>
                                            | Max Marks: <%# Eval("max_marks") %>
                                        </p>
                                        
                                        <asp:Panel runat="server" Visible='<%# Eval("description") != DBNull.Value && !string.IsNullOrWhiteSpace(Eval("description").ToString()) %>' CssClass="text-secondary small mb-2">
                                            <%# Eval("description") %>
                                        </asp:Panel>
                                        
                                        <%# GetGuidelineLink(Eval("attachment_path"), Eval("title")) %>
                                    </div>
                                    
                                    <div class="me-4">
                                        <span class="badge <%# GetBadgeClass(Eval("assignment_type").ToString()) %> px-3 py-2 rounded-pill">
                                            <%# Eval("assignment_type") %>
                                        </span>
                                    </div>
                                    
                                    <div class="d-flex align-items-center gap-2 border-start ps-4">
                                        <asp:LinkButton ID="btnGrade" runat="server" CssClass="btn btn-sm btn-success px-3 py-2 fw-bold" CommandArgument='<%# Eval("assignment_id") %>' OnClick="btnGrade_Click" ToolTip="Grade Submissions">
                                            <i class="fas fa-check-double me-1"></i> Evaluate
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-secondary px-3 py-2" CommandArgument='<%# Eval("assignment_id") %>' OnClick="btnEdit_Click" ToolTip="Edit Assignment">
                                            <i class="fas fa-pen"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-sm btn-outline-danger px-3 py-2 border-0" OnClientClick='<%# "showDeleteConfirmModal(" + Eval("assignment_id") + "); return false;" %>' ToolTip="Delete Assignment">
                                            <i class="fas fa-trash"></i>
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

                <div class="modal fade" id="addAssignmentModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Create Assignment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                            <div class="modal-body p-4">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Assignment Title</label>
                                    <asp:TextBox ID="txtAssignmentTitle" runat="server" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Description / Instructions</label>
                                    <asp:TextBox ID="txtAssignmentDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                                </div>
                                <div class="row mb-4">
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Type</label>
                                        <asp:DropDownList ID="ddlAssignmentType" runat="server" CssClass="form-select">
                                            <asp:ListItem Text="Coursework" Value="Coursework"></asp:ListItem>
                                            <asp:ListItem Text="Midterm Exam" Value="Midterm"></asp:ListItem>
                                            <asp:ListItem Text="Final Exam" Value="Final"></asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Max Marks</label>
                                        <asp:TextBox ID="txtMaxMarks" runat="server" CssClass="form-control" TextMode="Number" Text="100"></asp:TextBox>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Due Date & Time</label>
                                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox>
                                    </div>
                                </div>
                                
                                <div class="custom-dropzone mt-3 text-center p-4 border rounded bg-light">
                                    <i id="addFileIcon" class="fas fa-cloud-upload-alt fa-3x text-primary mb-3"></i>
                                    <h5 id="addFileName" class="fw-bold text-secondary">Select Guideline File (Optional)</h5>
                                    <label for="fuAssignmentFile" class="btn btn-outline-primary mt-2">Browse Files</label>
                                    <asp:FileUpload ID="fuAssignmentFile" runat="server" ClientIDMode="Static" CssClass="hidden-upload-absolute" onchange="updateFileName(this, 'addFileName', 'addFileIcon')" />
                                </div>
                            </div>
                            <div class="modal-footer border-0 bg-light p-3">
                                <asp:Button ID="btnSaveAssignment" runat="server" Text="Publish Assignment" CssClass="btn btn-primary px-4 fw-bold" OnClick="btnSaveAssignment_Click" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal fade" id="editAssignmentModal" tabindex="-1">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit Assignment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                            <div class="modal-body p-4">
                                <asp:HiddenField ID="hfEditAssignmentId" runat="server" />
                                <div class="mb-3"><label class="form-label fw-bold">Assignment Title</label><asp:TextBox ID="txtEditTitle" runat="server" CssClass="form-control"></asp:TextBox></div>
                                <div class="mb-3"><label class="form-label fw-bold">Description / Instructions</label><asp:TextBox ID="txtEditDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox></div>
                                <div class="row mb-4">
                                    <div class="col-md-4"><label class="form-label fw-bold">Type</label><asp:DropDownList ID="ddlEditType" runat="server" CssClass="form-select"><asp:ListItem Text="Coursework" Value="Coursework"></asp:ListItem><asp:ListItem Text="Midterm Exam" Value="Midterm"></asp:ListItem><asp:ListItem Text="Final Exam" Value="Final"></asp:ListItem></asp:DropDownList></div>
                                    <div class="col-md-4"><label class="form-label fw-bold">Max Marks</label><asp:TextBox ID="txtEditMaxMarks" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox></div>
                                    <div class="col-md-4"><label class="form-label fw-bold">Due Date</label><asp:TextBox ID="txtEditDueDate" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox></div>
                                </div>
                            </div>
                            <div class="modal-footer border-0 bg-light p-3">
                                <asp:Button ID="btnUpdateAssignment" runat="server" Text="Update Assignment" CssClass="btn btn-success px-4 fw-bold" OnClick="btnUpdateAssignment_Click" />
                            </div>
                        </div>
                    </div>
                </div>

                <asp:HiddenField ID="hfDeleteAssignmentId" runat="server" ClientIDMode="Static" />
                <div class="modal fade" id="deleteConfirmModal" tabindex="-1">
                    <div class="modal-dialog modal-dialog-centered modal-sm">
                        <div class="modal-content text-center p-4 border-0 shadow-lg" style="border-radius: 15px; overflow: hidden;">
                            <div class="modal-body p-0">
                                <div class="mb-4 mt-2">
                                    <div class="d-inline-flex align-items-center justify-content-center bg-danger bg-opacity-10 text-danger rounded-circle" style="width: 80px; height: 80px;">
                                        <i class="fas fa-exclamation text-danger" style="font-size: 40px;"></i>
                                    </div>
                                </div>
                                <h4 class="fw-bold mb-2">Delete Assignment?</h4>
                                <p class="text-muted mb-4 small">Are you sure you want to delete this assignment and ALL student submissions? This cannot be undone.</p>
                                <div class="d-flex justify-content-center gap-2 flex-wrap">
                                    <button type="button" class="btn btn-light px-3 fw-bold" data-bs-dismiss="modal">Cancel</button>
                                    <asp:Button ID="btnConfirmDeleteAssignment" runat="server" Text="Yes, Delete" CssClass="btn btn-danger px-3 fw-bold" OnClick="btnConfirmDeleteAssignment_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="ddlSort" EventName="SelectedIndexChanged" />
                <asp:PostBackTrigger ControlID="btnSaveAssignment" />
                <asp:PostBackTrigger ControlID="btnUpdateAssignment" />
            </Triggers>
        </asp:UpdatePanel>

        <asp:UpdatePanel runat="server" ID="upnlGradeModal">
            <ContentTemplate>
                <div id="customGradingOverlay" class="custom-grading-overlay">
                    <div class="custom-grading-modal">
                        <div class="custom-grading-header">
                            <div>
                                <h4 class="mb-0 fw-bold text-dark"><i class="fas fa-clipboard-check text-success me-2"></i> Evaluation Dashboard</h4>
                                <span class="text-muted small">Enter marks, leave feedback, and publish results to students.</span>
                            </div>
                            <button type="button" class="btn-close" onclick="closeGradingDashboard()"></button>
                        </div>
                        <div class="custom-grading-body">
                            <asp:HiddenField ID="hfGradingAssignmentId" runat="server" />
                            <asp:GridView ID="gvGrades" runat="server" AutoGenerateColumns="False" CssClass="custom-grade-table" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="student_code" HeaderText="ID" ItemStyle-Width="100px" />
                                    <asp:BoundField DataField="student_name" HeaderText="Student Name" ItemStyle-Font-Bold="true" />
                                    <asp:TemplateField HeaderText="Status"><ItemTemplate><%# GetSubmissionStatus(Eval("submitted_at"), Eval("due_date")) %></ItemTemplate></asp:TemplateField>
                                    <asp:TemplateField HeaderText="Submitted Work"><ItemTemplate><%# GetFileLink(Eval("submission_file"), Eval("student_name")) %></ItemTemplate></asp:TemplateField>
                                    <asp:TemplateField HeaderText="Marks">
                                        <ItemTemplate>
                                            <asp:HiddenField ID="hfStudentId" runat="server" Value='<%# Eval("student_id") %>' />
                                            <asp:TextBox ID="txtMarks" runat="server" CssClass="form-control text-center" Text='<%# Eval("marks_awarded") %>' Width="80px" placeholder="--"></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Feedback / Remarks">
                                        <ItemTemplate><asp:TextBox ID="txtFeedback" runat="server" CssClass="form-control" Text='<%# Eval("feedback") %>' placeholder="Optional feedback..."></asp:TextBox></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Publish?" ItemStyle-Width="80px" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate><asp:CheckBox ID="chkPublished" runat="server" Checked='<%# Eval("is_published") != DBNull.Value ? Convert.ToBoolean(Eval("is_published")) : false %>' CssClass="form-check-input" style="transform: scale(1.3);" /></ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                        <div class="custom-grading-footer gap-2">
                            <button type="button" class="btn btn-light px-4 border fw-bold" onclick="closeGradingDashboard()">Cancel</button>
                            <asp:Button ID="btnSaveGrades" runat="server" Text="Save & Update All" CssClass="btn btn-success px-4 fw-bold" OnClick="btnSaveGrades_Click" />
                        </div>
                    </div>
                </div>
            </ContentTemplate>
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
        // Checkmark Logic for File Upload
        function updateFileName(input, displayId, iconId) {
            var display = document.getElementById(displayId);
            var icon = document.getElementById(iconId);
            if (input.files && input.files.length > 0) {
                display.innerText = input.files[0].name;
                display.classList.remove('text-secondary'); display.classList.add('text-success');
                icon.classList.remove('fa-cloud-upload-alt', 'text-primary'); icon.classList.add('fa-check-circle', 'text-success');
            } else {
                display.innerText = 'Select Guideline File (Optional)';
                display.classList.remove('text-success'); display.classList.add('text-secondary');
                icon.classList.remove('fa-check-circle', 'text-success'); icon.classList.add('fa-cloud-upload-alt', 'text-primary');
            }
        }

        // Delete Modal Logic
        function showDeleteConfirmModal(assignmentId) {
            document.getElementById('hfDeleteAssignmentId').value = assignmentId;
            var deleteModal = new bootstrap.Modal(document.getElementById('deleteConfirmModal'));
            deleteModal.show();
        }

        // Grading Dashboard Controls
        function openGradingDashboard() { document.getElementById('customGradingOverlay').style.display = 'flex'; }
        function closeGradingDashboard() { document.getElementById('customGradingOverlay').style.display = 'none'; }

        // Black File Previewer Controls
        function openCustomPreview(fileUrl, fileTitle) {
            document.getElementById('customPreviewTitle').innerText = fileTitle;
            const ext = fileUrl.split('.').pop().toLowerCase();
            const container = document.getElementById('customPreviewContainer');

            container.innerHTML = '';

            if (ext === 'pdf' || ext === 'txt') {
                container.innerHTML = `<object data="${fileUrl}" type="application/pdf" width="100%" height="100%" style="display: block; border: none;"><iframe src="${fileUrl}" width="100%" height="100%" style="border: none;">Preview Unavailable</iframe></object>`;
            }
            else if (ext === 'jpg' || ext === 'png' || ext === 'jpeg') {
                container.innerHTML = `<div style="display: flex; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #212529;"><img src="${fileUrl}" style="max-width: 95%; max-height: 95%; object-fit: contain; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" /></div>`;
            }
            // THE FAKE DOCX SCREEN
            else if (ext === 'docx' || ext === 'doc') {
                container.innerHTML = `
                    <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%; height: 100%; background-color: #f8f9fa;">
                        <i class="fas fa-file-word text-primary mb-3" style="font-size: 70px;"></i>
                        <h3 class="fw-bold text-dark">File submitted in .docx format so it can't be previewed.</h3>
                        <p class="text-muted mt-2">Please download the file to review the submission.</p>
                        <a href="${fileUrl}" target="_blank" class="btn btn-primary px-4 mt-3 shadow-sm"><i class="fas fa-download me-2"></i> Download File</a>
                    </div>`;
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