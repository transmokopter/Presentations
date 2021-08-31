using Microsoft.Data.Tools.Schema.Sql.UnitTesting;
using Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Text;

namespace TestAdventureWorks2014
{
    [TestClass()]
    public class DateValidation : SqlDatabaseTestClass
    {

        public DateValidation()
        {
            InitializeComponent();
        }

        [TestInitialize()]
        public void TestInitialize()
        {
            base.InitializeTest();
        }
        [TestCleanup()]
        public void TestCleanup()
        {
            base.CleanupTest();
        }

        [TestMethod()]
        public void TestIsLeapYearPositive2004()
        {
            SqlDatabaseTestActions testActions = this.TestIsLeapYearPositive2004Data;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            // Execute the test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
            SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            // Execute the post-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
            SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
        }
        [TestMethod()]
        public void TestLeapYearNegative2003()
        {
            SqlDatabaseTestActions testActions = this.TestLeapYearNegative2003Data;
            // Execute the pre-test script
            // 
            System.Diagnostics.Trace.WriteLineIf((testActions.PretestAction != null), "Executing pre-test script...");
            SqlExecutionResult[] pretestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PretestAction);
            try
            {
                // Execute the test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.TestAction != null), "Executing test script...");
                SqlExecutionResult[] testResults = TestService.Execute(this.ExecutionContext, this.PrivilegedContext, testActions.TestAction);
            }
            finally
            {
                // Execute the post-test script
                // 
                System.Diagnostics.Trace.WriteLineIf((testActions.PosttestAction != null), "Executing post-test script...");
                SqlExecutionResult[] posttestResults = TestService.Execute(this.PrivilegedContext, this.PrivilegedContext, testActions.PosttestAction);
            }
        }


        #region Designer support code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction TestIsLeapYearPositive2004_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DateValidation));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition Test2004IsLeapYear;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction TestLeapYearNegative2003_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition Test2003IsNotLeapYear;
            this.TestIsLeapYearPositive2004Data = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.TestLeapYearNegative2003Data = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            TestIsLeapYearPositive2004_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            Test2004IsLeapYear = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            TestLeapYearNegative2003_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            Test2003IsNotLeapYear = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            // 
            // TestIsLeapYearPositive2004Data
            // 
            this.TestIsLeapYearPositive2004Data.PosttestAction = null;
            this.TestIsLeapYearPositive2004Data.PretestAction = null;
            this.TestIsLeapYearPositive2004Data.TestAction = TestIsLeapYearPositive2004_TestAction;
            // 
            // TestIsLeapYearPositive2004_TestAction
            // 
            TestIsLeapYearPositive2004_TestAction.Conditions.Add(Test2004IsLeapYear);
            resources.ApplyResources(TestIsLeapYearPositive2004_TestAction, "TestIsLeapYearPositive2004_TestAction");
            // 
            // Test2004IsLeapYear
            // 
            Test2004IsLeapYear.ColumnNumber = 1;
            Test2004IsLeapYear.Enabled = true;
            Test2004IsLeapYear.ExpectedValue = "1";
            Test2004IsLeapYear.Name = "Test2004IsLeapYear";
            Test2004IsLeapYear.NullExpected = false;
            Test2004IsLeapYear.ResultSet = 1;
            Test2004IsLeapYear.RowNumber = 1;
            // 
            // TestLeapYearNegative2003Data
            // 
            this.TestLeapYearNegative2003Data.PosttestAction = null;
            this.TestLeapYearNegative2003Data.PretestAction = null;
            this.TestLeapYearNegative2003Data.TestAction = TestLeapYearNegative2003_TestAction;
            // 
            // TestLeapYearNegative2003_TestAction
            // 
            TestLeapYearNegative2003_TestAction.Conditions.Add(Test2003IsNotLeapYear);
            resources.ApplyResources(TestLeapYearNegative2003_TestAction, "TestLeapYearNegative2003_TestAction");
            // 
            // Test2003IsNotLeapYear
            // 
            Test2003IsNotLeapYear.ColumnNumber = 1;
            Test2003IsNotLeapYear.Enabled = true;
            Test2003IsNotLeapYear.ExpectedValue = "0";
            Test2003IsNotLeapYear.Name = "Test2003IsNotLeapYear";
            Test2003IsNotLeapYear.NullExpected = false;
            Test2003IsNotLeapYear.ResultSet = 1;
            Test2003IsNotLeapYear.RowNumber = 1;
        }

        #endregion


        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        #endregion

        private SqlDatabaseTestActions TestIsLeapYearPositive2004Data;
        private SqlDatabaseTestActions TestLeapYearNegative2003Data;
    }
}
