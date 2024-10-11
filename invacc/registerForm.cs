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
        public RegisterForm()
        {
            InitializeComponent();
            WindowMover.Attach(this, lblNameProgRegister);
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

        // Attempt to open the database connection and proceed if successful
        private void TryRegister(NpgsqlConnection con)
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
                    MessageHelper.InfoRegistrationSuccess();
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (PostgresException ex)
            {
                if (ex.SqlState == "42710")
                {
                    MessageHelper.ErrorUserAlreadyExist();
                }
                if (con.State == ConnectionState.Closed)
                {
                    MessageHelper.ErrorUnableConnectDB();
                }
            }
        }

        private void ClearPasswordBoxes()
        {
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
                string connectionString = "Server=localhost;Port=5432;User Id=register;Password=password;Database=RentalDB;";
                using (var con = new NpgsqlConnection(connectionString))
                {
                    TryRegister(con);
                }
            }
        }
    }
}
