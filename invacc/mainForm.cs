using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Npgsql;
using System.Drawing;

namespace invacc
{
    public partial class FrmMain : Form
    {
        private NpgsqlConnection _session;
        private Dictionary<string, List<ButtonInfo>> roleButtons;

        public FrmMain(NpgsqlConnection session)
        {
            InitializeComponent();

            _session = session;
            WindowMover.Attach(this, panelTitleBar, lblNameProgInventory, picProgIcon);

            lblUsername.Text = DatabaseHelper.GetCurrentUser(_session);
            lblUserRole.Text = DatabaseHelper.GetUserRole(_session);

            InitializeRoleButtons();
            LoadButtonsForRole(lblUserRole.Text);
        }

        private void InitializeRoleButtons()
        {
            roleButtons = new Dictionary<string, List<ButtonInfo>>
            {
                ["Admin"] =
                    [
                        new ButtonInfo("Status", ShowStatus)
                    ],

                ["Moderator"] =
                    [
                        new ButtonInfo("Status", ShowStatus),
                        new ButtonInfo("Moderation", ShowModeration)
                    ],

                ["Director"] =
                    [
                        new ButtonInfo("Status", ShowStatus),
                        new ButtonInfo("Moderation", ShowModeration)
                    ],

                ["Marketing specialist"] =
                    [
                        new ButtonInfo("Status", ShowStatus),
                        new ButtonInfo("Moderation", ShowModeration)
                    ],

                ["Inventory manager"] =
                    [
                        new ButtonInfo("Status", ShowStatus),
                        new ButtonInfo("Moderation", ShowModeration)
                    ],

                ["Worker"] =
                    [
                        new ButtonInfo("Status", ShowStatus),
                        new ButtonInfo("Moderation", ShowModeration)
                    ],

                ["Unknown"] =
                    [
                        new ButtonInfo("Info", ShowInfo)
                    ]
            };
        }

        private void LoadButtonsForRole(string role)
        {
            if (roleButtons.TryGetValue(role, out List<ButtonInfo>? value))
            {
                int topOffset = 160;
                int buttonSpacing = 5;

                foreach (var buttonInfo in value)
                {
                    Button btn = new()
                    {
                        BackColor = Color.FromArgb(102, 123, 134),
                        BackgroundImageLayout = ImageLayout.None,
                        FlatStyle = FlatStyle.Flat,
                        Font = new Font("UD Digi Kyokasho NP-B", 9F, FontStyle.Bold),
                        ForeColor = Color.FromArgb(236, 240, 241),
                        UseVisualStyleBackColor = false,
                        Text = buttonInfo.Name,
                        Width = panelSide.Width,
                        Height = 40,
                        Top = topOffset
                    };

                    btn.FlatAppearance.BorderSize = 0;

                    btn.Click += (sender, e) => buttonInfo.Action();

                    panelSide.Controls.Add(btn);

                    topOffset += btn.Height + buttonSpacing;
                }
            }
        }

        private void ShowStatus()
        {
            MessageBox.Show("Status panel opened.");
        }

        private void ShowModeration()
        {
            MessageBox.Show("Moderation panel opened.");
        }

        private void ShowInfo()
        {
            MessageBox.Show("Info panel opened.");
        }

        private void BtnTitleBarClose_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void BtnTitleBarExpand_Click(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Normal || this.WindowState == FormWindowState.Minimized)
            {
                this.WindowState = FormWindowState.Maximized;
            }
            else if (this.WindowState == FormWindowState.Maximized)
            {
                this.WindowState = FormWindowState.Normal;
            }
        }

        private void BtnTitleBarMinimize_Click(object sender, EventArgs e)
        {
            this.WindowState = FormWindowState.Minimized;
        }

        private Form? activeForm = null;
        private void OpenChildForm(Form childForm)
        {
            if (activeForm != null)
            {
                activeForm.Close();
            }
            activeForm = childForm;
            childForm.TopLevel = false;
            childForm.FormBorderStyle = FormBorderStyle.None;
            childForm.Dock = DockStyle.Fill;
            panelDataInfo.Controls.Add(childForm);
            panelDataInfo.Tag = childForm;
            childForm.BringToFront();
            childForm.Show();
        }

        private void BtnPanelRentalItems_Click(object sender, EventArgs e)
        {
            OpenChildForm(new rentedItemsForm());
        }

        private void BtnPanelInventory_Click(object sender, EventArgs e)
        {
            OpenChildForm(new inventoryForm());
        }

        private void BtnPanelModeration_Click(object sender, EventArgs e)
        {
            OpenChildForm(new moderationForm());
        }

        private void BtnLogout_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
