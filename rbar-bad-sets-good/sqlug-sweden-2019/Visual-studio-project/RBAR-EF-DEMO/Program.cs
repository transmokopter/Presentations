using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Web.Script.Serialization;
using System.Data.SqlClient;
using System.Data;

namespace RBAR_EF_DEMO
{
    class Program
    {
            static List<Person> TestSomething()
        {
            using (var client = new WebClient())
            {
                //Talk to Daniel at strd.co to get an API key allowing more than 200 people downloaded. http://anonymize.strd.co 
                var json = client.DownloadString("https://anonymize.strd.co/json?culture=SE&rows=200&token=00000000-0000-0000-0000-000000000000");
                var serializer = new JavaScriptSerializer();
                List<Person> model = serializer.Deserialize<List<Person>>(json);
                return model;
            }
        }
        static void Main(string[] args)
        {

           PeopleCollection p = new PeopleCollection(TestSomething());
            //When running second attempt, after changing the PeopleColletion class, comment out from here
            using (var ctx = new RBARContext()) {
                foreach (Person pe in p) 
                {
                    ctx.People.Add(pe);
                }
                ctx.SaveChanges();
            } //down to here
/* Then uncomment this section
            using (SqlConnection cn = new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["RBAREFDEMO"].ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("dbo.InsertLotsOfPeople", cn);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                var PeoplesParam=cmd.Parameters.AddWithValue("@people", p);
                PeoplesParam.SqlDbType =  SqlDbType.Structured;
                cmd.ExecuteNonQuery();
                cn.Close();

            }
            */
        }
    }
}
