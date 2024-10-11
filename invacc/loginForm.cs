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
        public FrmLogin()
        {
            InitializeComponent();
            WindowMover.Attach(this, lblNameProg);
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
            string connectionString = $"Server=localhost;Port=5432;User Id={tboxUsername.Text};Password={tboxPassword.Text};Database=RentalDB;";
            using var con = new NpgsqlConnection(connectionString);
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
                    MessageHelper.ErrorUnableConnectOrFailedEntry();
                }
            }
        }

        // Open the main form after successful login
        private static void OpenMainForm()
        {
            var mainForm = new FrmMain();
            mainForm.Show();
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
                this.Hide();
                var result = registerForm.ShowDialog();

                if (Application.OpenForms.Count > 0)
                {
                    this.Show();
                }
            }
        }
    }
}
