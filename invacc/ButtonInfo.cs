using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace invacc
{
    class ButtonInfo(string name, Action action)
    {
        public string Name { get; } = name;
        public Action Action { get; } = action;
    }
}
