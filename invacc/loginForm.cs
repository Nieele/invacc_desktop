using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net.NetworkInformation;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql;
using System.Windows.Forms;

namespace invacc
{
    public partial class FrmLogin : Form
    {
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr LPAR);
        [DllImport("user32.dll")]
        public static extern bool ReleaseCapture();

        const int WM_NCLBUTTONDOWN = 0xA1;
        const int HT_CAPTION = 0x2;

        public FrmLogin()
        {
            InitializeComponent();
            AttachMoveWindowHandlers();
        }

        // Attach mouse event handlers for moving the window
        private void AttachMoveWindowHandlers()
        {
            this.MouseDown += MoveWindow;
            lblNameProg.MouseDown += MoveWindow;
        }

        // Method to handle window movement
        private void MoveWindow(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                _ = SendMessage(Handle, WM_NCLBUTTONDOWN, HT_CAPTION, IntPtr.Zero);
            }
        }

        // Close the window
        private void BtnCloseWindow_Click(object sender, EventArgs e)
        {
            Close();
        }

        // Method to show/hide the password
        private void CheckbxShowPassword_CheckedChanged(object sender, EventArgs e)
        {
            tboxPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
        }

        // Get database connection
        private static NpgsqlConnection GetConnection(string connectionString)
        {
            return new NpgsqlConnection(connectionString);
        }

        // Handle the login button click event
        private void BtnLogin_Click(object sender, EventArgs e)
        {
            string connectionString = $"Server=localhost;Port=5432;User Id={tboxUsername.Text};Password={tboxPassword.Text};Database=RentalDB;";
            using var con = GetConnection(connectionString);
            TryLogin(con);
        }

        // Attempt to open the database connection and proceed if successful
        private static void TryLogin(NpgsqlConnection con)
        {
            try
            {
                con.Open();
                if (con.State == ConnectionState.Open)
                {
                    OpenMainForm();
                }
            }
            catch
            {
                if (con.State == ConnectionState.Closed)
                {
                    ShowLoginError();
                }
            }
        }

        // Open the main form after successful login
        private static void OpenMainForm()
        {
            var form2 = new mainForm();
            form2.Show();
        }

        // Show an error message when login fails
        private static void ShowLoginError()
        {
            MessageBox.Show("Unable to connect to the database.\nMake sure that PostgreSQL is running and the username and password are correct.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
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

        private void LblRegister_Click(object sender, EventArgs e)
        {
            var registerForm = new RegisterForm();
            registerForm.Show();
            this.Hide();
        }
    }
}
