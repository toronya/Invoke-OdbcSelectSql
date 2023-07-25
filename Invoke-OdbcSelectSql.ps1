function Invoke-OdbcSelectSql
{
  param (
    [string]$conString,
    [ValidateScript({$_ -match '\bselect\b'})] [string]$sqlString,
    [string]$sqlFilePath,
    $con,
    [string]$DateFormatString = "yyyy/MM/dd",
    [string]$DateTimeFormatString = "yyyy/MM/dd HH:mm:ss",
    $timeout = 36000
  )
  begin{
    if ($sqlString -eq ""){
        if ($sqlFilePath -ne "" -and (Test-Path -Path $sqlFilePath) -eq $true ) {
          [string]$sqlString = (Get-Content $sqlFilePath)
        }else{
          Write-Error ("Required : -sqlString or -sqlFilePath")
          exit
        }
      }

    if($null -eq $con){
        $createCon = $true
        $con = New-Object System.Data.Odbc.OdbcConnection($conString)
        $con.Open()
    }else{
        $createCon = $false
    }
  }
  
#---------------------------------------------------

    process{
        $cmd = New-Object System.Data.Odbc.OdbcCommand
        $cmd.CommandTimeout = $timeout
        $cmd.Connection = $con
        $cmd.CommandText = $sqlString

        $rdr = $cmd.ExecuteReader()

        # HEADER
        $columnNames = @()
        $columnNames = @($rdr.GetSchemaTable() | Select-Object -ExpandProperty ColumnName)
          
        # BODY
        $LineCount = 0
        while ($rdr.Read()) {
            $result = [ordered]@{}
            for ($i=0; $i -lt $rdr.FieldCount; $i++) {
              $clm = $rdr[$i]
              if ($null -eq $clm){
                $clm = ""
              }elseif($clm -is [byte[]]){
                $clm = [System.Convert]::ToBase64String($clm)
              }elseif($clm -is [DateTime]){
                if ($clm.Hour -eq 0 -and $clm.Minute -eq 0 -and $clm.Second -eq 0 ){
                  $clm = ([DateTime]$clm).toString($DateFormatString)
                }else{
                  $clm = ([DateTime]$clm).toString($DateTimeFormatString)
                }
              }
              $result.Add($columnNames[$i], $clm)
            }
            # Hash to PSCustomObject
            [PSCustomObject]$result
        }
    }
    end{
        if($createCon -eq $true){
            $con.close()
            $con.dispose()
        }
    } 
}
