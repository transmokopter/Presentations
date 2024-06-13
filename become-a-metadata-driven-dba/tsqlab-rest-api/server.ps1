Start-PodeServer {
    Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http 
    Add-PodeEndpoint -Address 10.1.0.5 -Port 8080 -Protocol Http

    Add-PodeRoute -Method Get -Path 'GetSchedule' -ScriptBlock {
        $result = Get-Content "$psscriptroot\..\metadata\schedules.json" | ConvertFrom-Json

        $result | Get-Member | ForEach-Object{
            $property = $PSItem.Name 
            $propertyValue = $WebEvent.Query[$property]
            if($null -ne $propertyValue -and "" -ne $propertyValue){
                $result = $result | Where-Object { $PSItem.$property -eq $propertyValue}
            }
        }
        if($null -eq $result){
            $result = "" | ConvertTo-Json
        }
        Write-PodeJsonResponse -Value $result 
    }-PassThru | 
    Set-PodeOARequest -Parameters @(
        (New-PodeOAStringProperty -Name 'ServerName' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'InstanceName' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'JobName' | ConvertTo-PodeOAParameter -In Query)
    )

    Add-PodeRoute -Method Get -Path '/GetServer' -ScriptBlock {
        $result = Get-Content "$psscriptroot\..\metadata\servers.json" | ConvertFrom-Json

        $result | Get-Member | ForEach-Object{
            $property = $PSItem.Name
            $propertyValue = $WebEvent.Query[$property]
            if($null -ne $propertyValue -and "" -ne $propertyValue){
                $result = $result | Where-Object { $PSItem.$property -eq $propertyValue }
            }
        }
        if($null -eq $result){
            $result = ""| ConvertTo-Json
        }
        Write-PodeJsonResponse -Value $result 
    }-PassThru |
    Set-PodeOARequest -Parameters @(
        (New-PodeOAStringProperty -Name 'ServerName' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'OperatingSystem' | ConvertTo-PodeOAParameter -In Query)
    )

    Add-PodeRoute -Method Get -Path '/GetSqlInstance'-ScriptBlock {
        $result = Get-Content "$psscriptroot\..\metadata\sql-instances.json" | ConvertFrom-Json

        $result | Get-Member | ForEach-Object{
            $property = $PSItem.Name
            $propertyValue = $WebEvent.Query[$property]
            if($null -ne $propertyValue -and "" -ne $propertyValue){
                $result = $result | Where-Object { $PSItem.$property -eq $propertyValue }
            }
        }
        if($null -eq $result){
            $result = ""| ConvertTo-Json
        }
        Write-PodeJsonResponse -Value $result 
    } -PassThru |
    Set-PodeOARequest -Parameters @(
        (New-PodeOAStringProperty -Name 'ServerName' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'InstanceName' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'SqlVersion' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'Tier' | ConvertTo-PodeOAParameter -In Query),
        (New-PodeOAStringProperty -Name 'ConnectionName' | ConvertTo-PodeOAParameter -In Query)
    )



    Enable-PodeOpenApi -Path '/docs/openapi' -Title 'Become a metadata driven DBA Api' -Version "1.0.0-latest"
    Enable-PodeOpenApiViewer -Type Swagger -DarkMode
}

