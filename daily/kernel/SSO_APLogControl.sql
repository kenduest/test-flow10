
CREATE PROCEDURE Update_VACSYS_SSO_APLogControl
AS

--- Delete Count

DELETE FROM [VACSYS].[VacSys].[dbo].[SSO_APLogControl]
WHERE Cast(ControlDate AS DATE) = Dateadd(day, -1, Cast(Getdate() AS DATE))

--- Update Count

DECLARE @TotalCount INT

SELECT @TotalCount=Count(*)
FROM [VACSYS].[VacSys].[dbo].[SSO_APLoginLog] AS sso_aploginlog
WHERE  Cast(sso_aploginlog.LogDateTime AS DATE) = Dateadd(day, -1, Cast(Getdate() AS DATE)) AND sso_aploginlog.appid='NBP'

INSERT INTO [VACSYS].[VacSys].[dbo].[SSO_APLogControl]
       (AppID, ControlDate, DataCount)
VALUES
       ('NBP', Dateadd(day, -1, Cast(Getdate() AS DATE)), Cast(@TotalCount AS DECIMAL(18, 0)) )

GO
