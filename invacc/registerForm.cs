namespace invacc
{
    public partial class FrmRegister : Form
    {
        public FrmRegister()
        {
            InitializeComponent();
            WindowMover.Attach(this, this, lblNameProgRegister);
        }

        private void btnCloseWindow_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void lblLogin_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
        }

        // show/hide password
        private void checkbxShowPassword_CheckedChanged(object sender, EventArgs e)
        {
            tboxPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
            tboxConfirmPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
        }

        // Attempt to open the database connection and try register
        private void TryRegister()
        {
            var status = DatabaseHelper.ExecuteRegisterQuery(tboxUsername.Text, tboxPassword.Text);
            switch (status)
            {
                case DatabaseHelper.ReturnState.OK:
                    MessageHelper.InfoRegistrationSuccess();
                    this.DialogResult = DialogResult.OK;
                    break;
                case DatabaseHelper.ReturnState.UserAlreadyExist:
                    MessageHelper.ErrorUserAlreadyExist();
                    ClearFields();
                    break;
                case DatabaseHelper.ReturnState.ErrorConnection:
                    MessageHelper.ErrorUnableConnectDB();
                    ClearFields();
                    break;
            }
        }

        private void ClearPasswordBoxes()
        {
            tboxPassword.Clear();
            tboxConfirmPassword.Clear();
        }

        private void ClearFields()
        {
            tboxUsername.Clear();
            tboxPassword.Clear();
            tboxConfirmPassword.Clear();
        }

        private void btnRegister_Click(object sender, EventArgs e)
        {
            if (tboxPassword.Text != tboxConfirmPassword.Text)
            {
                MessageHelper.ErrorDifferentPassword();
                ClearPasswordBoxes();
            }
            else if (tboxPassword.TextLength < 4)
            {
                MessageHelper.ErrorShortPassword();
                ClearPasswordBoxes();
            }
            else
            {
                TryRegister();
            }
        }

        // Handle Enter key press to trigger login
        private void TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                btnRegister.PerformClick();
            }
        }
    }
}
