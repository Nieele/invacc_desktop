namespace invacc
{
    partial class RegisterForm
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
            lblNameProgRegister = new Label();
            btnCloseWindow = new Button();
            lblLogin = new Label();
            lblHaventAcc = new Label();
            btnLogin = new Button();
            checkbxShowPassword = new CheckBox();
            tboxPassword = new TextBox();
            tboxUsername = new TextBox();
            lblPassword = new Label();
            lblUsername = new Label();
            lblConfirmPassword = new Label();
            tboxConfirmPassword = new TextBox();
            SuspendLayout();
            // 
            // lblNameProgRegister
            // 
            lblNameProgRegister.BackColor = Color.FromArgb(52, 73, 94);
            lblNameProgRegister.Font = new Font("Javanese Text", 24F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblNameProgRegister.ForeColor = Color.White;
            lblNameProgRegister.Location = new Point(0, 0);
            lblNameProgRegister.Name = "lblNameProgRegister";
            lblNameProgRegister.Size = new Size(350, 92);
            lblNameProgRegister.TabIndex = 0;
            lblNameProgRegister.Text = "Register";
            lblNameProgRegister.TextAlign = ContentAlignment.MiddleCenter;
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
            btnCloseWindow.TabIndex = 10;
            btnCloseWindow.Text = "X";
            btnCloseWindow.UseVisualStyleBackColor = false;
            // 
            // lblLogin
            // 
            lblLogin.AutoSize = true;
            lblLogin.Cursor = Cursors.Hand;
            lblLogin.Font = new Font("Javanese Text", 12F, FontStyle.Bold);
            lblLogin.ForeColor = Color.FromArgb(192, 255, 255);
            lblLogin.Location = new Point(251, 465);
            lblLogin.Name = "lblLogin";
            lblLogin.Size = new Size(60, 36);
            lblLogin.TabIndex = 18;
            lblLogin.Text = "Login";
            // 
            // lblHaventAcc
            // 
            lblHaventAcc.AutoSize = true;
            lblHaventAcc.Font = new Font("Javanese Text", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblHaventAcc.ForeColor = Color.FromArgb(236, 240, 241);
            lblHaventAcc.Location = new Point(40, 465);
            lblHaventAcc.Name = "lblHaventAcc";
            lblHaventAcc.Size = new Size(220, 36);
            lblHaventAcc.TabIndex = 17;
            lblHaventAcc.Text = "Already have an accound?";
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
            btnLogin.TabIndex = 16;
            btnLogin.Text = "register";
            btnLogin.UseVisualStyleBackColor = false;
            // 
            // checkbxShowPassword
            // 
            checkbxShowPassword.AutoSize = true;
            checkbxShowPassword.Cursor = Cursors.Hand;
            checkbxShowPassword.FlatStyle = FlatStyle.Flat;
            checkbxShowPassword.Font = new Font("Javanese Text", 12F, FontStyle.Bold, GraphicsUnit.Point, 0);
            checkbxShowPassword.ForeColor = Color.FromArgb(236, 240, 241);
            checkbxShowPassword.Location = new Point(173, 336);
            checkbxShowPassword.Name = "checkbxShowPassword";
            checkbxShowPassword.Size = new Size(152, 40);
            checkbxShowPassword.TabIndex = 15;
            checkbxShowPassword.Text = "Show Password";
            checkbxShowPassword.TextAlign = ContentAlignment.MiddleCenter;
            checkbxShowPassword.UseVisualStyleBackColor = true;
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
            tboxPassword.TabIndex = 14;
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
            tboxUsername.TabIndex = 13;
            // 
            // lblPassword
            // 
            lblPassword.AutoSize = true;
            lblPassword.Font = new Font("Javanese Text", 18F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblPassword.ForeColor = Color.FromArgb(236, 240, 241);
            lblPassword.Location = new Point(20, 185);
            lblPassword.Name = "lblPassword";
            lblPassword.Size = new Size(127, 54);
            lblPassword.TabIndex = 12;
            lblPassword.Text = "password";
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
            lblUsername.TabIndex = 11;
            lblUsername.Text = "username";
            lblUsername.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblConfirmPassword
            // 
            lblConfirmPassword.AutoSize = true;
            lblConfirmPassword.Font = new Font("Javanese Text", 18F, FontStyle.Bold, GraphicsUnit.Point, 0);
            lblConfirmPassword.ForeColor = Color.FromArgb(236, 240, 241);
            lblConfirmPassword.Location = new Point(20, 255);
            lblConfirmPassword.Name = "lblConfirmPassword";
            lblConfirmPassword.Size = new Size(220, 54);
            lblConfirmPassword.TabIndex = 19;
            lblConfirmPassword.Text = "confirm password";
            // 
            // tboxConfirmPassword
            // 
            tboxConfirmPassword.BackColor = Color.FromArgb(236, 240, 241);
            tboxConfirmPassword.Font = new Font("Franklin Gothic Medium", 14.25F, FontStyle.Bold, GraphicsUnit.Point, 204);
            tboxConfirmPassword.ForeColor = Color.FromArgb(52, 73, 94);
            tboxConfirmPassword.Location = new Point(25, 300);
            tboxConfirmPassword.MaxLength = 32;
            tboxConfirmPassword.Name = "tboxConfirmPassword";
            tboxConfirmPassword.PasswordChar = '*';
            tboxConfirmPassword.Size = new Size(300, 29);
            tboxConfirmPassword.TabIndex = 20;
            // 
            // RegisterForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(127, 140, 141);
            ClientSize = new Size(350, 530);
            Controls.Add(lblLogin);
            Controls.Add(tboxConfirmPassword);
            Controls.Add(tboxUsername);
            Controls.Add(tboxPassword);
            Controls.Add(lblConfirmPassword);
            Controls.Add(lblHaventAcc);
            Controls.Add(btnLogin);
            Controls.Add(checkbxShowPassword);
            Controls.Add(lblPassword);
            Controls.Add(lblUsername);
            Controls.Add(btnCloseWindow);
            Controls.Add(lblNameProgRegister);
            FormBorderStyle = FormBorderStyle.None;
            Name = "RegisterForm";
            Text = "Register";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label lblNameProgRegister;
        private Button btnCloseWindow;
        private Label lblLogin;
        private Label lblHaventAcc;
        private Button btnLogin;
        private CheckBox checkbxShowPassword;
        private TextBox tboxPassword;
        private TextBox tboxUsername;
        private Label lblPassword;
        private Label lblUsername;
        private Label lblConfirmPassword;
        private TextBox tboxConfirmPassword;
    }
}