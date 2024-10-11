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
        }
    }
}
