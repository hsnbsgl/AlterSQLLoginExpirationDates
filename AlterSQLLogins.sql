SELECT @@SERVERNAME AS ServerName, 
        SL.name AS LoginName, 
        LOGINPROPERTY (SL.name ,'PasswordLastSetTime') AS PasswordLastSetTime,
        ISNULL(CONVERT (varchar (100) , LOGINPROPERTY (SL.name,'DaysUntilExpiration')), 'Never Expire') AS DaysUntilExpiration,
        ISNULL(CONVERT (varchar (100) ,DATEADD (dd, CONVERT(int, LOGINPROPERTY (SL.name,'DaysUntilExpiration')),
                                                CONVERT(int,LOGINPROPERTY(SL.name, 'PasswordLastSetTime'))), 101),'Never Expire') AS PasswordExpirationDate,
        CASE WHEN is_expiration_checked = 1 THEN 'TRUE' ELSE 'FALSE' END AS PasswordExpireChecked
 FROM sys.sql_logins AS SL
 WHERE SL.name NOT LIKE '##%' AND SL.name NOT LIKE 'endPointUser' and is disabled = 0
 ORDER BY (LOGINPROPERTY(SL.name,'PasswordLastSetTime')) DESC
 
 SET NOCOUNT ON
 
 /*ALTER Login with same password*/
 
 SELECT 'ALTER LOGIN ['+ P.name + '] WITH PASSWORD=0x' +
 CONVERT (VARCHAR (500) , cast (convert (sysname, LoginProperty (p.name, 'PasswordHash')) AS varbinary (256)), 2) + ' HASHED '+ 
 ' ,DEFAULT DATABASE=['+P.default_database_name +']'+
 ' ,DEFAULT LANGUAGE=['+P.default_language_name +']'+
 ' ,CHECK POLICY= OFF' +
 ' , CHECK EXPIRATION= OFF' 
 FROM sys.server principals p
 LEFT JOIN sys.sql_logins L ON P.sid = L.sid
 WHERE P.type = 'S' AND P.name NOT LIKE '##%##' AND p.is disabled=0 
 ORDER BY P.name
 
 /*SET Check policy ON, check expiration ON*/
 
 SELECT 'ALTER LOGIN [' + p.name + '] WITH CHECK_POLICY= ON , CHECK_ EXPIRATION=ON ' FROM sys.server_principals p
 WHERE P.type= 'S' AND P.name NOT LIKE '##%##' AND p.is_disabled=0 
 ORDER BY P.name
