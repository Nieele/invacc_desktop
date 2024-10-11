using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.StartPanel;

namespace invacc
{
    internal class DatabaseHelper
    {
        public enum ReturnState
        {
            OK,
            ErrorConnection,
            UserAlreadyExist,
            UnknownError
        }

        public static NpgsqlConnection CreateRegisterConnection()
        {
            string connectionString = $"Server=localhost;Port=5432;User Id=register;Password=password;Database=RentalDB;Pooling=false;";
            return new NpgsqlConnection(connectionString);
        }

        public static ReturnState ExecuteRegisterQuery(string username, string password)
        {
            string query = $"CREATE USER {username} LOGIN PASSWORD '{password}';";

            using (var con = CreateRegisterConnection())
            {
                try
                {
                    con.Open();
                    using (var cmd = new NpgsqlCommand(query, con))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                catch (PostgresException ex)
                {
                    if (ex.SqlState == "42710")
                    {
                        return ReturnState.UserAlreadyExist;
                    }
                    if (con.State == ConnectionState.Closed)
                    {
                        return ReturnState.ErrorConnection;
                    }
                }
                catch (Exception ex)
                {
                    return ReturnState.UnknownError;
                }
                finally
                {
                    con.Close();
                }
            }

            return ReturnState.OK;
        }

        public static NpgsqlConnection CreateLoginConnection(string username, string password)
        {
            string connectionString = $"Server=localhost;Port=5432;User Id={username};Password={password};Database=RentalDB;Pooling=false;";
            return new NpgsqlConnection(connectionString);
        }

        public static ReturnState ExecuteLoginQuery(NpgsqlConnection con)
        {
            try
            {
                con.Open();
                if (con.State == ConnectionState.Open)
                {
                    return ReturnState.OK;
                }
            }
            catch
            {
                if (con.State == ConnectionState.Closed)
                {
                    return ReturnState.ErrorConnection;
                }
            }
            return ReturnState.UnknownError;
        }
    }
}
