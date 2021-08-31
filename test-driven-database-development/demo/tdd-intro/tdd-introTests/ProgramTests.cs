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
        [TestMethod("European Date Format is OK")]
        public void IsValidDateTestPositiveEuropeanDateFormat()
        {
            Assert.IsTrue(tdd_intro.Program.IsValidDate("2021-08-30"));
        }
        [TestMethod("American Date Format is OK")]
        public void IsValidDateTestNegativeAmericanDateFormat()
        {
            Assert.IsTrue(tdd_intro.Program.IsValidDate("08/30/2021"));
        }
    }
}