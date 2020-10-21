using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.SqlServer.Server;
using System.Data;

namespace RBAR_EF_DEMO
{
    public class Person
    {
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int ID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Gender { get; set; }
        public int Age { get; set; }
        public string Address { get; set; }
        public string ZipCode { get; set; }
        public string Location { get; set; }
        public DateTime BirthDate { get; set; }
        public string PersonNummer { get; set; }
    }
    public class RBARContext : DbContext
    {
        public RBARContext() : base("name=RBAREFDEMO" ) { }

        public DbSet<Person> People{ get;set;}
    }

/*    When running second attempt, first uncomment this method, and comment out the version of it below.
 *    
 *    public class PeopleCollection : List<Person>, IEnumerable<SqlDataRecord>
    {
        public PeopleCollection(List<Person> pl) : base(pl) { }

        IEnumerator<SqlDataRecord> IEnumerable<SqlDataRecord>.GetEnumerator()
        {
            var sdr = new SqlDataRecord(
             new SqlMetaData("ID", SqlDbType.Int),
             new SqlMetaData("FirstName", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("LastName", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("Gender", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("Age", SqlDbType.Int),
             new SqlMetaData("Address", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("ZipCode", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("Location", SqlDbType.NVarChar, SqlMetaData.Max),
             new SqlMetaData("BirthDate", SqlDbType.DateTime),
            new SqlMetaData("PersonNummer", SqlDbType.NVarChar, SqlMetaData.Max));

            foreach (Person p in this)
            {
                sdr.SetInt32(0, p.ID);
                sdr.SetString(1, p.FirstName);
                sdr.SetString(2, p.LastName);
                sdr.SetString(3, p.Gender);
                sdr.SetInt32(4, p.Age);
                sdr.SetString(5, p.Address);
                sdr.SetString(6, p.ZipCode);
                sdr.SetString(7, p.Location);
                sdr.SetDateTime(8, p.BirthDate);
                sdr.SetString(9, p.PersonNummer);

                yield return sdr;
            }
        }
    }
  */
    public class PeopleCollection : List<Person>
    {
        public PeopleCollection(List<Person> pl) : base(pl) { }
        
    }
}
