using Npgsql;
using System.Drawing;

namespace invacc
{
    public partial class FrmMain : Form
    {
        private NpgsqlConnection _session;

        public FrmMain(NpgsqlConnection session)
        {
            InitializeComponent();
            _session = session;
            WindowMover.Attach(this, panelTitleBar, lblNameProgInventory, picProgIcon);

            lblUsername.Text = DatabaseHelper.GetCurrentUser(_session);
            lblUserRole.Text = DatabaseHelper.GetUserRole(_session);

            OpenChildForm(new rentedItemsForm());
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
