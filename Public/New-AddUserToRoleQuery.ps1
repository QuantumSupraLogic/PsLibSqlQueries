function New-AddUserToRoleQuery {
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
        $role
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
            ALTER ROLE $role ADD MEMBER $userName
        "
    }
    
    end {
        return $SqlQuery
    }
}