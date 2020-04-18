#To install - use Install-Module

Install-Module DBATOOLS -Repository PSGALLERY -Scope AllUsers;

#To update, use built in command Update-DbaTools

Update-DbaTools;

#First lest's create login credentials

$secpwd = ConvertTo-SecureString -AsPlainText "Pa55w.rd" -Force
$cred = New-Object pscredential("sa",$secpwd)

#Some commandlets

#Find SQL Server services on a machine

Get-DbaService -Server sql1;
#Filter for Engine servie only
Get-DbaService -Server sql1 -Type Engine;
#Explore members of the returned object
Get-DbaService -Server sql1 -Type Engine | Get-Member;
#Customize result set
Get-DbaService -Server sql1 -Type Engine | Select-Object -Property ComputerName, ServiceType, ServiceName, Description, @{N='ServiceStatus';E={$_.State}};
#Get output as table 
Get-DbaService -Server localhost -Type Engine | Select-Object -Property ComputerName, ServiceType, ServiceName, Description, @{N='ServiceStatus';E={$_.State}}|format-table;

#Let's install some packages I consider standard
#And while I'm at it, there are some things I consider standard on a database instance
#I like putting them in their own database instead of master
$dbname = "DBA"
New-DbaDatabase -SqlInstance sql1 -SqlCredential $cred -name $dbname -owner sa 

Install-DbaMaintenanceSolution -sqlinstance sql1 -SqlCredential $cred -Database $dbname 
Install-DbaFirstResponderKit -SqlInstance sql1 -SqlCredential $cred -Database $dbname 
Install-DbaWhoIsActive -SqlInstance sql1 -SqlCredential $cred -Database $dbname 

$DBALoginpwd=ConvertTo-SecureString -AsPlaintext "Pa55w.rd" -Force
New-DbaLogin -SqlInstance sql1 -SqlCredential $cred -Login DBALogin -Password $DBALoginpwd -PasswordPolicyEnforced:$false

