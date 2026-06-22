using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SchoolSystem
{
    public partial class UserManagement : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["SchoolSystemDB"].ConnectionString;

        private string ToTitleCase(string s)
        {
            if (string.IsNullOrWhiteSpace(s)) return s;
            return CultureInfo.CurrentCulture.TextInfo.ToTitleCase(s.Trim().ToLower());
        }

        private int GetNextId(string table, string pkCol)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(
                    "SELECT ISNULL(IDENT_CURRENT('" + table.Replace("[", "").Replace("]", "") + "'), 0) + " +
                    "ISNULL(IDENT_INCR('" + table.Replace("[", "").Replace("]", "") + "'), 1)", conn);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private string BuildEmail(string name, int id, string domain)
        {
            string clean = name.Trim().ToLower().Replace(" ", "");
            var sb = new System.Text.StringBuilder();
            foreach (char c in clean) if (char.IsLetterOrDigit(c)) sb.Append(c);
            if (sb.Length == 0) sb.Append("user");
            return sb.ToString() + id.ToString("D4") + "@" + domain;
        }

        private string JsStr(string s) { return (s ?? "").Replace("\\", "\\\\").Replace("'", "\\'"); }

        private void SetToast(string msg, string type = "success")
        {
            hfToastMsg.Value = msg;
            hfToastType.Value = type;
        }

        // ══════════════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStudents();
                LoadLecturers();
                LoadProgramAdd();
                LoadAllStatistics();
                WriteDropdownData();
                hfNextStudId.Value = GetNextId("[Student]", "student_id").ToString();
                hfNextLectId.Value = GetNextId("[Lecturer]", "lecturer_id").ToString();
            }
        }

        private void LoadAllStatistics()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("", conn);
                cmd.CommandText = "SELECT COUNT(*) FROM [Student]";
                lblTotalStudents.Text = cmd.ExecuteScalar().ToString();
                cmd.CommandText = "SELECT COUNT(*) FROM [Student] WHERE student_isactive='Active'";
                lblActiveStudents.Text = cmd.ExecuteScalar().ToString();
                cmd.CommandText = "SELECT COUNT(*) FROM [Student] WHERE student_isactive='Inactive' OR student_isactive='Graduated'";
                lblInactiveStudents.Text = cmd.ExecuteScalar().ToString();
                cmd.CommandText = "SELECT COUNT(*) FROM [Lecturer]";
                lblTotalLecturers.Text = cmd.ExecuteScalar().ToString();
                cmd.CommandText = "SELECT COUNT(*) FROM [Lecturer] WHERE teacher_isactive='Active'";
                lblActiveLecturers.Text = cmd.ExecuteScalar().ToString();
                cmd.CommandText = "SELECT COUNT(*) FROM [Lecturer] WHERE teacher_isactive='Inactive'";
                lblInactiveLecturers.Text = cmd.ExecuteScalar().ToString();
            }
        }

        private void WriteDropdownData()
        {
            var progs = new System.Collections.Generic.List<string>();
            var depts = new System.Collections.Generic.List<string>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                DataTable dtP = new DataTable();
                new SqlDataAdapter(new SqlCommand(
                    "SELECT program_id, program_name FROM [Program] ORDER BY program_name", conn)).Fill(dtP);
                foreach (DataRow r in dtP.Rows)
                    progs.Add(r["program_id"] + "|" + r["program_name"]);

                DataTable dtD = new DataTable();
                new SqlDataAdapter(new SqlCommand(
                    "SELECT DISTINCT lecturer_department FROM [Lecturer] ORDER BY lecturer_department", conn)).Fill(dtD);
                foreach (DataRow r in dtD.Rows)
                    depts.Add(r["lecturer_department"].ToString());
            }

            litDropdownData.Text =
                "<script>var _progData='" + string.Join("||", progs) + "'; var _deptData='" + string.Join("||", depts) + "';</script>";
        }

        // ══════════════════════════════════════════════════════════════
        // ADVANCE SESSION
        // Advances student semesters AND rolls the global academic session.
        // Sem 1 / JAN2026 → Sem 2 / APR2026 → Sem 3 / AUG2026 → ...
        // ══════════════════════════════════════════════════════════════
        private static readonly string[] SessionOrder = { "JAN", "APR", "AUG" };

        protected void btnAdvanceSession_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // 1. Advance all active students by 1 semester
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Student SET student_sem = student_sem + 1 WHERE student_isactive = 'Active'", conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // 2. Graduate students who have reached their program limit
                    using (SqlCommand cmd = new SqlCommand("sp_ProcessGraduations", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.ExecuteNonQuery();
                    }

                    // 3. Roll the global academic session forward in SystemSettings
                    string current;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT setting_value FROM SystemSettings WHERE setting_key = 'current_session'", conn))
                    {
                        current = cmd.ExecuteScalar()?.ToString() ?? "JAN2026";
                    }

                    // Mark all Active course assignments from the outgoing session as Inactive
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE CourseAssignment_Session SET assign_status = 'Inactive' WHERE academic_session = @OldSession AND assign_status = 'Active'", conn))
                    {
                        cmd.Parameters.AddWithValue("@OldSession", current);
                        cmd.ExecuteNonQuery();
                    }

                    string next = GetNextSession(current);
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE SystemSettings SET setting_value = @val WHERE setting_key = 'current_session'", conn))
                    {
                        cmd.Parameters.AddWithValue("@val", next);
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadStudents();
                LoadAllStatistics();

                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "advSuccess",
                    "Swal.fire({ title: 'Session Advanced', text: 'Session advanced and graduations processed successfully. All active students have moved to the next semester.', icon: 'success', confirmButtonColor: '#C5A059' });", true);
            }
            catch (Exception ex)
            {
                System.Web.UI.ScriptManager.RegisterStartupScript(this, GetType(), "advError",
                    "Swal.fire({ title: 'Error', text: 'Error advancing session: " + JsStr(ex.Message) + "', icon: 'error', confirmButtonColor: '#C5A059' });", true);
            }
        }

        // Converts e.g. "JAN2026" → "APR2026", "AUG2026" → "JAN2027"
        private string GetNextSession(string session)
        {
            if (string.IsNullOrWhiteSpace(session) || session.Length < 7)
                return "JAN2026";

            string month = session.Substring(0, 3).ToUpper();
            int year = int.Parse(session.Substring(3));

            int idx = Array.IndexOf(SessionOrder, month);
            if (idx == -1) idx = 0;

            int nextIdx = (idx + 1) % SessionOrder.Length;
            if (nextIdx == 0) year++;

            return SessionOrder[nextIdx] + year;
        }

        // ══════════════════════════════════════════════════════════════
        // PROGRAM DROPDOWN
        // ══════════════════════════════════════════════════════════════
        private void LoadProgramAdd()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                DataTable dt = new DataTable();
                new SqlDataAdapter(new SqlCommand(
                    "SELECT program_id, program_name FROM [Program] ORDER BY program_name", conn)).Fill(dt);

                string selected = ddlProgramAdd.SelectedValue;
                ddlProgramAdd.DataSource = dt;
                ddlProgramAdd.DataTextField = "program_name";
                ddlProgramAdd.DataValueField = "program_id";
                ddlProgramAdd.DataBind();
                ddlProgramAdd.Items.Insert(0, new ListItem("- Select a program -", ""));

                if (!string.IsNullOrEmpty(selected) &&
                    ddlProgramAdd.Items.FindByValue(selected) != null)
                    ddlProgramAdd.SelectedValue = selected;
            }
        }

        private void LoadStudents()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                DataTable dt = new DataTable();
                new SqlDataAdapter(new SqlCommand(@"
                    SELECT s.student_id,
                           s.student_code,
                           s.student_name,
                           s.student_email,
                           ISNULL(NULLIF(s.student_contact,''), 'N/A') AS student_contact,
                           s.student_isactive,
                           s.student_sem,
                           p.program_name
                    FROM [Student] s
                    LEFT JOIN [Program] p ON s.Program_id = p.program_id
                    ORDER BY s.student_name", conn)).Fill(dt);
                gvStudents.DataSource = dt;
                gvStudents.DataBind();
            }
        }

        private void LoadLecturers()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                DataTable dt = new DataTable();
                new SqlDataAdapter(new SqlCommand(@"
                    SELECT lecturer_id,
                           lecturer_code,
                           lecturer_name,
                           lecturer_email,
                           ISNULL(NULLIF(lecturer_contact,''), 'N/A') AS lecturer_contact,
                           lecturer_department,
                           teacher_isactive
                    FROM [Lecturer]
                    ORDER BY lecturer_name", conn)).Fill(dt);
                gvLecturers.DataSource = dt;
                gvLecturers.DataBind();
            }
        }

        // ══════════════════════════════════════════════════════════════
        // ADD STUDENT
        // ══════════════════════════════════════════════════════════════
        protected void btnAddStudent_Click(object sender, EventArgs e)
        {
            string name = ToTitleCase(txtStudName.Text);
            string contact = txtStudContact.Text.Trim();
            string progVal = Request.Form[ddlProgramAdd.UniqueID] ?? ddlProgramAdd.SelectedValue;

            var missing = new System.Collections.Generic.List<string>();
            if (string.IsNullOrWhiteSpace(name)) missing.Add("Full Name");
            if (string.IsNullOrWhiteSpace(progVal)) missing.Add("Program");
            if (!string.IsNullOrEmpty(contact) &&
                !System.Text.RegularExpressions.Regex.IsMatch(contact, @"^01\d-\d{7,8}$"))
                missing.Add("Phone Number (must start with 01)");

            int sem = 1;
            if (!string.IsNullOrEmpty(txtStudSem.Text)) int.TryParse(txtStudSem.Text, out sem);
            if (sem < 1 || sem > 12) missing.Add("Semester (1–12)");

            if (missing.Count > 0)
            {
                lblStudErr.Text = "⚠ Please fix: " + string.Join(", ", missing) + ".";
                hfReopenModal.Value = "addStudent";
                LoadStudents(); LoadAllStatistics();
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO [Student]
                            (student_code, student_name, student_pw, student_email,
                             student_contact, student_address, date_of_birth,
                             student_sem, student_isactive, Admin_admin_id, Program_id)
                        VALUES
                            ('TMP', @name, 'stud123', 'placeholder',
                             NULLIF(@contact,''), NULL, NULL,
                             @sem, 'Active', 1, @prog);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);", conn);
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@contact", contact);
                    cmd.Parameters.AddWithValue("@sem", sem);
                    cmd.Parameters.AddWithValue("@prog", progVal);
                    int realId = Convert.ToInt32(cmd.ExecuteScalar());

                    string code = "S" + realId.ToString("D4");
                    string email = BuildEmail(name, realId, "stud.com");

                    new SqlCommand(
                        "UPDATE [Student] SET student_code=@c, student_email=@e WHERE student_id=@id", conn)
                    {
                        Parameters = {
                            new SqlParameter("@c",  code),
                            new SqlParameter("@e",  email),
                            new SqlParameter("@id", realId)
                        }
                    }.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                lblStudErr.Text = "⚠ Error: " + ex.Message;
                hfReopenModal.Value = "addStudent";
                LoadStudents(); LoadAllStatistics();
                return;
            }

            txtStudName.Text = txtStudContact.Text = "";
            txtStudSem.Text = "1"; txtStudEmail.Text = "";
            lblStudErr.Text = ""; hfReopenModal.Value = "";
            hfNextStudId.Value = GetNextId("[Student]", "student_id").ToString();

            SetToast("✓ Student added successfully.", "success");
            LoadStudents(); LoadAllStatistics();
        }

        // ══════════════════════════════════════════════════════════════
        // ADD LECTURER
        // ══════════════════════════════════════════════════════════════
        protected void btnAddLecturer_Click(object sender, EventArgs e)
        {
            string name = ToTitleCase(txtLectName.Text);
            string contact = txtLectContact.Text.Trim();
            string dept = ddlLectDept.SelectedValue;

            var missing = new System.Collections.Generic.List<string>();
            if (string.IsNullOrWhiteSpace(name)) missing.Add("Full Name");
            if (string.IsNullOrWhiteSpace(dept)) missing.Add("Department");
            if (!string.IsNullOrEmpty(contact) &&
                !System.Text.RegularExpressions.Regex.IsMatch(contact, @"^01\d-\d{7,8}$"))
                missing.Add("Phone Number (must start with 01)");

            if (missing.Count > 0)
            {
                lblLectErr.Text = "⚠ Please fix: " + string.Join(", ", missing) + ".";
                hfReopenModal.Value = "addLecturer";
                LoadLecturers(); LoadAllStatistics();
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO [Lecturer]
                            (lecturer_code, lecturer_name, lecturer_pw, lecturer_email,
                             lecturer_contact, lecturer_address, date_of_birth,
                             lecturer_department, teacher_isactive, Admin_admin_id)
                        VALUES
                            ('TMP', @name, 'lect123', 'placeholder',
                             NULLIF(@contact,''), NULL, NULL,
                             @dept, 'Active', 1);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);", conn);
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@contact", contact);
                    cmd.Parameters.AddWithValue("@dept", dept);
                    int realId = Convert.ToInt32(cmd.ExecuteScalar());

                    string code = "L" + realId.ToString("D4");
                    string email = BuildEmail(name, realId, "lect.com");

                    new SqlCommand(
                        "UPDATE [Lecturer] SET lecturer_code=@c, lecturer_email=@e WHERE lecturer_id=@id", conn)
                    {
                        Parameters = {
                            new SqlParameter("@c",  code),
                            new SqlParameter("@e",  email),
                            new SqlParameter("@id", realId)
                        }
                    }.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                lblLectErr.Text = "⚠ Error: " + ex.Message;
                hfReopenModal.Value = "addLecturer";
                LoadLecturers(); LoadAllStatistics();
                return;
            }

            txtLectName.Text = txtLectContact.Text = "";
            txtLectEmail.Text = ""; lblLectErr.Text = ""; hfReopenModal.Value = "";
            hfNextLectId.Value = GetNextId("[Lecturer]", "lecturer_id").ToString();

            SetToast("✓ Lecturer added successfully.", "success");
            LoadLecturers(); LoadAllStatistics();
        }

        // ══════════════════════════════════════════════════════════════
        // STUDENT GRID COMMANDS
        // ══════════════════════════════════════════════════════════════
        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "Toggle":
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        new SqlCommand(@"UPDATE [Student] SET student_isactive=
                            CASE WHEN student_isactive='Active' THEN 'Inactive' ELSE 'Active' END
                            WHERE student_id=@id AND student_isactive != 'Graduated'", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
                    }
                    SetToast("✓ Status updated.", "success");
                    break;

                case "DeleteS":
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();

                        // Delete attendance records tied to this student's enrollments
                        new SqlCommand(@"DELETE ar FROM [AttendanceRecord] ar 
                                          INNER JOIN [Enrollment] e ON ar.enrollment_id = e.enrollment_id 
                                          WHERE e.student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // Delete payment detail rows tied to this student's enrollments
                        new SqlCommand(@"DELETE pd FROM [PaymentDetail] pd 
                                          INNER JOIN [Enrollment] e ON pd.enrollment_id = e.enrollment_id 
                                          WHERE e.student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // Delete assignment submissions made by this student
                        new SqlCommand("DELETE FROM [AssignmentSubmission] WHERE student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        new SqlCommand(@"DELETE cg FROM [CourseGrade] cg INNER JOIN [Enrollment] e ON cg.Enrollment_id = e.enrollment_id WHERE e.student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        new SqlCommand("DELETE FROM [Enrollment] WHERE student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        new SqlCommand("DELETE FROM [Payment] WHERE Student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        new SqlCommand("DELETE FROM [Grades] WHERE Student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // StudentCalendar and StudentNotifRead have ON DELETE CASCADE - no manual delete needed

                        new SqlCommand("DELETE FROM [Student] WHERE student_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
                    }
                    SetToast("✓ Student deleted.", "success");
                    break;

                case "ViewS":
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand(@"
                            SELECT s.student_id, s.student_code, s.student_name, s.student_email,
                                   ISNULL(NULLIF(s.student_contact,''),'N/A') AS student_contact,
                                   ISNULL(s.student_address,'N/A')            AS student_address,
                                   s.date_of_birth,
                                   s.student_sem, s.student_isactive, p.program_name
                            FROM [Student] s
                            LEFT JOIN [Program] p ON s.Program_id = p.program_id
                            WHERE s.student_id = @id", conn);
                        cmd.Parameters.AddWithValue("@id", id);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                hfViewType.Value = "student";
                                hfViewCode.Value = rdr["student_code"].ToString();
                                hfViewName.Value = rdr["student_name"].ToString();
                                hfViewEmail.Value = rdr["student_email"].ToString();
                                hfViewContact.Value = rdr["student_contact"].ToString();
                                hfViewAddr.Value = rdr["student_address"].ToString();
                                hfViewDOB.Value = rdr["date_of_birth"] != DBNull.Value
                                    ? Convert.ToDateTime(rdr["date_of_birth"]).ToString("dd MMM yyyy")
                                    : "N/A";
                                hfViewExtra1.Value = rdr["program_name"].ToString();
                                hfViewExtra2.Value = rdr["student_sem"].ToString();
                                hfViewStatus.Value = rdr["student_isactive"].ToString();
                            }
                        }
                    }
                    hfToastMsg.Value = "";
                    hfToastType.Value = "";
                    break;
            }

            LoadStudents(); LoadAllStatistics();
        }

        // ══════════════════════════════════════════════════════════════
        // LECTURER GRID COMMANDS
        // ══════════════════════════════════════════════════════════════
        protected void gvLecturers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "DeleteL":
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();

                        // Block deletion if this lecturer is set as a Program's Head of Program
                        using (SqlCommand chk = new SqlCommand(
                            "SELECT COUNT(1) FROM [Program] WHERE Lecturer_id = @id", conn))
                        {
                            chk.Parameters.AddWithValue("@id", id);
                            if ((int)chk.ExecuteScalar() > 0)
                            {
                                SetToast("✗ Cannot delete: this lecturer is set as Head of Program for one or more programs. Reassign the program first.", "error");
                                break;
                            }
                        }

                        // Remove this lecturer's course-session assignments
                        new SqlCommand("DELETE FROM [CourseAssignment_Session] WHERE lecturer_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // Remove this lecturer's favourites
                        new SqlCommand("DELETE FROM [LecturerCourseFavourite] WHERE lecturer_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // Remove announcements posted by this lecturer
                        new SqlCommand("DELETE FROM [Announcement] WHERE Lecturer_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();

                        // LecturerCalendar and LecturerNotifRead - LecturerCalendar has ON DELETE CASCADE, no manual delete needed

                        // Finally, remove the lecturer record itself
                        // (Course, Enrollment, and CourseGrade are intentionally left untouched -
                        //  they belong to the course/students, not the lecturer)
                        new SqlCommand("DELETE FROM [Lecturer] WHERE lecturer_id = @id", conn)
                        { Parameters = { new SqlParameter("@id", id) } }.ExecuteNonQuery();
                    }
                    SetToast("✓ Lecturer deleted.", "success");
                    break;

                case "ViewL":
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand(@"
                            SELECT lecturer_id, lecturer_code, lecturer_name, lecturer_email,
                                   ISNULL(NULLIF(lecturer_contact,''),'N/A') AS lecturer_contact,
                                   ISNULL(lecturer_address,'N/A')            AS lecturer_address,
                                   date_of_birth,
                                   lecturer_department, teacher_isactive
                            FROM [Lecturer] WHERE lecturer_id = @id", conn);
                        cmd.Parameters.AddWithValue("@id", id);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                hfViewType.Value = "lecturer";
                                hfViewCode.Value = rdr["lecturer_code"].ToString();
                                hfViewName.Value = rdr["lecturer_name"].ToString();
                                hfViewEmail.Value = rdr["lecturer_email"].ToString();
                                hfViewContact.Value = rdr["lecturer_contact"].ToString();
                                hfViewAddr.Value = rdr["lecturer_address"].ToString();
                                hfViewDOB.Value = rdr["date_of_birth"] != DBNull.Value
                                    ? rdr["date_of_birth"].ToString()
                                    : "N/A";
                                hfViewExtra1.Value = rdr["lecturer_department"].ToString();
                                hfViewStatus.Value = rdr["teacher_isactive"].ToString();
                            }
                        }
                    }
                    hfToastMsg.Value = "";
                    hfToastType.Value = "";
                    break;
            }

            LoadLecturers(); LoadAllStatistics();
        }
    }
}