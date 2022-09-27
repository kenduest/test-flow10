
-- Delete

DELETE from [SMSCheck].[RMarket].[dbo].[Result_Log] 
WHERE RecordID IN (
    SELECT substring(upper(send_record.uid), 1, 20)
FROM [dbo].[send_record] as send_record
WHERE  cast(send_record.create_time AS date) = dateadd(day, -1, cast(getdate() AS date))
)


-- -- Insert

INSERT INTO [SMSCheck].[RMarket].[dbo].[Result_Log]
      (
      Deliverytype,
      Channel,
      Pgcode,
      Pgdesc,
      Batchno,
      Recordid,
      Psendtime,
      Rsendtime,
      Checkflag,
      Errormsg,
      Sendflag,
      Sendstatus,
      Isread,
      Custid,
      Custphonenum ,
      Outsysid,
      Msgcontenttype,
      Priority,
      Msgcontent
      )
SELECT '4'                                                                           AS Deliverytype,
      send.req_channel                                                               AS Channel,
      send.msg_type                                                                  AS Pgcode,
      CONVERT(varchar(100), send_record.gateway_id)                                  AS Pgdesc,
      iif(send.req_batch_id IS NULL, '', substring(upper(send.req_batch_id), 1, 20)) AS Batchno,
      substring(upper(send_record.uid), 1, 20)                                       AS Recordid,
      cast(send_record.send_time AS        datetime)                                        AS Psendtime,
      cast(send_record.actual_send_time AS datetime)                                        AS Rsendtime,
      ''                                                                                    AS Checkflag,
      ''                                                                                    AS Errormsg,
      1                                                                                     AS sendflag,
      iif(send_record.resp_code IS NULL, '', send_record.resp_code)                         AS Sendstatus,
      0                                                                                     AS Isread,
      substring(send_record.customer_id, 1, 11)                                             AS Custid,
      send_record.customer_phone                                                            AS Custphonenum,
      iif(send.req_channel LIKE '%card%', 'CARDSMS', 'BANKSMS')                             AS Outsysid,
      CASE 
              WHEN send.priority >= 9 THEN 'T' 
              WHEN send.priority <= 8 AND send.priority >= 6 THEN 'G' 
              WHEN send.priority < 5 THEN 'C' 
      END                                  AS Msgcontenttype,
      send.priority                        AS Priority,
      send_record.content                  AS Msgcontent
FROM [dbo].[send]        AS send,
     [dbo].[send_record] AS send_record
WHERE  send_record.send_uid = send.uid
      AND cast(send_record.create_time AS date) = dateadd(day, -1, cast(getdate() AS date))


-- Update

UPDATE [SMSCheck].[RMarket].[dbo].[Result_Log]
SET    sendflag=iif(send_record.resp_code IS NULL, '', send_record.resp_code)
FROM [dbo].[send_record] as send_record, [dbo].[send] as send, [SMSCheck].[RMarket].[dbo].[Result_Log] as adw
WHERE  send_record.send_uid = send.uid
      AND substring(upper(send_record.uid), 1, 20) = adw.recordid
      AND adw.sendflag != send_record.resp_code
      AND send_record.create_time != send_record.update_time
      AND cast(send_record.create_time AS date) >= dateadd(day, -3, cast(getdate() AS date))
