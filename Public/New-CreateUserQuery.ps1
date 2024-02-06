Set-StrictMode -Version 3.0

function New-CreateUserQuery{
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
        $userName
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
            CREATE USER $userName
        "
    }
    
    end {
        return $SqlQuery
    }
}