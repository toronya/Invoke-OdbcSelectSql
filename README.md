# Invoke-OdbcSelectSql
This is a PowerShell script that issues SQL queries ODBC connection.

## Exapmle

```powershell

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Set-Location C:\workspace\powershell_odbc\

Import-Module .\Invoke-OdbcSelectSql.ps1

Invoke-OdbcSelectSql -conString "dsn=postgres_x64" -sqlString "select * from work.test" |
ConvertTo-Csv -NoTypeInformation |
ForEach-Object {$_ -replace '"',''} |
Out-File -FilePath ".\test.csv" -Encoding Default

```
