namespace invacc
{
    partial class FrmLogin
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            lblNameProgLogin = new Label();
            lblUsername = new Label();
            lblPassword = new Label();
            tboxUsername = new TextBox();
            tboxPassword = new TextBox();
            checkbxShowPassword = new CheckBox();
            btnLogin = new Button();
            lblHaventAcc = new Label();
            lblRegister = new Label();
            btnCloseWindow = new Button();
            SuspendLayout();
            // 
            // lblNameProgLogin
            // 
            lblNameProgLogin.BackColor = Color.FromArgb(52, 73, 94);
            lblNameProgLogin.Dock = DockStyle.Top;
            lblNameProgLogin.Font = new Font("Javanese Text", 24F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblNameProgLogin.ForeColor = Color.White;
            lblNameProgLogin.Location = new Point(0, 0);
            lblNameProgLogin.Name = "lblNameProgLogin";
            lblNameProgLogin.RightToLeft = RightToLeft.No;
            lblNameProgLogin.Size = new Size(350, 92);
            lblNameProgLogin.TabIndex = 0;
            lblNameProgLogin.Text = "Login";
            lblNameProgLogin.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblUsername
            // 
            lblUsername.AutoSize = true;
            lblUsername.BackColor = Color.FromArgb(127, 140, 141);
            lblUsername.Font = new Font("Javanese Text", 18F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblUsername.ForeColor = Color.FromArgb(236, 240, 241);
            lblUsername.Location = new Point(20, 115);
            lblUsername.Margin = new Padding(0);
            lblUsername.Name = "lblUsername";
            lblUsername.Size = new Size(131, 54);
            lblUsername.TabIndex = 1;
            lblUsername.Text = "username";
            lblUsername.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblPassword
            // 
            lblPassword.AutoSize = true;
            lblPassword.Font = new Font("Javanese Text", 18F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblPassword.ForeColor = Color.FromArgb(236, 240, 241);
            lblPassword.Location = new Point(20, 185);
            lblPassword.Name = "lblPassword";
            lblPassword.Size = new Size(127, 54);
            lblPassword.TabIndex = 2;
            lblPassword.Text = "password";
            // 
            // tboxUsername
            // 
            tboxUsername.BackColor = Color.FromArgb(236, 240, 241);
            tboxUsername.Font = new Font("Franklin Gothic Medium", 14.25F, FontStyle.Bold, GraphicsUnit.Point, 204);
            tboxUsername.ForeColor = Color.FromArgb(52, 73, 94);
            tboxUsername.Location = new Point(25, 160);
            tboxUsername.MaxLength = 32;
            tboxUsername.Name = "tboxUsername";
            tboxUsername.Size = new Size(300, 29);
            tboxUsername.TabIndex = 3;
            tboxUsername.KeyDown += TextBox_KeyDown;
            // 
            // tboxPassword
            // 
            tboxPassword.BackColor = Color.FromArgb(236, 240, 241);
            tboxPassword.Font = new Font("Franklin Gothic Medium", 14.25F, FontStyle.Bold, GraphicsUnit.Point, 204);
            tboxPassword.ForeColor = Color.FromArgb(52, 73, 94);
            tboxPassword.Location = new Point(25, 230);
            tboxPassword.MaxLength = 32;
            tboxPassword.Name = "tboxPassword";
            tboxPassword.PasswordChar = '*';
            tboxPassword.Size = new Size(300, 29);
            tboxPassword.TabIndex = 4;
            tboxPassword.KeyDown += TextBox_KeyDown;
            // 
            // checkbxShowPassword
            // 
            checkbxShowPassword.AutoSize = true;
            checkbxShowPassword.Cursor = Cursors.Hand;
            checkbxShowPassword.FlatStyle = FlatStyle.Flat;
            checkbxShowPassword.Font = new Font("Javanese Text", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            checkbxShowPassword.ForeColor = Color.FromArgb(236, 240, 241);
            checkbxShowPassword.Location = new Point(173, 266);
            checkbxShowPassword.Name = "checkbxShowPassword";
            checkbxShowPassword.Size = new Size(152, 40);
            checkbxShowPassword.TabIndex = 5;
            checkbxShowPassword.Text = "Show Password";
            checkbxShowPassword.TextAlign = ContentAlignment.MiddleCenter;
            checkbxShowPassword.UseVisualStyleBackColor = true;
            checkbxShowPassword.CheckedChanged += CheckbxShowPassword_CheckedChanged;
            // 
            // btnLogin
            // 
            btnLogin.BackColor = Color.FromArgb(52, 73, 94);
            btnLogin.Cursor = Cursors.Hand;
            btnLogin.FlatAppearance.BorderColor = Color.IndianRed;
            btnLogin.Font = new Font("Javanese Text", 14.25F, FontStyle.Bold, GraphicsUnit.Point, 0);
            btnLogin.ForeColor = Color.FromArgb(236, 240, 241);
            btnLogin.Location = new Point(25, 415);
            btnLogin.Name = "btnLogin";
            btnLogin.Size = new Size(300, 45);
            btnLogin.TabIndex = 6;
            btnLogin.Text = "login";
            btnLogin.UseVisualStyleBackColor = false;
            btnLogin.Click += BtnLogin_Click;
            // 
            // lblHaventAcc
            // 
            lblHaventAcc.AutoSize = true;
            lblHaventAcc.Font = new Font("Javanese Text", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblHaventAcc.ForeColor = Color.FromArgb(236, 240, 241);
            lblHaventAcc.Location = new Point(37, 465);
            lblHaventAcc.Name = "lblHaventAcc";
            lblHaventAcc.Size = new Size(198, 36);
            lblHaventAcc.TabIndex = 7;
            lblHaventAcc.Text = "Don't have an account?";
            // 
            // lblRegister
            // 
            lblRegister.AutoSize = true;
            lblRegister.Cursor = Cursors.Hand;
            lblRegister.Font = new Font("Javanese Text", 12F, FontStyle.Bold);
            lblRegister.ForeColor = Color.FromArgb(192, 255, 255);
            lblRegister.Location = new Point(229, 465);
            lblRegister.Name = "lblRegister";
            lblRegister.Size = new Size(82, 36);
            lblRegister.TabIndex = 8;
            lblRegister.Text = "Register";
            lblRegister.Click += LblRegister_Click;
            // 
            // btnCloseWindow
            // 
            btnCloseWindow.BackColor = Color.FromArgb(62, 83, 104);
            btnCloseWindow.BackgroundImageLayout = ImageLayout.None;
            btnCloseWindow.FlatStyle = FlatStyle.Popup;
            btnCloseWindow.ForeColor = Color.FromArgb(236, 240, 241);
            btnCloseWindow.Location = new Point(325, 0);
            btnCloseWindow.Name = "btnCloseWindow";
            btnCloseWindow.Size = new Size(25, 25);
            btnCloseWindow.TabIndex = 9;
            btnCloseWindow.Text = "X";
            btnCloseWindow.UseVisualStyleBackColor = false;
            btnCloseWindow.Click += BtnCloseWindow_Click;
            // 
            // FrmLogin
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(127, 140, 141);
            ClientSize = new Size(350, 530);
            Controls.Add(btnCloseWindow);
            Controls.Add(lblRegister);
            Controls.Add(lblHaventAcc);
            Controls.Add(btnLogin);
            Controls.Add(checkbxShowPassword);
            Controls.Add(tboxPassword);
            Controls.Add(tboxUsername);
            Controls.Add(lblPassword);
            Controls.Add(lblUsername);
            Controls.Add(lblNameProgLogin);
            FormBorderStyle = FormBorderStyle.None;
            Name = "FrmLogin";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Login";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label lblNameProgLogin;
        private Label lblUsername;
        private Label lblPassword;
        private TextBox tboxUsername;
        private TextBox tboxPassword;
        private CheckBox checkbxShowPassword;
        private Button btnLogin;
        private Label lblHaventAcc;
        private Label lblRegister;
        private Button btnCloseWindow;
    }
}