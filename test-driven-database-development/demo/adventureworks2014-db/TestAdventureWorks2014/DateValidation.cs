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
        public void TestIsLeapYearNegative2003()
        {
            SqlDatabaseTestActions testActions = this.TestIsLeapYearNegative2003Data;
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
        [TestMethod()]
        public void TestIsLeapYearNegative1900()
        {
            SqlDatabaseTestActions testActions = this.TestIsLeapYearNegative1900Data;
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
        [TestMethod()]
        public void TestIsLeapYearPositive1996()
        {
            SqlDatabaseTestActions testActions = this.TestIsLeapYearPositive1996Data;
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
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction TestIsLeapYearNegative2003_TestAction;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(DateValidation));
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition Test2003IsNotLeapYear;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction TestIsLeapYearNegative1900_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition TestLeapYearNegative1900;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction TestIsLeapYearPositive1996_TestAction;
            Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition TestIsLeapYearPositive1996;
            this.TestIsLeapYearNegative2003Data = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.TestIsLeapYearNegative1900Data = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            this.TestIsLeapYearPositive1996Data = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestActions();
            TestIsLeapYearNegative2003_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            Test2003IsNotLeapYear = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            TestIsLeapYearNegative1900_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            TestLeapYearNegative1900 = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            TestIsLeapYearPositive1996_TestAction = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.SqlDatabaseTestAction();
            TestIsLeapYearPositive1996 = new Microsoft.Data.Tools.Schema.Sql.UnitTesting.Conditions.ScalarValueCondition();
            // 
            // TestIsLeapYearNegative2003_TestAction
            // 
            TestIsLeapYearNegative2003_TestAction.Conditions.Add(Test2003IsNotLeapYear);
            resources.ApplyResources(TestIsLeapYearNegative2003_TestAction, "TestIsLeapYearNegative2003_TestAction");
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
            // 
            // TestIsLeapYearNegative1900_TestAction
            // 
            TestIsLeapYearNegative1900_TestAction.Conditions.Add(TestLeapYearNegative1900);
            resources.ApplyResources(TestIsLeapYearNegative1900_TestAction, "TestIsLeapYearNegative1900_TestAction");
            // 
            // TestLeapYearNegative1900
            // 
            TestLeapYearNegative1900.ColumnNumber = 1;
            TestLeapYearNegative1900.Enabled = true;
            TestLeapYearNegative1900.ExpectedValue = "0";
            TestLeapYearNegative1900.Name = "TestLeapYearNegative1900";
            TestLeapYearNegative1900.NullExpected = false;
            TestLeapYearNegative1900.ResultSet = 1;
            TestLeapYearNegative1900.RowNumber = 1;
            // 
            // TestIsLeapYearNegative2003Data
            // 
            this.TestIsLeapYearNegative2003Data.PosttestAction = null;
            this.TestIsLeapYearNegative2003Data.PretestAction = null;
            this.TestIsLeapYearNegative2003Data.TestAction = TestIsLeapYearNegative2003_TestAction;
            // 
            // TestIsLeapYearNegative1900Data
            // 
            this.TestIsLeapYearNegative1900Data.PosttestAction = null;
            this.TestIsLeapYearNegative1900Data.PretestAction = null;
            this.TestIsLeapYearNegative1900Data.TestAction = TestIsLeapYearNegative1900_TestAction;
            // 
            // TestIsLeapYearPositive1996Data
            // 
            this.TestIsLeapYearPositive1996Data.PosttestAction = null;
            this.TestIsLeapYearPositive1996Data.PretestAction = null;
            this.TestIsLeapYearPositive1996Data.TestAction = TestIsLeapYearPositive1996_TestAction;
            // 
            // TestIsLeapYearPositive1996_TestAction
            // 
            TestIsLeapYearPositive1996_TestAction.Conditions.Add(TestIsLeapYearPositive1996);
            resources.ApplyResources(TestIsLeapYearPositive1996_TestAction, "TestIsLeapYearPositive1996_TestAction");
            // 
            // TestIsLeapYearPositive1996
            // 
            TestIsLeapYearPositive1996.ColumnNumber = 1;
            TestIsLeapYearPositive1996.Enabled = true;
            TestIsLeapYearPositive1996.ExpectedValue = "1";
            TestIsLeapYearPositive1996.Name = "TestIsLeapYearPositive1996";
            TestIsLeapYearPositive1996.NullExpected = false;
            TestIsLeapYearPositive1996.ResultSet = 1;
            TestIsLeapYearPositive1996.RowNumber = 1;
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
        private SqlDatabaseTestActions TestIsLeapYearNegative2003Data;
        private SqlDatabaseTestActions TestIsLeapYearNegative1900Data;
        private SqlDatabaseTestActions TestIsLeapYearPositive1996Data;
    }
}
