Function Get-TSqlAbSqlInstance {
    param(
        [string] $ServerName = "",
        [string] $InstanceName = "",
        [string] $SqlVersion = "",
        [string] $Tier = "",
        [string] $ConnectionName = ""
    )
    $instances = Invoke-RestMethod "http://localhost:8080/GetSqlInstance?ServerName=$ServerName&InstanceName=$InstanceName&SqlVersion=$SqlVersion&Tier=$Tier&ConnectionName=$ConnectionName"
    $instances 
}