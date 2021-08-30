using Microsoft.VisualStudio.TestTools.UnitTesting;
using tdd_intro;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace tdd_intro.Tests
{
    [TestClass()]
    public class ProgramTests
    {
        [TestMethod()]
        public void IsValidDateTest_PositiveTest_StringFormat()
        {
            Assert.IsTrue(tdd_intro.Program.IsValidDate("2021-08-30"));
        }
        [TestMethod()]
        public void IsValidDateTest_NegativeTest_StringFormat()
        {
            Assert.IsFalse(tdd_intro.Program.IsValidDate("08/30/2021"));
        }
    }
}