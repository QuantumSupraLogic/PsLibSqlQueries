function New-UseDatabaseQuery{
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
            USE $databaseName
            GO
            "
    }
    
    end {
        return $SqlQuery
    }
}