Set-StrictMode -Version 3.0

function New-GetLogPathQuery {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $databaseName
    )
    $query = "
        USE $databaseName
        SELECT 
            physical_name 
        FROM 
            sys.database_files 
        WHERE 
            type = 1 and 
            state = 0"

    return $query
}