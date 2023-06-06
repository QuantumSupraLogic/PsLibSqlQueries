function New-GetDataPathQuery {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $databaseName
    )
    $query = "
        USE $databaseName
        SELECT physical_name FROM sys.database_files WHERE TYPE = 1"

    return $query
}