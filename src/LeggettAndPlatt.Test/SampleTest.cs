using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LeggettAndPlatt.Test
{
    [TestFixture]
    public class SampleTest
    {
        [TestCase]
        public void SampleMethod()
        {
            Double currentValue = 10.10;
            Double updatedValue = 10.10;

            Assert.AreEqual(currentValue,updatedValue);
        }
        [TestCase]
        [Ignore("This method is skipping")]
        public void Test()
        {
        }

    }
}
