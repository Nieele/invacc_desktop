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
            lblNameProg = new Label();
            label2 = new Label();
            label3 = new Label();
            tboxUsername = new TextBox();
            tboxPassword = new TextBox();
            checkbxShowPassword = new CheckBox();
            btnLogin = new Button();
            lblHaventAcc = new Label();
            lblRegister = new Label();
            SuspendLayout();
            // 
            // lblNameProg
            // 
            lblNameProg.BackColor = Color.FromArgb(52, 73, 94);
            lblNameProg.Dock = DockStyle.Top;
            lblNameProg.Font = new Font("Javanese Text", 24F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblNameProg.ForeColor = Color.White;
            lblNameProg.Location = new Point(0, 0);
            lblNameProg.Name = "lblNameProg";
            lblNameProg.RightToLeft = RightToLeft.No;
            lblNameProg.Size = new Size(350, 92);
            lblNameProg.TabIndex = 0;
            lblNameProg.Text = "Login";
            lblNameProg.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.BackColor = Color.FromArgb(127, 140, 141);
            label2.Font = new Font("Javanese Text", 15.75F, FontStyle.Bold, GraphicsUnit.Point, 0);
            label2.ForeColor = Color.FromArgb(236, 240, 241);
            label2.Location = new Point(25, 120);
            label2.Margin = new Padding(0);
            label2.Name = "label2";
            label2.Size = new Size(116, 47);
            label2.TabIndex = 1;
            label2.Text = "username";
            label2.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Font = new Font("Javanese Text", 15.75F, FontStyle.Bold, GraphicsUnit.Point, 0);
            label3.ForeColor = Color.FromArgb(236, 240, 241);
            label3.Location = new Point(25, 190);
            label3.Name = "label3";
            label3.Size = new Size(115, 47);
            label3.TabIndex = 2;
            label3.Text = "password";
            // 
            // tboxUsername
            // 
            tboxUsername.BackColor = Color.FromArgb(236, 240, 241);
            tboxUsername.Font = new Font("Franklin Gothic Medium", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            tboxUsername.ForeColor = Color.FromArgb(52, 73, 94);
            tboxUsername.Location = new Point(25, 160);
            tboxUsername.MaxLength = 32;
            tboxUsername.Multiline = true;
            tboxUsername.Name = "tboxUsername";
            tboxUsername.Size = new Size(300, 30);
            tboxUsername.TabIndex = 3;
            // 
            // tboxPassword
            // 
            tboxPassword.BackColor = Color.FromArgb(236, 240, 241);
            tboxPassword.Font = new Font("Franklin Gothic Medium", 12F, FontStyle.Bold);
            tboxPassword.ForeColor = Color.FromArgb(52, 73, 94);
            tboxPassword.Location = new Point(25, 230);
            tboxPassword.MaxLength = 32;
            tboxPassword.Multiline = true;
            tboxPassword.Name = "tboxPassword";
            tboxPassword.Size = new Size(300, 30);
            tboxPassword.TabIndex = 4;
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
            // 
            // btnLogin
            // 
            btnLogin.BackColor = Color.FromArgb(52, 73, 94);
            btnLogin.Cursor = Cursors.Hand;
            btnLogin.FlatAppearance.BorderColor = Color.IndianRed;
            btnLogin.Font = new Font("Javanese Text", 14.25F, FontStyle.Bold, GraphicsUnit.Point, 0);
            btnLogin.ForeColor = Color.FromArgb(236, 240, 241);
            btnLogin.Location = new Point(25, 384);
            btnLogin.Name = "btnLogin";
            btnLogin.Size = new Size(300, 45);
            btnLogin.TabIndex = 6;
            btnLogin.Text = "login";
            btnLogin.UseVisualStyleBackColor = false;
            // 
            // lblHaventAcc
            // 
            lblHaventAcc.AutoSize = true;
            lblHaventAcc.Font = new Font("Javanese Text", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblHaventAcc.ForeColor = Color.FromArgb(236, 240, 241);
            lblHaventAcc.Location = new Point(40, 455);
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
            lblRegister.Location = new Point(228, 455);
            lblRegister.Name = "lblRegister";
            lblRegister.Size = new Size(82, 36);
            lblRegister.TabIndex = 8;
            lblRegister.Text = "Register";
            // 
            // frmLogin
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(127, 140, 141);
            ClientSize = new Size(350, 530);
            Controls.Add(lblRegister);
            Controls.Add(lblHaventAcc);
            Controls.Add(btnLogin);
            Controls.Add(checkbxShowPassword);
            Controls.Add(tboxPassword);
            Controls.Add(tboxUsername);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(lblNameProg);
            FormBorderStyle = FormBorderStyle.None;
            Name = "frmLogin";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Login";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label lblNameProg;
        private Label label2;
        private Label label3;
        private TextBox tboxUsername;
        private TextBox tboxPassword;
        private CheckBox checkbxShowPassword;
        private Button btnLogin;
        private Label lblHaventAcc;
        private Label lblRegister;
    }
}