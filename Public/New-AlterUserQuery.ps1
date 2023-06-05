function New-AlterUserQuery{
    [CmdletBinding()]
    param (
        [Parameter()]
        [AddDelimitersTransform()]
        [string] 
        $databaseName,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $userName,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $login
    )
    
    begin {
        
    }
    
    process {
        if ($databaseName) {
        $SqlQuery = "
            USE $databaseName
            GO
            "
        }
        $SqlQuery = "
            ALTER USER $userName WITH LOGIN = $login
        "
    }
    
    end {
        return $SqlQuery
    }
}