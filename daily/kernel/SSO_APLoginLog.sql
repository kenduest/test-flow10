
Use NBPKernel
GO

CREATE PROCEDURE Update_VACSYS_SSO_APLoginLog
AS

-- Delete

DELETE FROM [VACSYS].[VacSys].[dbo].[SSO_APLoginLog]
WHERE  appid = 'NBP'
       AND Cast(logdatetime AS DATE) = Dateadd(day, -1, Cast(Getdate() AS DATE))

-- Insert
INSERT INTO [VACSYS].[VacSys].[dbo].[SSO_APLoginLog]
       (userid, appid, logaction, logresult, logdatetime, hostip, clientip, remark)
SELECT log_operation.user_id                       AS userid,
       'NBP'                                       AS appid,
       1                                           AS logaction,
       'S'                                         AS logresult,
       Cast(log_operation.create_time AS DATETIME) AS logdatetime,
       '0.0.0.0'                                   AS hostip,
       log_operation.client_ip                     AS clientip,
       'signin'                                    AS remark
FROM   [dbo].[log_operation] AS log_operation
WHERE  log_operation.category = 'signin'
       AND Cast(log_operation.create_time AS DATE) = Dateadd(day, -1, Cast(Getdate() AS DATE))


GO

