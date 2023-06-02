function New-DropUserQuery{
    [CmdletBinding()]
    param (
        [Parameter()]
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