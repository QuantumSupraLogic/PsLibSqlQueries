function New-ShrinkDatabaseQuery{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $databaseName,
        [Parameter()]
        [int] 
        $targetPercentage = 1
    )
    
    begin {
        
    }
    
    process {
        $SqlQuery = "
            DBCC SHRINKDATABASE $databaseName, $targetPercentage
            "
    }
    
    end {
        return $SqlQuery
    }
}