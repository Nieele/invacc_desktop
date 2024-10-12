namespace invacc
{
    partial class FrmMain
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMain));
            panelTitleBar = new Panel();
            picProgIcon = new PictureBox();
            lblNameProgInventory = new Label();
            btnTitleBarClose = new Button();
            btnTitleBarExpand = new Button();
            btnTitleBarMinimize = new Button();
            picAccount = new PictureBox();
            panelSide = new Panel();
            btnPanelModeration = new Button();
            lblUserRole = new Label();
            lblUsername = new Label();
            btnPanelInventory = new Button();
            btnPanelRentalItems = new Button();
            panel1 = new Panel();
            panelTitleBar.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)picProgIcon).BeginInit();
            ((System.ComponentModel.ISupportInitialize)picAccount).BeginInit();
            panelSide.SuspendLayout();
            SuspendLayout();
            // 
            // panelTitleBar
            // 
            panelTitleBar.BackColor = Color.FromArgb(97, 110, 111);
            panelTitleBar.Controls.Add(picProgIcon);
            panelTitleBar.Controls.Add(lblNameProgInventory);
            panelTitleBar.Controls.Add(btnTitleBarClose);
            panelTitleBar.Controls.Add(btnTitleBarExpand);
            panelTitleBar.Controls.Add(btnTitleBarMinimize);
            panelTitleBar.Dock = DockStyle.Top;
            panelTitleBar.Location = new Point(0, 0);
            panelTitleBar.Name = "panelTitleBar";
            panelTitleBar.Size = new Size(800, 22);
            panelTitleBar.TabIndex = 0;
            // 
            // picProgIcon
            // 
            picProgIcon.BackgroundImage = (Image)resources.GetObject("picProgIcon.BackgroundImage");
            picProgIcon.BackgroundImageLayout = ImageLayout.Stretch;
            picProgIcon.Location = new Point(6, 3);
            picProgIcon.Name = "picProgIcon";
            picProgIcon.Size = new Size(16, 16);
            picProgIcon.TabIndex = 3;
            picProgIcon.TabStop = false;
            // 
            // lblNameProgInventory
            // 
            lblNameProgInventory.AutoSize = true;
            lblNameProgInventory.Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold, GraphicsUnit.Point, 128);
            lblNameProgInventory.Location = new Point(28, 5);
            lblNameProgInventory.Name = "lblNameProgInventory";
            lblNameProgInventory.Size = new Size(68, 14);
            lblNameProgInventory.TabIndex = 3;
            lblNameProgInventory.Text = "Inventory";
            // 
            // btnTitleBarClose
            // 
            btnTitleBarClose.BackColor = Color.FromArgb(77, 90, 91);
            btnTitleBarClose.BackgroundImage = (Image)resources.GetObject("btnTitleBarClose.BackgroundImage");
            btnTitleBarClose.BackgroundImageLayout = ImageLayout.Zoom;
            btnTitleBarClose.FlatAppearance.BorderSize = 0;
            btnTitleBarClose.FlatAppearance.MouseDownBackColor = Color.FromArgb(87, 100, 101);
            btnTitleBarClose.FlatStyle = FlatStyle.Flat;
            btnTitleBarClose.Location = new Point(763, 1);
            btnTitleBarClose.Name = "btnTitleBarClose";
            btnTitleBarClose.Size = new Size(30, 20);
            btnTitleBarClose.TabIndex = 2;
            btnTitleBarClose.UseVisualStyleBackColor = false;
            btnTitleBarClose.Click += BtnTitleBarClose_Click;
            // 
            // btnTitleBarExpand
            // 
            btnTitleBarExpand.BackColor = Color.FromArgb(77, 90, 91);
            btnTitleBarExpand.BackgroundImage = (Image)resources.GetObject("btnTitleBarExpand.BackgroundImage");
            btnTitleBarExpand.BackgroundImageLayout = ImageLayout.Zoom;
            btnTitleBarExpand.FlatAppearance.BorderSize = 0;
            btnTitleBarExpand.FlatAppearance.MouseDownBackColor = Color.FromArgb(87, 100, 101);
            btnTitleBarExpand.FlatStyle = FlatStyle.Flat;
            btnTitleBarExpand.Location = new Point(728, 1);
            btnTitleBarExpand.Name = "btnTitleBarExpand";
            btnTitleBarExpand.Size = new Size(30, 20);
            btnTitleBarExpand.TabIndex = 1;
            btnTitleBarExpand.UseVisualStyleBackColor = false;
            btnTitleBarExpand.Click += BtnTitleBarExpand_Click;
            // 
            // btnTitleBarMinimize
            // 
            btnTitleBarMinimize.BackColor = Color.FromArgb(77, 90, 91);
            btnTitleBarMinimize.BackgroundImage = (Image)resources.GetObject("btnTitleBarMinimize.BackgroundImage");
            btnTitleBarMinimize.BackgroundImageLayout = ImageLayout.Zoom;
            btnTitleBarMinimize.FlatAppearance.BorderColor = Color.White;
            btnTitleBarMinimize.FlatAppearance.BorderSize = 0;
            btnTitleBarMinimize.FlatAppearance.MouseDownBackColor = Color.FromArgb(87, 100, 101);
            btnTitleBarMinimize.FlatStyle = FlatStyle.Flat;
            btnTitleBarMinimize.Location = new Point(693, 1);
            btnTitleBarMinimize.Name = "btnTitleBarMinimize";
            btnTitleBarMinimize.Size = new Size(30, 20);
            btnTitleBarMinimize.TabIndex = 0;
            btnTitleBarMinimize.UseVisualStyleBackColor = false;
            btnTitleBarMinimize.Click += BtnTitleBarMinimize_Click;
            // 
            // picAccount
            // 
            picAccount.BackColor = Color.FromArgb(72, 93, 114);
            picAccount.BackgroundImageLayout = ImageLayout.None;
            picAccount.Image = (Image)resources.GetObject("picAccount.Image");
            picAccount.Location = new Point(43, 30);
            picAccount.Name = "picAccount";
            picAccount.Size = new Size(64, 64);
            picAccount.TabIndex = 1;
            picAccount.TabStop = false;
            // 
            // panelSide
            // 
            panelSide.BackColor = Color.FromArgb(52, 73, 94);
            panelSide.BorderStyle = BorderStyle.FixedSingle;
            panelSide.Controls.Add(btnPanelModeration);
            panelSide.Controls.Add(lblUserRole);
            panelSide.Controls.Add(lblUsername);
            panelSide.Controls.Add(btnPanelInventory);
            panelSide.Controls.Add(btnPanelRentalItems);
            panelSide.Controls.Add(picAccount);
            panelSide.Dock = DockStyle.Left;
            panelSide.Location = new Point(0, 22);
            panelSide.Margin = new Padding(0);
            panelSide.Name = "panelSide";
            panelSide.Size = new Size(150, 428);
            panelSide.TabIndex = 2;
            // 
            // btnPanelModeration
            // 
            btnPanelModeration.BackColor = Color.FromArgb(102, 123, 134);
            btnPanelModeration.BackgroundImageLayout = ImageLayout.None;
            btnPanelModeration.FlatAppearance.BorderSize = 0;
            btnPanelModeration.FlatStyle = FlatStyle.Flat;
            btnPanelModeration.Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold);
            btnPanelModeration.ForeColor = Color.FromArgb(236, 240, 241);
            btnPanelModeration.Location = new Point(0, 249);
            btnPanelModeration.Name = "btnPanelModeration";
            btnPanelModeration.Size = new Size(150, 36);
            btnPanelModeration.TabIndex = 6;
            btnPanelModeration.Text = "Moderation";
            btnPanelModeration.UseVisualStyleBackColor = false;
            // 
            // lblUserRole
            // 
            lblUserRole.Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold, GraphicsUnit.Point, 128);
            lblUserRole.ForeColor = Color.FromArgb(236, 240, 241);
            lblUserRole.Location = new Point(0, 122);
            lblUserRole.Margin = new Padding(0);
            lblUserRole.Name = "lblUserRole";
            lblUserRole.Size = new Size(150, 20);
            lblUserRole.TabIndex = 5;
            lblUserRole.Text = "unknown";
            lblUserRole.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblUsername
            // 
            lblUsername.Font = new Font("UD Digi Kyokasho NP-B", 11.25F, FontStyle.Bold, GraphicsUnit.Point, 128);
            lblUsername.ForeColor = Color.FromArgb(236, 240, 241);
            lblUsername.Location = new Point(0, 100);
            lblUsername.Name = "lblUsername";
            lblUsername.Size = new Size(150, 22);
            lblUsername.TabIndex = 4;
            lblUsername.Text = "unknown";
            lblUsername.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // btnPanelInventory
            // 
            btnPanelInventory.BackColor = Color.FromArgb(102, 123, 134);
            btnPanelInventory.BackgroundImageLayout = ImageLayout.None;
            btnPanelInventory.FlatAppearance.BorderSize = 0;
            btnPanelInventory.FlatStyle = FlatStyle.Flat;
            btnPanelInventory.Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold);
            btnPanelInventory.ForeColor = Color.FromArgb(236, 240, 241);
            btnPanelInventory.Location = new Point(0, 207);
            btnPanelInventory.Name = "btnPanelInventory";
            btnPanelInventory.Size = new Size(150, 36);
            btnPanelInventory.TabIndex = 3;
            btnPanelInventory.Text = "Inventory";
            btnPanelInventory.UseVisualStyleBackColor = false;
            // 
            // btnPanelRentalItems
            // 
            btnPanelRentalItems.BackColor = Color.FromArgb(102, 123, 134);
            btnPanelRentalItems.BackgroundImageLayout = ImageLayout.None;
            btnPanelRentalItems.FlatAppearance.BorderSize = 0;
            btnPanelRentalItems.FlatStyle = FlatStyle.Flat;
            btnPanelRentalItems.Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold);
            btnPanelRentalItems.ForeColor = Color.FromArgb(236, 240, 241);
            btnPanelRentalItems.Location = new Point(0, 165);
            btnPanelRentalItems.Name = "btnPanelRentalItems";
            btnPanelRentalItems.Size = new Size(150, 36);
            btnPanelRentalItems.TabIndex = 2;
            btnPanelRentalItems.Text = "Rented Items";
            btnPanelRentalItems.UseVisualStyleBackColor = false;
            // 
            // panel1
            // 
            panel1.BackColor = Color.FromArgb(127, 140, 141);
            panel1.Dock = DockStyle.Fill;
            panel1.Location = new Point(150, 22);
            panel1.Margin = new Padding(0);
            panel1.Name = "panel1";
            panel1.Size = new Size(650, 428);
            panel1.TabIndex = 3;
            // 
            // FrmMain
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.FromArgb(127, 140, 141);
            BackgroundImageLayout = ImageLayout.None;
            ClientSize = new Size(800, 450);
            Controls.Add(panel1);
            Controls.Add(panelSide);
            Controls.Add(panelTitleBar);
            FormBorderStyle = FormBorderStyle.None;
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "FrmMain";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "Inventory";
            panelTitleBar.ResumeLayout(false);
            panelTitleBar.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)picProgIcon).EndInit();
            ((System.ComponentModel.ISupportInitialize)picAccount).EndInit();
            panelSide.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private Panel panelTitleBar;
        private Button btnTitleBarMinimize;
        private Button btnTitleBarClose;
        private Button btnTitleBarExpand;
        private PictureBox picAccount;
        private Panel panelSide;
        private Label lblNameProgInventory;
        private Button btnPanelInventory;
        private Button btnPanelRentalItems;
        private PictureBox picProgIcon;
        private Label lblUsername;
        private Label lblUserRole;
        private Button btnPanelModeration;
        private Panel panel1;
    }
}
