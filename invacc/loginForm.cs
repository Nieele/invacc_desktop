using Npgsql;

namespace invacc
{
    public partial class FrmLogin : Form
    {
        public FrmLogin()
        {
            InitializeComponent();
            WindowMover.Attach(this, this, lblNameProgLogin);
        }

        private void BtnCloseWindow_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        // show/hide password
        private void CheckbxShowPassword_CheckedChanged(object sender, EventArgs e)
        {
            tboxPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
        }

        private void BtnLogin_Click(object sender, EventArgs e)
        {
            TryLogin();
        }

        private void ClearFields()
        {
            tboxUsername.Clear();
            tboxPassword.Clear();
        }

        // Attempt to open the database connection and proceed if successful
        private void TryLogin()
        {
            using (var con = DatabaseHelper.CreateLoginConnection(tboxUsername.Text, tboxPassword.Text))
            {
                var status = DatabaseHelper.ExecuteLoginQuery(con);
                switch (status)
                {
                    case DatabaseHelper.ReturnState.OK:
                        ClearFields();
                        OpenMainForm(con);
                        break;
                    case DatabaseHelper.ReturnState.ErrorConnection:
                        MessageHelper.ErrorUnableConnectOrFailedEntry();
                        ClearFields();
                        break;
                }
            }
        }

        // Open the main form after successful login
        private void OpenMainForm(NpgsqlConnection session)
        {
            using (var mainForm = new FrmMain(session))
            {
                this.Hide();
                mainForm.ShowDialog();

                if (Application.OpenForms.Count > 0)
                {
                    this.StartPosition = FormStartPosition.CenterScreen;
                    this.Show();
                }
            }
        }

        // Handle Enter key press to trigger login
        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                btnLogin.PerformClick();
            }
        }

        // Switching to the registration window
        private void LblRegister_Click(object sender, EventArgs e)
        {
            using (var registerForm = new FrmRegister())
            {
                registerForm.StartPosition = FormStartPosition.Manual;
                registerForm.Location = this.Location;

                this.Hide();
                var result = registerForm.ShowDialog();

                if (Application.OpenForms.Count > 0)
                {
                    this.StartPosition = FormStartPosition.Manual;
                    this.Location = registerForm.Location;
                    this.Show();
                }
            }
        }
    }
}
