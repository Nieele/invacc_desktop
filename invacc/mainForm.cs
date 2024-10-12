using Npgsql;

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
    }
}
