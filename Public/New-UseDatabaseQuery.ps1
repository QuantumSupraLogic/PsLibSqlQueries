function New-ShrinkDatabaseQuery{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $databaseName
    )
    
    begin {
        
    }
    
    process {
        $SqlQuery = "
            USE DATABASE $databaseName
            GO
            "
    }
    
    end {
        return $SqlQuery
    }
}