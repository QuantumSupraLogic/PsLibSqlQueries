function New-ChangeDatabaseRecoveryModelSqlQuery{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $databaseName,
        [Parameter(Mandatory=$true)]
        [ValidateSet('FULL', 'BULK-LOGGED', 'SIMPLE')]
        [string]
        $recoveryModel
    )

    $sqlQuery = "
        USE [master]
        ALTER DATABASE $databaseName SET RECOVERY $recoveryModel"
        
    return $sqlQuery
}