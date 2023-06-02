function New-RestoreFromLatestSnapshotQuery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [AddDelimitersTransform()]
        [string] 
        $databaseName,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $folderName
    )
    
    begin {
        
    }
    
    process {
        $SqlQuery = "
            use $databaseName
            go

            declare @dbname varchar (50);
            declare @snapshot varchar(100);
            declare @dbid varchar (10);
            declare @query1 varchar(500);
            declare @query2 varchar(500);
            declare @query3 varchar(500);
            
            set @dbid = DB_ID();
            set @dbname = DB_NAME();
            select Top 1 @snapshot = name from sys.databases where source_database_id = @dbid order by create_date desc
            select DB_ID()
            select @snapshot
            
            select * from sys.databases where source_database_id = @dbid
            set @query1 = 'ALTER DATABASE ['+@dbname+'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
            set @query2 = 'RESTORE DATABASE ['+@dbname+'] from DATABASE_SNAPSHOT = '''+@snapshot+''''
            set @query3 = 'ALTER DATABASE ['+@dbname+'] SET MULTI_USER'
            
            USE master;
            select @dbname
            select @query1
            select @query2
            select @query3
            
            execute (@query1)
            execute (@query2)
            execute (@query3)"
    }
    
    end {
        return $SqlQuery
    }
}