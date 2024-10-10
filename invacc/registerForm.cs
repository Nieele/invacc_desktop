using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace invacc
{
    public partial class RegisterForm : Form
    {
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr LPAR);
        [DllImport("user32.dll")]
        public static extern bool ReleaseCapture();

        const int WM_NCLBUTTONDOWN = 0xA1;
        const int HT_CAPTION = 0x2;

        public RegisterForm()
        {
            InitializeComponent();
            AttachMoveWindowHandlers();
        }

        // Attach mouse event handlers for moving the window
        private void AttachMoveWindowHandlers()
        {
            this.MouseDown += MoveWindow;
            lblNameProgRegister.MouseDown += MoveWindow;
        }

        // Method to handle window movement
        private void MoveWindow(object? sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                _ = SendMessage(Handle, WM_NCLBUTTONDOWN, HT_CAPTION, IntPtr.Zero);
            }
        }

        private void btnCloseWindow_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void lblLogin_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
        }

        // Method to show/hide the password
        private void checkbxShowPassword_CheckedChanged(object sender, EventArgs e)
        {
            tboxPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
            tboxConfirmPassword.PasswordChar = checkbxShowPassword.Checked ? '\0' : '*';
        }

        // Get database connection
        private static NpgsqlConnection GetConnection(string connectionString)
        {
            return new NpgsqlConnection(connectionString);
        }

        // Attempt to open the database connection and proceed if successful
        private void TryLogin(NpgsqlConnection con)
        {
            try
            {
                con.Open();
                if (con.State == ConnectionState.Open)
                {
                    string query = $"CREATE USER {tboxUsername.Text} LOGIN PASSWORD '{tboxPassword.Text}';";
                    using (var command = new NpgsqlCommand(query, con))
                    {
                        var reader = command.ExecuteReader();
                    }
                    MessageBox.Show("Registration was successful", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (PostgresException ex)
            {
                if (ex.SqlState == "42710")
                {
                    MessageBox.Show("User already exists.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                if (con.State == ConnectionState.Closed)
                {
                    MessageBox.Show("Unable to connect to the database.\nMake sure that PostgreSQL is running", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void btnRegister_Click(object sender, EventArgs e)
        {
            if (tboxPassword.Text != tboxConfirmPassword.Text)
            {
                MessageBox.Show("The passwords are different", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                tboxPassword.Clear();
                tboxConfirmPassword.Clear();
            } 
            else if (tboxPassword.TextLength < 4)
            {
                MessageBox.Show("The password cannot be less than 4", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                tboxPassword.Clear();
                tboxConfirmPassword.Clear();
            }
            else
            {
                string connectionString = "Server=localhost;Port=5432;User Id=register;Password=password;Database=RentalDB;";
                using (var con = GetConnection(connectionString))
                {
                    TryLogin(con);
                }
            }
        }
    }
}
