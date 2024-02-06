Set-StrictMode -Version 3.0

function New-CreateSnapshotQuery {
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

            declare @mytime varchar(50);
            declare @dbname varchar (50);
            declare @dbfilename varchar (50);
            declare @snapshot varchar(100);
            declare @filename varchar(200);
            declare @query varchar(500);
            set @dbname = DB_NAME();
            select @dbfilename = f.name
            FROM sys.master_files f
            INNER JOIN sys.databases d ON d.database_id = f.database_id and d.name =  DB_NAME() and f.type = 0;;
            set @mytime =  cast(datepart(year, CURRENT_TIMESTAMP) as varchar)+substring( cast(100+datepart(month, CURRENT_TIMESTAMP) as varchar), 2,2)+substring( cast(100+datepart(day, CURRENT_TIMESTAMP) as varchar), 2,2)+'_'+substring( cast(100+datepart(hour, CURRENT_TIMESTAMP) as varchar), 2,2)+substring( cast(100+datepart(minute, CURRENT_TIMESTAMP) as varchar), 2,2)+substring( cast(100+datepart(second, CURRENT_TIMESTAMP) as varchar), 2,2);
            set @snapshot = @dbname+'_'+@mytime;
            set @filename = $folderName + @snapshot + '.ss';
            set @query = 'create database '+  @snapshot + ' on (NAME = ' + @dbfilename +', FILENAME = '''+@filename +''') AS SNAPSHOT OF '+@dbname
            select @snapshot, @filename, @query;

            EXECUTE (@query);"
    }
    
    end {
        return $SqlQuery
    }
}