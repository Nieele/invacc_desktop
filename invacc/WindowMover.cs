using System.Runtime.InteropServices;

namespace invacc
{
    internal class WindowMover
    {
        [DllImport("user32.dll")]
        private static extern int SendMessage(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr LPAR);

        [DllImport("user32.dll")]
        private static extern bool ReleaseCapture();

        private const int WM_NCLBUTTONDOWN = 0xA1;
        private const int HT_CAPTION = 0x2;

        // Attach mouse event handlers for moving the window
        public static void Attach(Form form, params Control[] controls)
        {
            form.MouseDown += (sender, e) => MoveWindow(form, e);

            foreach (var control in controls)
            {
                control.MouseDown += (sender, e) => MoveWindow(form, e);
            }
        }

        private static void MoveWindow(Form form, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                ReleaseCapture();
                SendMessage(form.Handle, WM_NCLBUTTONDOWN, (IntPtr)HT_CAPTION, IntPtr.Zero);
            }
        }
    }
}
