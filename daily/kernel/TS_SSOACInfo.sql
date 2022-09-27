CREATE PROCEDURE Update_TS_SSOACInfo
AS

INSERT INTO [TCSDB].[TCSDB].[dbo].[TS_SSOACInfo]
SELECT CONVERT(VARCHAR(8), log_operation.create_time, 112) AS AppDate,
       'NBP'                                       AS AppID,
       (SELECT company.code
       FROM company
       WHERE  log_operation.before_data IS NOT NULL
              AND Json_value(log_operation.before_data, '$.companyUid') = company.uid)
                                                   AS CompID,
       (SELECT company.name
       FROM company
       WHERE  log_operation.before_data IS NOT NULL
              AND Json_value(log_operation.before_data, '$.companyUid') =
                   company.uid)
                                                   AS CompName,
       department.code                             AS DeptID,
       department.name                             AS DeptName,
       Json_value(before_data, '$.userId')         AS EmpID,
       Json_value(before_data, '$.name')           AS EmpName,
       log_operation.function_name                 AS FunID,
       ''                                          AS FunName,
       '人工授權'                                    AS GrantType,
       log_operation.text                          AS GrantDesc,
       1                                           AS WorkStatus,
       '在職'                                       AS WorkStatusDesc,
       log_operation.user_id                       AS GrantUserID,
       log_operation.user_name                     AS GrantUserName,
       ''                                          AS Remark,
       GetDate()                                   AS CreateDT
FROM [dbo].[log_operation] as log_operation, [dbo].[department] as department
WHERE  category = 'permission'
       AND action_name != 'deleted'
       AND log_operation.before_data is not NULL
       AND CAST(send_record.create_time AS date) = DATEADD(day, -1, CAST(GETDATE() AS date))

GO;

