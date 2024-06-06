Function Get-TsqlAbServer{
    param(
        [string]$ServerName = ""
    )
    Invoke-RestMethod "http://localhost:8080/GetServer?ServerName=$ServerName"
}