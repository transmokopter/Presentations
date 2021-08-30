using System;
using System.Text.RegularExpressions;

namespace tdd_intro
{
    public class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("I'm not really going to use Main today...");
        }
        public static bool IsValidDate(string inDate)
        {
            var r = new Regex("\\d\\d\\d\\d-\\d\\d-\\d\\d");
            var m = r.Match(inDate);
            // New requirement. American date format also valid
            // var rAmerican = new Regex("\\d\\d/\\d\\d/\\d\\d\\d\\d");
            // var mAmerican = rAmerican.Match(inDate);
            // return m.Success || mAmerican.Success
            return m.Success;

        }
    }
}
