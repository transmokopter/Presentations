using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;


namespace StateProvinceApp.Pages.StateProvince
{
    public class IndexModel : PageModel
    {
        public readonly IConfiguration _configuration;
        public IndexModel(IConfiguration configuration)
        {
            _configuration = configuration;
            
        }
        public List<CountryRegionInfo> countryRegionInfoList = new List<CountryRegionInfo>();
        public void OnGet()
        {
            try
            {
                string connectionString = _configuration.GetConnectionString("aw2014");  //"Data Source=aw2014;Initial Catalog=AdventureWorks2014;Persist Security Info=True;User ID=sa;Password=Pa55w.rd;Encrypt=False";

                using(SqlConnection sqlConnection = new SqlConnection(connectionString))
                {
                    sqlConnection.Open();
                    string query = "SELECT CountryRegionCode, Name, ModifiedDate FROM Person.CountryRegion;";
                    using(SqlCommand command = new SqlCommand(query, sqlConnection))
                    {
                        using(SqlDataReader dr = command.ExecuteReader())
                        {
                            while (dr.Read())
                            {
                                CountryRegionInfo cri = new CountryRegionInfo();
                                cri.CountryRegionCode = dr.GetString(0);
                                cri.Name = dr.GetString(1);
                                cri.ModifiedDate = dr.GetDateTime(2);
                                countryRegionInfoList.Add(cri);
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {

                throw;
            }
        }
    }
    public class CountryRegionInfo
    {
        public string CountryRegionCode;
        public string Name;
        public DateTime ModifiedDate;
    }
}
