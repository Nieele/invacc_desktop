using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace invacc
{
    internal class MessageHelper
    {
        public static void InfoRegistrationSuccess()
        {
            MessageBox.Show("Registration was successful", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        public static void ErrorUserAlreadyExist()
        {
            MessageBox.Show("User already exists.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public static void ErrorUnableConnectDB()
        {
            MessageBox.Show("Unable to connect to the database.\nMake sure that PostgreSQL is running", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public static void ErrorUnableConnectOrFailedEntry()
        {
            MessageBox.Show("Unable to connect to the database.\nMake sure that PostgreSQL is running", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public static void ErrorDifferentPassword()
        {
            MessageBox.Show("The passwords are different", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public static void ErrorShortPassword()
        {
            MessageBox.Show("The password cannot be less than 4", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
