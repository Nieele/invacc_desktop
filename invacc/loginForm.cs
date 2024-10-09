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

        private void Move_window(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                _ = SendMessage(Handle, WM_NCLBUTTONDOWN, HT_CAPTION, 0);
            }
        }

        public FrmLogin()
        {
            InitializeComponent();
            this.MouseDown += new MouseEventHandler(Move_window);
            lblNameProg.MouseDown += new MouseEventHandler(Move_window);
        }

        private void BtnCloseWindow_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private static NpgsqlConnection GetConnection(string connectionString)
        {
            return new NpgsqlConnection(connectionString);
        }

        private void CheckbxShowPassword_CheckedChanged(object sender, EventArgs e)
        {
            if (checkbxShowPassword.Checked)
            {
                tboxPassword.PasswordChar = '\0';
            }
            else
            {
                tboxPassword.PasswordChar = '*';
            }
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            string sqlConnectionArg = "Server=localhost;Port=5432;User Id=" + tboxUsername.Text + ";Password=" + tboxPassword.Text + ";Database=RentalDB;";
            using (NpgsqlConnection con = GetConnection(sqlConnectionArg))
            {
                try
                {
                    con.Open();
                    if (con.State == ConnectionState.Open)
                    {
                        Form form2 = new mainForm();
                        form2.Show();
                    }
                }
                catch
                {
                    MessageBox.Show("Incorrect login or password", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void textBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                btnLogin.PerformClick();
            }
        }
    }
}
