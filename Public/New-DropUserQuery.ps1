Set-StrictMode -Version 3.0

function New-DropUserQuery{
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
            DROP USER IF EXISTS $userName
        "
    }
    
    end {
        return $SqlQuery
    }
}