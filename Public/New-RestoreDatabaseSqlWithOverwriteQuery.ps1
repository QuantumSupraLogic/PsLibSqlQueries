function New-RestoreDatabaseSqlWithOverwriteQuery {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dstDataSource,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dstDatabaseName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupLocation,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $dataPathNewDb,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $logPathNewDb
    )
    if (!(Get-Module 'PsLibSqlTools')) {
        Import-Module PsLibSqlTools
    }

    $query = "
        SET NOCOUNT ON;
        DECLARE @FileListCmd            nvarchar(max);
        DECLARE @RestoreCmd             nvarchar(max);
        DECLARE @cmd                    nvarchar(max);
        DECLARE @BackupFile             nvarchar(max);
        DECLARE @DBName                 sysname;
        DECLARE @DataPath               nvarchar(260);
        DECLARE @LogPath                nvarchar(260);
        DECLARE @Version                decimal(10,2);
        DECLARE @MaxLogicalNameLength   int;
        DECLARE @MoveFiles              nvarchar(max);
        
        SET @BackupFile     = N'$backupLocation'; --source backup file
        SET @DBName         = N'$dstDataBaseName'; --target database name
        SET @DataPath       = N'$dataPathNewDb'; --target data path
        SET @LogPath        = N'$logPathNewDb'; --target log path
        
        /* ************************************
        
            modify nothing below this point.
        
        ************************************ */
        IF RIGHT(@DataPath, 1) <> '\' SET @DataPath = @DataPath + N'\';
        IF RIGHT(@LogPath, 1) <> '\' SET @LogPath = @LogPath + N'\';
        SET @cmd = N'';
        SET @Version = CONVERT(decimal(10,2), 
            CONVERT(varchar(10), SERVERPROPERTY('ProductMajorVersion')) 
            + '.' + 
            CONVERT(varchar(10), SERVERPROPERTY('ProductMinorVersion'))
            );
        IF @Version IS NULL --use ProductVersion instead
        BEGIN
            DECLARE @sv varchar(10);
            SET @sv = CONVERT(varchar(10), SERVERPROPERTY('ProductVersion'));
            SET @Version = CONVERT(decimal(10,2), LEFT(@sv, CHARINDEX(N'.', @sv) + 1));
        END
        
        IF OBJECT_ID(N'tempdb..#FileList', N'U') IS NOT NULL
        BEGIN
            DROP TABLE #FileList;
        END
        CREATE TABLE #FileList 
        (
            LogicalName               sysname             NOT NULL
            , PhysicalName              varchar(255)        NOT NULL
            , [Type]                    char(1)             NOT NULL
            , FileGroupName             sysname             NULL
            , Size                      numeric(20,0)       NOT NULL
            , MaxSize                   numeric(20,0)       NOT NULL
            , FileId                    bigint              NOT NULL
            , CreateLSN                 numeric(25,0)       NOT NULL
            , DropLSN                   numeric(25,0)       NULL
            , UniqueId                  uniqueidentifier    NOT NULL
            , ReadOnlyLSN               numeric(25,0)       NULL
            , ReadWriteLSN              numeric(25,0)       NULL
            , BackupSizeInBytes         bigint              NOT NULL
            , SourceBlockSize           int                 NOT NULL
            , FileGroupId               int                 NULL
            , LogGroupGUID              uniqueidentifier    NULL
            , DifferentialBaseLSN       numeric(25,0)       NULL
            , DifferentialBaseGUID      uniqueidentifier    NOT NULL
            , IsReadOnly                bit                 NOT NULL
            , IsPresent                 bit                 NOT NULL 
        );
        
        IF @Version >= 10.5 ALTER TABLE #FileList ADD TDEThumbprint varbinary(32) NULL;
        IF @Version >= 12   ALTER TABLE #FileList ADD SnapshotURL nvarchar(360) NULL;
        
        SET @FileListCmd = N'RESTORE FILELISTONLY FROM DISK = N''' + @BackupFile + N''';';
        
        INSERT INTO #FileList
        EXEC (@FileListCmd);
        SET @MaxLogicalNameLength = COALESCE((SELECT MAX(LEN(fl.LogicalName)) FROM #FileList fl), 0);
        SELECT @MoveFiles = (SELECT N', MOVE N''' + fl.LogicalName + N''' ' 
            + REPLICATE(N' ', @MaxLogicalNameLength - LEN(fl.LogicalName)) 
            + N'TO N''' + CASE WHEN fl.Type = 'L' THEN @LogPath ELSE @DataPath END 
            + @DBName + N'\' + CASE WHEN fl.FileGroupName = N'PRIMARY' THEN N'System' 
                                    WHEN fl.FileGroupName IS NULL THEN N'Log' 
                                    ELSE fl.FileGroupName END 
            + N'\' + fl.LogicalName + CASE WHEN fl.Type = 'L' THEN N'.log' 
                                        ELSE 
                                            CASE WHEN fl.FileGroupName = N'PRIMARY' THEN N'.mdf'
                                            ELSE N'.ndf' 
                                            END 
                                        END + N'''
            '
        FROM #FileList fl
        FOR XML PATH(''));
        
        SET @MoveFiles = REPLACE(@MoveFiles, N'&#x0D;', N'');
        SET @MoveFiles = REPLACE(@MoveFiles, char(10), char(13) + char(10));
        SET @MoveFiles = LEFT(@MoveFiles, LEN(@MoveFiles) - 2);
        
        SET @RestoreCmd = N'RESTORE DATABASE ' + @DBName + N'
        FROM DISK = N''' + @BackupFile + N''' 
        WITH REPLACE 
            , RECOVERY
            , STATS = 5
            ' + @MoveFiles + N';';
        
        IF LEN(@RestoreCmd) > 4000 
        BEGIN
            DECLARE @CurrentLen int;
            SET @CurrentLen = 1;
            WHILE @CurrentLen <= LEN(@RestoreCmd)
            BEGIN
                SELECT SUBSTRING(@RestoreCmd, @CurrentLen, 4000) as Query;
                SET @CurrentLen = @CurrentLen + 4000;
            END
            RAISERROR (N'Output is chunked into 4,000 char pieces - look for errant line endings!', 14, 1);
        END
        ELSE
        BEGIN
            EXECUTE (@RestoreCmd);
        END"

    return $query
}