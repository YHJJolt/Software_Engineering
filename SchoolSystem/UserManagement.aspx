<%@ Page Title="User Management" Language="C#" MasterPageFile="~/AdminMaster.Master"
    AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="SchoolSystem.UserManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Admin.css" rel="stylesheet" type="text/css" />
    
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="user-mgmt-page">
    <div class="header"><h1><i class="fas fa-users"></i>User Management</h1></div>

    <asp:HiddenField ID="hfReopenModal"  runat="server" />
    <asp:HiddenField ID="hfActiveTab"    runat="server" Value="students" />
    <asp:HiddenField ID="hfViewType"     runat="server" />
    <asp:HiddenField ID="hfViewCode"     runat="server" />
    <asp:HiddenField ID="hfViewName"     runat="server" />
    <asp:HiddenField ID="hfViewEmail"    runat="server" />
    <asp:HiddenField ID="hfViewContact"  runat="server" />
    <asp:HiddenField ID="hfViewAddr"     runat="server" />
    <asp:HiddenField ID="hfViewDOB"      runat="server" />
    <asp:HiddenField ID="hfViewExtra1"   runat="server" />
    <asp:HiddenField ID="hfViewExtra2"   runat="server" />
    <asp:HiddenField ID="hfViewStatus"   runat="server" />
    <asp:HiddenField ID="hfNextStudId"   runat="server" />
    <asp:HiddenField ID="hfNextLectId"   runat="server" />
    <asp:HiddenField ID="hfToastMsg"     runat="server" />
    <asp:HiddenField ID="hfToastType"    runat="server" />

    <asp:Literal ID="litDropdownData" runat="server" />
    <div id="umToast" class="um-toast"></div>


    <div class="row mb-4 g-3">
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="stat-lbl" id="lblBox2">Total Students</div>
                <div class="stat-num c-yellow">
                    <asp:Label ID="lblTotalStudents"  runat="server">0</asp:Label>
                    <asp:Label ID="lblTotalLecturers" runat="server" style="display:none;">0</asp:Label>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="stat-lbl" id="lblBox3">Active Students</div>
                <div class="stat-num c-green">
                    <asp:Label ID="lblActiveStudents"  runat="server">0</asp:Label>
                    <asp:Label ID="lblActiveLecturers" runat="server" style="display:none;">0</asp:Label>
                </div>
            </div>
        </div>
        <div class="col-md-4 col-6">
            <div class="stat-box">
                <div class="stat-lbl" id="lblBox4">Inactive Students</div>
                <div class="stat-num c-red-stat">
                    <asp:Label ID="lblInactiveStudents"  runat="server">0</asp:Label>
                    <asp:Label ID="lblInactiveLecturers" runat="server" style="display:none;">0</asp:Label>
                </div>
            </div>
        </div>
    </div>

    <ul class="nav nav-tabs mb-3" id="umTabs">
        <li class="nav-item"><a class="nav-link<%=hfActiveTab.Value=="students"?" active":"" %>" data-bs-toggle="tab" href="#tabStudents" onclick="swapStats('students')">Students</a></li>
        <li class="nav-item"><a class="nav-link<%=hfActiveTab.Value=="lecturers"?" active":"" %>" data-bs-toggle="tab" href="#tabLecturers" onclick="swapStats('lecturers')">Lecturers</a></li>
    </ul>

    <div class="tab-content">

        <%-- ══ STUDENTS TAB ══ --%>
        <div class="tab-pane fade<%=hfActiveTab.Value=="students"?" show active":"" %>" id="tabStudents">
            <div class="d-flex justify-content-between mb-3 flex-wrap gap-2">
                <div class="search-row">
                    <input type="text" id="txtSrchStud" class="form-control" placeholder="Search Code, Name, Email…" style="width:240px;font-size:13px;" oninput="filterStudents()" />
                    <select id="ddlProgFilter" class="form-select w-auto" style="font-size:13px;" onchange="filterStudents()"><option value="">All Programs</option></select>
                    <select id="ddlStudStatus" class="form-select w-auto" style="font-size:13px;" onchange="filterStudents()">
                        <option value="">All Status</option><option value="Active">Active</option><option value="Inactive">Inactive</option>
                    </select>
                    <%-- Sort --%>
                </div>
                <div class="d-flex gap-2 align-items-center">
                    <%-- Sort funnel button + panel --%>
                    <div class="position-relative">
                        <button type="button" class="btn btn-outline-secondary" id="btnStudSort" onclick="toggleSortPanel('studSortPanel')" title="Sort">
                            <i class="fas fa-filter"></i>
                        </button>
                        <div id="studSortPanel" class="sort-panel" style="display:none;">
                            <div class="sort-group-lbl">Code</div>
                            <button class="sort-opt" onclick="pickSort('studSortPanel','ddlStudSort','code-asc',this)">Ascending</button>
                            <button class="sort-opt" onclick="pickSort('studSortPanel','ddlStudSort','code-desc',this)">Descending</button>
                            <div class="sort-group-lbl mt-2">Name</div>
                            <button class="sort-opt" onclick="pickSort('studSortPanel','ddlStudSort','name-asc',this)">A → Z</button>
                            <button class="sort-opt" onclick="pickSort('studSortPanel','ddlStudSort','name-desc',this)">Z → A</button>
                        </div>
                        <input type="hidden" id="ddlStudSort" value="code-asc" />
                    </div>
                    <button type="button" class="btn btn-dark" data-bs-toggle="modal" data-bs-target="#modalAddStudent"><i class="fas fa-plus"></i> Add Student</button>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvStudents" runat="server" CssClass="table table-hover align-middle"
                    AutoGenerateColumns="false" OnRowCommand="gvStudents_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="student_code"    HeaderText="Code" />
                        <asp:BoundField DataField="student_name"    HeaderText="Name" />
                        <asp:BoundField DataField="student_email"   HeaderText="Email" />
                        <asp:BoundField DataField="student_contact" HeaderText="Contact" NullDisplayText="N/A" />
                        <asp:BoundField DataField="program_name"    HeaderText="Program" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# Eval("student_isactive").ToString()=="Active"?"bg-success":"bg-danger" %>'><%# Eval("student_isactive") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CssClass="act-icon c-blue" CommandName="ViewS" CommandArgument='<%# Eval("student_id") %>' ToolTip="View"><i class="fas fa-eye"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="act-icon c-org" CommandName="Toggle" CommandArgument='<%# Eval("student_id") %>'
                                    ToolTip='<%# Eval("student_isactive").ToString()=="Active"?"Deactivate":"Activate" %>'
                                    OnClientClick='<%# "return confirmToggle(\""+Eval("student_name")+"\",\""+Eval("student_code")+"\",\""+Eval("student_isactive")+"\");" %>'>
                                    <i class='<%# Eval("student_isactive").ToString()=="Active"?"fas fa-toggle-on":"fas fa-toggle-off" %>'></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="act-icon c-red" CommandName="DeleteS" CommandArgument='<%# Eval("student_id") %>'
                                    ToolTip="Delete" OnClientClick='<%# "return confirmDelete(\""+Eval("student_name")+"\",\""+Eval("student_code")+"\",\"student\");" %>'>
                                    <i class="fas fa-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <%-- ══ LECTURERS TAB ══ --%>
        <div class="tab-pane fade<%=hfActiveTab.Value=="lecturers"?" show active":"" %>" id="tabLecturers">
            <div class="d-flex justify-content-between mb-3 flex-wrap gap-2">
                <div class="search-row">
                    <input type="text" id="txtSrchLect" class="form-control" placeholder="Search Code, Name, Email…" style="width:240px;font-size:13px;" oninput="filterLecturers()" />
                    <select id="ddlDeptFilter" class="form-select w-auto" style="font-size:13px;" onchange="filterLecturers()"><option value="">All Departments</option></select>
                    <select id="ddlLectStatus" class="form-select w-auto" style="font-size:13px;" onchange="filterLecturers()">
                        <option value="">All Status</option><option value="Active">Active</option><option value="Inactive">Inactive</option>
                    </select>
                    <%-- Sort --%>
                </div>
                <div class="d-flex gap-2 align-items-center">
                    <div class="position-relative">
                        <button type="button" class="btn btn-outline-secondary" id="btnLectSort" onclick="toggleSortPanel('lectSortPanel')" title="Sort">
                            <i class="fas fa-filter"></i>
                        </button>
                        <div id="lectSortPanel" class="sort-panel" style="display:none;">
                            <div class="sort-group-lbl">Code</div>
                            <button class="sort-opt" onclick="pickSort('lectSortPanel','ddlLectSort','code-asc',this)"><i class="fas fa-arrow-up me-1"></i>Ascending</button>
                            <button class="sort-opt" onclick="pickSort('lectSortPanel','ddlLectSort','code-desc',this)"><i class="fas fa-arrow-down me-1"></i>Descending</button>
                            <div class="sort-group-lbl mt-2">Name</div>
                            <button class="sort-opt" onclick="pickSort('lectSortPanel','ddlLectSort','name-asc',this)"><i class="fas fa-arrow-up me-1"></i>A → Z</button>
                            <button class="sort-opt" onclick="pickSort('lectSortPanel','ddlLectSort','name-desc',this)"><i class="fas fa-arrow-down me-1"></i>Z → A</button>
                        </div>
                        <input type="hidden" id="ddlLectSort" value="code-asc" />
                    </div>
                    <button type="button" class="btn btn-dark" data-bs-toggle="modal" data-bs-target="#modalAddLecturer"><i class="fas fa-plus"></i> Add Lecturer</button>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="gvLecturers" runat="server" CssClass="table table-hover align-middle"
                    AutoGenerateColumns="false" OnRowCommand="gvLecturers_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="lecturer_code"        HeaderText="Code" />
                        <asp:BoundField DataField="lecturer_name"        HeaderText="Name" />
                        <asp:BoundField DataField="lecturer_email"       HeaderText="Email" />
                        <asp:BoundField DataField="lecturer_contact"     HeaderText="Contact" NullDisplayText="N/A" />
                        <asp:BoundField DataField="lecturer_department"  HeaderText="Department" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='badge <%# Eval("teacher_isactive").ToString()=="Active"?"bg-success":"bg-danger" %>'><%# Eval("teacher_isactive") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CssClass="act-icon c-blue" CommandName="ViewL" CommandArgument='<%# Eval("lecturer_id") %>' ToolTip="View"><i class="fas fa-eye"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="act-icon c-org" CommandName="Toggle" CommandArgument='<%# Eval("lecturer_id") %>'
                                    ToolTip='<%# Eval("teacher_isactive").ToString()=="Active"?"Deactivate":"Activate" %>'
                                    OnClientClick='<%# "return confirmToggle(\""+Eval("lecturer_name")+"\",\""+Eval("lecturer_code")+"\",\""+Eval("teacher_isactive")+"\");" %>'>
                                    <i class='<%# Eval("teacher_isactive").ToString()=="Active"?"fas fa-toggle-on":"fas fa-toggle-off" %>'></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CssClass="act-icon c-red" CommandName="DeleteL" CommandArgument='<%# Eval("lecturer_id") %>'
                                    ToolTip="Delete" OnClientClick='<%# "return confirmDelete(\""+Eval("lecturer_name")+"\",\""+Eval("lecturer_code")+"\",\"lecturer\");" %>'>
                                    <i class="fas fa-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>

    <%-- ══ MODAL: ADD STUDENT ══ --%>
    <div class="modal fade" id="modalAddStudent" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>Add New Student</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:12px;">Full Name <span style="color:#dc2626">*</span></label>
                            <asp:TextBox ID="txtStudName" runat="server" CssClass="form-control" Placeholder="e.g. John Doe" oninput="onStudNameInput()" />
                            <div id="errStudName" class="text-danger mt-1" style="font-size:12px;display:none;">Please enter full name</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Email <span style="color:#dc2626">*</span></label>
                            <asp:TextBox ID="txtStudEmail" runat="server" CssClass="form-control bg-light" ReadOnly="true" Placeholder="e.g. johndoe0001@stud.com" />
                            <div class="form-text" style="font-size:11px;">Auto-generated. Cannot be edited.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Password <span style="color:#dc2626">*</span></label>
                            <div class="pw-wrapper">
                                <asp:TextBox ID="txtStudPassword" runat="server" CssClass="form-control bg-light" ReadOnly="true" />
                                <button type="button" class="pw-toggle" onclick="togglePw('<%=txtStudPassword.ClientID%>',this)"><i class="fas fa-eye"></i></button>
                            </div>
                            <div class="form-text" style="font-size:11px;">Default setting. Cannot be edited.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Phone Number <span style="color:#6c757d;font-weight:400;">(Optional)</span></label>
                            <asp:TextBox ID="txtStudContact" runat="server" CssClass="form-control" Placeholder="e.g. 017-1234567" oninput="phoneMask(this)" maxlength="12" />
                            <div id="errStudContact" class="text-danger mt-1" style="font-size:12px;display:none;">Must start with 01 (e.g. 017-1234567)</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Semester <span style="color:#dc2626">*</span></label>
                            <asp:TextBox ID="txtStudSem" runat="server" CssClass="form-control" Text="1" TextMode="Number" />
                            <div id="errStudSem" class="text-danger mt-1" style="font-size:12px;display:none;">Semester must be between 1 and 12</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Program <span style="color:#dc2626">*</span></label>
                            <asp:DropDownList ID="ddlProgramAdd" runat="server" CssClass="form-select" onchange="onProgChange(this)" />
                            <div id="errStudProg" class="text-danger mt-1" style="font-size:12px;display:none;">Please select a program</div>
                        </div>
                    </div>
                    <asp:Label ID="lblStudErr" runat="server" CssClass="text-danger mt-2 d-block fw-semibold" style="font-size:13px;" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" onclick="clearStudForm()">Clear</button>
                    <asp:Button ID="btnAddStudent" runat="server" CssClass="btn btn-dark" Text="Add Student" OnClick="btnAddStudent_Click" OnClientClick="return validateStudForm();" />
                </div>
            </div>
        </div>
    </div>

    <%-- ══ MODAL: ADD LECTURER ══ --%>
    <div class="modal fade" id="modalAddLecturer" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-chalkboard-teacher me-2"></i>Add New Lecturer</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label fw-semibold" style="font-size:12px;">Full Name <span style="color:#dc2626">*</span></label>
                            <asp:TextBox ID="txtLectName" runat="server" CssClass="form-control" Placeholder="e.g. Alan Turing" oninput="onLectNameInput()" />
                            <div id="errLectName" class="text-danger mt-1" style="font-size:12px;display:none;">Please enter full name</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Email <span style="color:#dc2626">*</span></label>
                            <asp:TextBox ID="txtLectEmail" runat="server" CssClass="form-control bg-light" ReadOnly="true" Placeholder="e.g. alanturing0001@lect.com" />
                            <div class="form-text" style="font-size:11px;">Auto-generated. Cannot be edited.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Password <span style="color:#dc2626">*</span></label>
                            <div class="pw-wrapper">
                                <asp:TextBox ID="txtLectPassword" runat="server" CssClass="form-control bg-light" ReadOnly="true" />
                                <button type="button" class="pw-toggle" onclick="togglePw('<%=txtLectPassword.ClientID%>',this)"><i class="fas fa-eye"></i></button>
                            </div>
                            <div class="form-text" style="font-size:11px;">Default setting. Cannot be edited.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Phone Number <span style="color:#6c757d;font-weight:400;">(Optional)</span></label>
                            <asp:TextBox ID="txtLectContact" runat="server" CssClass="form-control" Placeholder="e.g. 012-3456789" oninput="phoneMask(this)" maxlength="12" />
                            <div id="errLectContact" class="text-danger mt-1" style="font-size:12px;display:none;">Must start with 01 (e.g. 012-3456789)</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold" style="font-size:12px;">Department <span style="color:#dc2626">*</span></label>
                            <asp:DropDownList ID="ddlLectDept" runat="server" CssClass="form-select" style="color:#6c757d;" onchange="onDeptChange(this)">
                                <asp:ListItem Value="">- Select a department -</asp:ListItem>
                                <asp:ListItem Value="School of Computing">School of Computing</asp:ListItem>
                                <asp:ListItem Value="School of Business">School of Business</asp:ListItem>
                                <asp:ListItem Value="School of Design">School of Design</asp:ListItem>
                            </asp:DropDownList>
                            <div id="errLectDept" class="text-danger mt-1" style="font-size:12px;display:none;">Please select a department</div>
                        </div>
                    </div>
                    <asp:Label ID="lblLectErr" runat="server" CssClass="text-danger mt-2 d-block fw-semibold" style="font-size:13px;" />
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" onclick="clearLectForm()">Clear</button>
                    <asp:Button ID="btnAddLecturer" runat="server" CssClass="btn btn-dark" Text="Add Lecturer" OnClick="btnAddLecturer_Click" OnClientClick="return validateLectForm();" />
                </div>
            </div>
        </div>
    </div>

    <%-- ══ VIEW DETAIL OVERLAY ══ --%>
    <div id="viewOverlay" class="view-overlay" onclick="closeViewOverlay(event)">
        <div class="view-card" onclick="event.stopPropagation()">
            <div class="view-card-header">
                <h5 id="viewCardTitle">Details</h5>
                <button type="button" class="btn-close" onclick="document.getElementById('viewOverlay').classList.remove('show')"></button>
            </div>
            <div class="view-card-body" id="viewCardBody"></div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // @ts-nocheck
        function showToast(msg, type) { var t = document.getElementById('umToast'); t.textContent = msg; t.className = 'um-toast ' + (type || 'success'); t.classList.add('show'); setTimeout(function () { t.classList.remove('show'); }, 3200); }

        function initProgDropdown() {
            var sel = document.getElementById('<%=ddlProgramAdd.ClientID%>');
            if (!sel) return;
            if (sel.options.length > 0 && sel.options[0].value === '') { sel.options[0].disabled = true; sel.options[0].style.display = 'none'; }
            sel.style.color = sel.value ? '#212529' : '#6c757d';
        }
        function onProgChange(sel) {
            sel.style.color = sel.value ? '#212529' : '#6c757d';
            var err = document.getElementById('errStudProg');
            if (err && sel.value) err.style.display = 'none';
            sel.classList.toggle('is-invalid', !sel.value);
        }
        function onDeptChange(sel) {
            sel.style.color = sel.value ? '#212529' : '#6c757d';
            var err = document.getElementById('errLectDept');
            if (err && sel.value) err.style.display = 'none';
            sel.classList.toggle('is-invalid', !sel.value);
        }

        function phoneMask(el) {
            var raw = el.value.replace(/\D/g, '');
            if (raw.length > 0 && raw[0] !== '0') raw = '0' + raw;
            if (raw.length > 1 && raw[1] !== '1') raw = raw[0] + '1' + raw.substring(2);
            if (raw.length > 11) raw = raw.substring(0, 11);
            el.value = raw.length > 3 ? raw.substring(0, 3) + '-' + raw.substring(3) : raw;
        }

        function toTitleCaseStr(s) { return s.replace(/\b\w/g, function (c) { return c.toUpperCase(); }); }
        function toTitleCase(el) { var pos = el.selectionStart; el.value = toTitleCaseStr(el.value); try { el.setSelectionRange(pos, pos); } catch (e) { } }

        function buildEmail(name, id, domain) {
            var clean = name.trim().toLowerCase().replace(/\s+/g, '').replace(/[^a-z0-9]/g, '');
            if (!clean) clean = 'user';
            return clean + String(id).padStart(4, '0') + '@' + domain;
        }
        function onStudNameInput() {
            var n = document.getElementById('<%=txtStudName.ClientID%>');
            var e = document.getElementById('<%=txtStudEmail.ClientID%>');
            var id = document.getElementById('<%=hfNextStudId.ClientID%>').value || '1';
            toTitleCase(n);
            e.value = n.value ? buildEmail(n.value, id, 'stud.com') : '';
        }
        function onLectNameInput() {
            var n = document.getElementById('<%=txtLectName.ClientID%>');
            var e = document.getElementById('<%=txtLectEmail.ClientID%>');
            var id = document.getElementById('<%=hfNextLectId.ClientID%>').value || '1';
            toTitleCase(n);
            e.value = n.value ? buildEmail(n.value, id, 'lect.com') : '';
        }

        function togglePw(id, btn) {
            var el = document.getElementById(id); if (!el) return;
            var show = (el.type === 'text');
            el.type = show ? 'password' : 'text';
            btn.querySelector('i').className = show ? 'fas fa-eye' : 'fas fa-eye-slash';
        }

        function chk(fieldId, errId, testFn) {
            var el = document.getElementById(fieldId);
            var err = document.getElementById(errId);
            var val = el ? el.value.trim() : '';
            var fail = !testFn(val);
            if (err) err.style.display = fail ? 'block' : 'none';
            if (el) el.classList.toggle('is-invalid', fail);
            return !fail;
        }
        function validateOptionalPhone(fieldId, errId) {
            var el = document.getElementById(fieldId);
            var err = document.getElementById(errId);
            var val = el ? el.value.trim() : '';
            if (!val) { if (err) err.style.display = 'none'; if (el) el.classList.remove('is-invalid'); return true; }
            var fail = !/^01\d-\d{7,8}$/.test(val);
            if (err) err.style.display = fail ? 'block' : 'none';
            if (el) el.classList.toggle('is-invalid', fail);
            return !fail;
        }
        function validateStudForm() {
            var ok = true;
            ok = chk('<%=txtStudName.ClientID%>', 'errStudName', function (v) { return v.length > 0; }) && ok;
            ok = validateOptionalPhone('<%=txtStudContact.ClientID%>', 'errStudContact') && ok;
            var semEl = document.getElementById('<%=txtStudSem.ClientID%>');
            var semVal = semEl ? parseInt(semEl.value) : 0;
            var semFail = isNaN(semVal) || semVal < 1 || semVal > 12;
            var semErr = document.getElementById('errStudSem');
            if (semErr) semErr.style.display = semFail ? 'block' : 'none';
            if (semEl) semEl.classList.toggle('is-invalid', semFail);
            if (semFail) ok = false;
            var progEl = document.getElementById('<%=ddlProgramAdd.ClientID%>');
            var progFail = !progEl || !progEl.value;
            var progErr = document.getElementById('errStudProg');
            if (progErr) progErr.style.display = progFail ? 'block' : 'none';
            if (progEl) progEl.classList.toggle('is-invalid', progFail);
            if (progFail) ok = false;
            return ok;
        }
        function validateLectForm() {
            var ok = true;
            ok = chk('<%=txtLectName.ClientID%>', 'errLectName', function (v) { return v.length > 0; }) && ok;
            ok = validateOptionalPhone('<%=txtLectContact.ClientID%>', 'errLectContact') && ok;
            var deptEl = document.getElementById('<%=ddlLectDept.ClientID%>');
            var deptFail = !deptEl || !deptEl.value;
            var deptErr = document.getElementById('errLectDept');
            if (deptErr) deptErr.style.display = deptFail ? 'block' : 'none';
            if (deptEl) deptEl.classList.toggle('is-invalid', deptFail);
            if (deptFail) ok = false;
            return ok;
        }

        function clearStudForm() {
            ['<%=txtStudName.ClientID%>','<%=txtStudContact.ClientID%>']
            .forEach(function(id){var e=document.getElementById(id);if(e){e.value='';e.classList.remove('is-invalid');}});
        var s=document.getElementById('<%=txtStudSem.ClientID%>');if(s){s.value='1';s.classList.remove('is-invalid');}
        document.getElementById('<%=txtStudEmail.ClientID%>').value='';
        var p=document.getElementById('<%=ddlProgramAdd.ClientID%>');
        if(p){p.value='';p.style.color='#6c757d';p.classList.remove('is-invalid');}
        ['errStudName','errStudContact','errStudSem','errStudProg']
            .forEach(function(id){var e=document.getElementById(id);if(e)e.style.display='none';});
        var err=document.getElementById('<%=lblStudErr.ClientID%>');if(err)err.textContent='';
    }
    function clearLectForm(){
        ['<%=txtLectName.ClientID%>','<%=txtLectContact.ClientID%>']
            .forEach(function(id){var e=document.getElementById(id);if(e){e.value='';e.classList.remove('is-invalid');}});
        document.getElementById('<%=txtLectEmail.ClientID%>').value='';
        var d=document.getElementById('<%=ddlLectDept.ClientID%>');
        if(d){d.value='';d.style.color='#6c757d';d.classList.remove('is-invalid');}
        ['errLectName','errLectContact','errLectDept']
            .forEach(function(id){var e=document.getElementById(id);if(e)e.style.display='none';});
        var err=document.getElementById('<%=lblLectErr.ClientID%>');if(err)err.textContent='';
    }

    function confirmDelete(name,code,type){return confirm('Permanently delete '+type+'?\n\nName : '+name+'\nCode : '+code+'\n\nThis cannot be undone');}
    function confirmToggle(name,code,status){
        var a=status==='Active'?'DEACTIVATE':'ACTIVATE';
        var n=status==='Active'?'User will no longer be able to log in':'User will be able to log in again';
        return confirm(a+' user?\n\nName : '+name+'\nCode : '+code+'\n\n'+n);
    }

    function swapStats(tab){
        var s=(tab==='students');
        document.getElementById('lblBox2').textContent=s?'Total Students':'Total Lecturers';
        document.getElementById('lblBox3').textContent=s?'Active Students':'Active Lecturers';
        document.getElementById('lblBox4').textContent=s?'Inactive Students':'Inactive Lecturers';
        document.getElementById('<%=lblTotalStudents.ClientID%>').style.display=s?'':'none';
        document.getElementById('<%=lblActiveStudents.ClientID%>').style.display=s?'':'none';
        document.getElementById('<%=lblInactiveStudents.ClientID%>').style.display=s?'':'none';
        document.getElementById('<%=lblTotalLecturers.ClientID%>').style.display=s?'none':'';
        document.getElementById('<%=lblActiveLecturers.ClientID%>').style.display=s?'none':'';
        document.getElementById('<%=lblInactiveLecturers.ClientID%>').style.display=s?'none':'';
    }

    function populateDropdowns(){
        if(typeof _progData!=='undefined'&&_progData){
            var sel=document.getElementById('ddlProgFilter');
            while(sel.options.length>1)sel.remove(1);
            _progData.split('||').forEach(function(item){var p=item.split('|');if(p.length===2)sel.add(new Option(p[1],p[1]));});
        }
        if(typeof _deptData!=='undefined'&&_deptData){
            var sel2=document.getElementById('ddlDeptFilter');
            while(sel2.options.length>1)sel2.remove(1);
            _deptData.split('||').forEach(function(v){if(v)sel2.add(new Option(v,v));});
        }
    }

    function updateNoResults(tableId){
        var table=document.getElementById(tableId);
        if(!table)return;
        table.style.display='';
        var tbody=table.querySelector('tbody');if(!tbody)return;
        var old=tbody.querySelector('.no-results-row');
        var vis=Array.from(tbody.querySelectorAll('tr:not(.no-results-row)')).filter(function(r){return r.style.display!=='none';});
        if(vis.length===0){
            if(!old){var tr=document.createElement('tr');tr.className='no-results-row';var td=document.createElement('td');td.colSpan=99;td.innerHTML='<i class="fas fa-search me-2"></i>No results found';tr.appendChild(td);tbody.appendChild(tr);}
        } else {if(old)old.remove();}
    }

    function saveFilters(){
        sessionStorage.setItem('sf_stud_search',document.getElementById('txtSrchStud').value);
        sessionStorage.setItem('sf_stud_prog',  document.getElementById('ddlProgFilter').value);
        sessionStorage.setItem('sf_stud_status',document.getElementById('ddlStudStatus').value);
        sessionStorage.setItem('sf_stud_sort',  document.getElementById('ddlStudSort').value);
        sessionStorage.setItem('sf_lect_search',document.getElementById('txtSrchLect').value);
        sessionStorage.setItem('sf_lect_dept',  document.getElementById('ddlDeptFilter').value);
        sessionStorage.setItem('sf_lect_status',document.getElementById('ddlLectStatus').value);
        sessionStorage.setItem('sf_lect_sort',  document.getElementById('ddlLectSort').value);
    }
    function restoreFilters(){
        var ss=sessionStorage.getItem('sf_stud_search'),sp=sessionStorage.getItem('sf_stud_prog'),st=sessionStorage.getItem('sf_stud_status'),sso=sessionStorage.getItem('sf_stud_sort');
        var ls=sessionStorage.getItem('sf_lect_search'),ld=sessionStorage.getItem('sf_lect_dept'), lt=sessionStorage.getItem('sf_lect_status'),lso=sessionStorage.getItem('sf_lect_sort');
        if(ss)document.getElementById('txtSrchStud').value=ss;
        if(sp)document.getElementById('ddlProgFilter').value=sp;
        if(st)document.getElementById('ddlStudStatus').value=st;
        if(sso)document.getElementById('ddlStudSort').value=sso;
        if(ls)document.getElementById('txtSrchLect').value=ls;
        if(ld)document.getElementById('ddlDeptFilter').value=ld;
        if(lt)document.getElementById('ddlLectStatus').value=lt;
        if(lso)document.getElementById('ddlLectSort').value=lso;
        if(ss||sp||st)filterStudents();
        if(ls||ld||lt)filterLecturers();
    }

    function filterStudents(){
        var search=document.getElementById('txtSrchStud').value.toLowerCase();
        var prog=document.getElementById('ddlProgFilter').value.toLowerCase();
        var status=document.getElementById('ddlStudStatus').value.toLowerCase();
        var gvId='<%=gvStudents.ClientID%>';
        var table=document.getElementById(gvId);if(!table)return;
        table.style.display='';
        document.querySelectorAll('#'+gvId+' tbody tr').forEach(function(row){
            var c=row.cells;if(!c||c.length<6)return;
            var ms=!search||[0,1,2].some(function(i){return c[i].textContent.trim().toLowerCase().includes(search);});
            var mp=!prog||c[4].textContent.trim().toLowerCase().includes(prog);
            var mt=!status||c[5].textContent.trim().toLowerCase()===status;
            row.style.display=(ms&&mp&&mt)?'':'none';
        });
        updateNoResults(gvId);saveFilters();
    }
    function filterLecturers(){
        var search=document.getElementById('txtSrchLect').value.toLowerCase();
        var dept=document.getElementById('ddlDeptFilter').value.toLowerCase();
        var status=document.getElementById('ddlLectStatus').value.toLowerCase();
        var gvId='<%=gvLecturers.ClientID%>';
        var table=document.getElementById(gvId);if(!table)return;
        table.style.display='';
        document.querySelectorAll('#'+gvId+' tbody tr').forEach(function(row){
            var c=row.cells;if(!c||c.length<6)return;
            var ms=!search||[0,1,2].some(function(i){return c[i].textContent.trim().toLowerCase().includes(search);});
            var mp=!dept||c[4].textContent.trim().toLowerCase().includes(dept);
            var mt=!status||c[5].textContent.trim().toLowerCase()===status;
            row.style.display=(ms&&mp&&mt)?'':'none';
        });
        updateNoResults(gvId);saveFilters();
    }

    // ── Sort panel ───────────────────────────────────────────────────
    function toggleSortPanel(panelId){
        var p=document.getElementById(panelId);
        var all=['studSortPanel','lectSortPanel'];
        all.forEach(function(id){ if(id!==panelId){ var el=document.getElementById(id); if(el)el.style.display='none'; }});
        p.style.display=(p.style.display==='none'?'block':'none');
    }
    document.addEventListener('click',function(e){
        if(!e.target.closest('.position-relative')){ 
            ['studSortPanel','lectSortPanel'].forEach(function(id){ var el=document.getElementById(id); if(el)el.style.display='none'; });
        }
    });
    function pickSort(panelId,hidId,val,btn){
        // Mark active button
        document.querySelectorAll('#'+panelId+' .sort-opt').forEach(function(b){b.classList.remove('active');});
        btn.classList.add('active');
        document.getElementById(hidId).value=val;
        document.getElementById(panelId).style.display='none';
        if(hidId==='ddlStudSort') sortStudents();
        else sortLecturers();
        saveFilters();
    }
    function sortTable(gvId, colIdx, dir){
        var table=document.getElementById(gvId); if(!table)return;
        var tbody=table.querySelector('tbody'); if(!tbody)return;
        var rows=Array.from(tbody.querySelectorAll('tr:not(.no-results-row)')).filter(function(r){
            return r.querySelector('td') && !r.querySelector('th');
        });
        rows.sort(function(a,b){
            var av=a.cells[colIdx]?a.cells[colIdx].textContent.trim().toLowerCase():'';
            var bv=b.cells[colIdx]?b.cells[colIdx].textContent.trim().toLowerCase():'';
            return dir==='asc'?av.localeCompare(bv):bv.localeCompare(av);
        });
        var noRes=tbody.querySelector('.no-results-row');
        rows.forEach(function(r){
            if(noRes) tbody.insertBefore(r, noRes);
            else tbody.appendChild(r);
        });
    }
    function sortStudents(){
        var val=document.getElementById('ddlStudSort').value;
        sortTable('<%=gvStudents.ClientID%>',val.startsWith('name')?1:0,val.endsWith('asc')?'asc':'desc');
    }
    function sortLecturers(){
        var val=document.getElementById('ddlLectSort').value;
        sortTable('<%=gvLecturers.ClientID%>',val.startsWith('name')?1:0,val.endsWith('asc')?'asc':'desc');
    }

        // ── View card ───────────────────────────────────────────────────
    function showViewCard(){
        var vtype=document.getElementById('<%=hfViewType.ClientID%>').value;if(!vtype)return;
        var code=document.getElementById('<%=hfViewCode.ClientID%>').value;
        var name=document.getElementById('<%=hfViewName.ClientID%>').value;
        var email=document.getElementById('<%=hfViewEmail.ClientID%>').value;
        var contact=document.getElementById('<%=hfViewContact.ClientID%>').value;
        var addr=document.getElementById('<%=hfViewAddr.ClientID%>').value;
        var dob=document.getElementById('<%=hfViewDOB.ClientID%>').value;
        var e1=document.getElementById('<%=hfViewExtra1.ClientID%>').value;
        var e2=document.getElementById('<%=hfViewExtra2.ClientID%>').value;
        var status=document.getElementById('<%=hfViewStatus.ClientID%>').value;
        document.getElementById('viewCardTitle').textContent=vtype==='student'?'Student Details':'Lecturer Details';
        function r(lbl,val){return '<div class="view-row"><span class="view-lbl">'+lbl+'</span><span class="view-val">'+(val&&val.trim()&&val!=='-'?val:'N/A')+'</span></div>';}
        var badge='<span class="badge '+(status==='Active'?'bg-success':'bg-danger')+'">'+status+'</span>';
        var html=vtype==='student'
            ?r('Code',code)+r('Name',name)+r('Email',email)+r('Contact',contact)+r('Address',addr)+r('Date of Birth',dob)+r('Program',e1)+r('Semester',e2)+r('Status',badge)
            :r('Code',code)+r('Name',name)+r('Email',email)+r('Contact',contact)+r('Address',addr)+r('Date of Birth',dob)+r('Department',e1)+r('Status',badge);
        document.getElementById('viewCardBody').innerHTML=html;
        document.getElementById('viewOverlay').classList.add('show');
        document.getElementById('<%=hfViewType.ClientID%>').value='';
    }
    function closeViewOverlay(e){if(e.target===document.getElementById('viewOverlay'))document.getElementById('viewOverlay').classList.remove('show');}

    window.addEventListener('DOMContentLoaded',function(){
        populateDropdowns();
        restoreFilters();
        initProgDropdown();

        var deptSel=document.getElementById('<%=ddlLectDept.ClientID%>');
        if(deptSel){
            if(deptSel.options.length>0&&deptSel.options[0].value===''){
                deptSel.options[0].disabled=true;
                deptSel.options[0].style.display='none';
            }
            deptSel.style.color=deptSel.value?'#212529':'#6c757d';
        }

        var semEl=document.getElementById('<%=txtStudSem.ClientID%>');
        if(semEl){
            semEl.setAttribute('min','1');semEl.setAttribute('max','12');
            semEl.addEventListener('keydown',function(ev){if(ev.key==='-'||ev.key==='+'||ev.key==='e'||ev.key==='E')ev.preventDefault();});
            semEl.addEventListener('change',function(){var v=parseInt(this.value)||1;if(v<1)v=1;if(v>12)v=12;this.value=v;});
            semEl.addEventListener('blur',  function(){var v=parseInt(this.value)||1;if(v<1)v=1;if(v>12)v=12;this.value=v;});
        }

        var activeTab=document.getElementById('<%=hfActiveTab.ClientID%>').value||'students';
        swapStats(activeTab);

        var reopen=document.getElementById('<%=hfReopenModal.ClientID%>').value;
        if(reopen==='addStudent')  new bootstrap.Modal(document.getElementById('modalAddStudent')).show();
        if(reopen==='addLecturer') new bootstrap.Modal(document.getElementById('modalAddLecturer')).show();

        var tmsg=document.getElementById('<%=hfToastMsg.ClientID%>').value;
        var ttype=document.getElementById('<%=hfToastType.ClientID%>').value;
        if(tmsg)showToast(tmsg,ttype||'success');

        showViewCard();

        sortStudents();
        sortLecturers();
    });

    var addStudModal=document.getElementById('modalAddStudent');
    if(addStudModal)addStudModal.addEventListener('shown.bs.modal',function(){initProgDropdown();});

    document.querySelectorAll('#umTabs a').forEach(function(el){
        el.addEventListener('shown.bs.tab',function(e){
            var tab=e.target.getAttribute('href').replace('#tab','').toLowerCase();
            sessionStorage.setItem('umTab',tab);
            document.getElementById('<%=hfActiveTab.ClientID%>').value = tab;
            swapStats(tab);
        });
    });

    </script>
    </div>
</asp:Content>