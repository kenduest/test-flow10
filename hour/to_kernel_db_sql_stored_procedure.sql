DROP PROCEDURE legacy_to_report_db
GO

CREATE PROCEDURE legacy_to_report_db
AS
BEGIN

     -- insert send table

     DECLARE @CURRENT_TIME DATETIME2
     DECLARE @PREVIOUS_TIME DATETIME2
     SET @CURRENT_TIME = Sysdatetime()
     SELECT @PREVIOUS_TIME=TimeStamp
     FROM [dbo].[GravityLegacySync]
     WHERE Name='SI_SINOBACBANKMSGINFO'

     INSERT INTO [dbo].[send]
          (
          uid,
          way_name,
          send_from,
          send_date,
          send_mode,
          status,
          priority,
          msg_type,
          req_channel,
          req_batch_id,
          create_time,
          memo
          )

     (
          SELECT
          SI_SinoPacBank.GUID as uid,
          'SMS' as way_name,
          4 as send_from,
          convert(varchar, SI_SinoPacBank.BookingTime, 23) as send_time,
          'R' as send_mode,
          CASE Convert(int, StatusFlag)
               WHEN 1 THEN 5
               WHEN 4 THEN 5
               WHEN 5 THEN 5
               WHEN 6 THEN 5
               WHEN 7 THEN 5
               WHEN 8 THEN 5
               WHEN 9 THEN 7
          END as status,
          SI_SinoPacBank.Priority as priority,
          SI_SinoPacBank.MsgType as msg_type,
          SI_SinoPacBank.Channel as req_channel,
          MsgInfo.BatchCode as req_batch_id,
          SYSDATETIME() as create_time,
          SI_SinoPacBank.Memo as memo

     FROM [SMSBank].[SMSDB].[dbo].[SI_SinoPacBank] as SI_SinoPacBank, [SMSBank].[SMSDB].[dbo].[MsgInfo] as MsgInfo
     WHERE SI_SinoPacBank.GUID = MsgInfo.DestName AND
          SI_SinoPacBank.BookingTime >= @PREVIOUS_TIME AND
          SI_SinoPacBank.BookingTime < @CURRENT_TIME 
     )

     -- insert send_record table

     INSERT INTO [dbo].[send_record]
          (
          uid,
          status,
          send_uid,
          way_name,
          serial_number,
          send_time,
          expire_time,
          customer_id,
          customer_phone,
          req_uid,
          req_department,
          req_company,
          req_object_id,
          content,
          actual_send_time,
          resp_code,
          origin_resp_code,
          create_time,
          dr_time,
          gateway_id
          )

     (
          SELECT
          SI_SinoPacBank.GUID as uid,
          CASE Convert(int, StatusFlag)
               WHEN 4 THEN 1
               WHEN 5 THEN 1
               WHEN 6 THEN 1
               WHEN 7 THEN 1
               WHEN 8 THEN 1
               WHEN 9 THEN 3
          END as status,
          SI_SinoPacBank.GUID as send_uid,
          'SMS' as way_name,
          SI_SinoPacBank.SerialNum as serial_number ,
          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-' 
               + Substring(MsgInfo.SubmitTime, 5, 2) + '-' 
               + Substring(MsgInfo.SubmitTime, 7, 2) + ' ' 
               + Substring(MsgInfo.SubmitTime, 9, 2) + ':' 
               + Substring(MsgInfo.SubmitTime, 11, 2) + ':' 
               + Substring(MsgInfo.SubmitTime, 13, 2) AS DATETIME2) as send_time,
          Dateadd(second, SI_SinoPacBank.ExpireTime, SI_SinoPacBank.BookingTime) as expire_time,
          SI_SinoPacBank.SenderID as customer_id,
          MsgInfo.DestNo as customer_phone,
          MsgInfo.DestName as req_uid,
          SI_SinoPacBank.DepID as req_department,
          SI_SinoPacBank.Company as req_company,
          convert(varchar, MsgInfo.ObjectID) as req_object_id,
          MsgInfo.MsgData as content,
          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-' 
               + Substring(MsgInfo.SubmitTime, 5, 2) + '-' 
               + Substring(MsgInfo.SubmitTime, 7, 2) + ' ' 
               + Substring(MsgInfo.SubmitTime, 9, 2) + ':' 
               + Substring(MsgInfo.SubmitTime, 11, 2) + ':' 
               + Substring(MsgInfo.SubmitTime, 13, 2) AS DATETIME2) as actual_send_time,
          MsgInfo.StatusFlag as resp_code,
          MsgInfo.StatusFlag as origin_resp_code,
          GETDate() as create_time,
          Cast(Substring(MsgInfo.StatusTime, 1, 4) + '-' 
               + Substring(MsgInfo.StatusTime, 5, 2) + '-' 
               + Substring(MsgInfo.StatusTime, 7, 2) + ' ' 
               + Substring(MsgInfo.StatusTime, 9, 2) + ':' 
               + Substring(MsgInfo.StatusTime, 11, 2) + ':' 
               + Substring(MsgInfo.StatusTime, 13, 2) AS DATETIME2) as dr_time,
          1 as gateway_id

     FROM [dbo].[SI_SinoPacBank] as SI_SinoPacBank, [dbo].[MsgInfo] as MsgInfo
     WHERE SI_SinoPacBank.GUID = MsgInfo.DestName AND
          SI_SinoPacBank.BookingTime >= @PREVIOUS_TIME AND
          SI_SinoPacBank.BookingTime < @CURRENT_TIME
     )


     -- update send_record table


     UPDATE [dbo].[send_record]
          SET dr_time=Cast(Substring(MsgInfo.StatusTime , 1, 4) + '-' 
            + Substring(MsgInfo.StatusTime , 5, 2) + '-' 
            + Substring(MsgInfo.StatusTime , 7, 2) + ' ' 
            + Substring(MsgInfo.StatusTime , 9, 2) + ':' 
            + Substring(MsgInfo.StatusTime , 11, 2) + ':' 
            + Substring(MsgInfo.StatusTime , 13, 2) AS DATETIME2)

     FROM [SMSBank].[SMSDB].[dbo].[SI_SinoPacBank] as SI_SinoPacBank,
          [SMSBank].[SMSDB].[dbo].[MsgInfo] as MsgInfo
     WHERE 
          SI_SinoPacBank.GUID = MsgInfo.DestName AND
          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-' 
            + Substring(MsgInfo.StatusTime, 5, 2) + '-' 
            + Substring(MsgInfo.StatusTime, 7, 2) + ' ' 
            + Substring(MsgInfo.StatusTime, 9, 2) + ':' 
            + Substring(MsgInfo.StatusTime, 11, 2) + ':' 
            + Substring(MsgInfo.StatusTime, 13, 2) AS DATETIME2) != send_record.dr_time AND

          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-' 
            + Substring(MsgInfo.SubmitTime, 5, 2) + '-' 
            + Substring(MsgInfo.SubmitTime, 7, 2) + ' ' 
            + Substring(MsgInfo.SubmitTime, 9, 2) + ':' 
            + Substring(MsgInfo.SubmitTime, 11, 2) + ':' 
            + Substring(MsgInfo.SubmitTime, 13, 2) AS DATETIME2) >= Dateadd(day, -3, SYSDATETIME())


     UPDATE [dbo].[send_record]
     SET calc_section=1, sending_section = 1, section=1, success_section=1,failure_section=0
     FROM [SMSBank].[SMSDB].[dbo].[SI_SinoPacBank] as SI_SinoPacBank, [SMSBank].[SMSDB].[dbo].[MsgInfo] as MsgInfo, [dbo].send_record as send_record
     WHERE SI_SinoPacBank.GUID = MsgInfo.DestName AND MsgInfo.StatusFlag = 4 AND
          send_record.UID = SI_SinoPacBank.GUID AND
          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-' 
            + Substring(MsgInfo.SubmitTime, 5, 2) + '-' 
            + Substring(MsgInfo.SubmitTime, 7, 2) + ' ' 
            + Substring(MsgInfo.SubmitTime, 9, 2) + ':' 
            + Substring(MsgInfo.SubmitTime, 11, 2) + ':' 
            + Substring(MsgInfo.SubmitTime, 13, 2) AS DATETIME2) >= Dateadd(day, -3, SYSDATETIME())


     UPDATE [dbo].[send_record]
          SET calc_section=0, sending_section = 0, section=1, success_section=0,failure_section=1
          FROM [SMSBank].[SMSDB].[dbo].[SI_SinoPacBank] as SI_SinoPacBank,
          [SMSBank].[SMSDB].[dbo].[MsgInfo] as MsgInfo,
          [dbo].send_record as send_record
          WHERE send_record.uid = SI_SinoPacBank.GUID AND
          SI_SinoPacBank.GUID = MsgInfo.DestName AND
          MsgInfo.StatusFlag IN (5,6,7,8,9) AND
          Cast(Substring(MsgInfo.SubmitTime, 1, 4) + '-'
               + Substring(MsgInfo.SubmitTime, 5, 2) + '-'
               + Substring(MsgInfo.SubmitTime, 7, 2) + ' '
               + Substring(MsgInfo.SubmitTime, 9, 2) + ':'
               + Substring(MsgInfo.SubmitTime, 11, 2) + ':'
               + Substring(MsgInfo.SubmitTime, 13, 2) AS DATETIME2) >= Dateadd(day, -3, SYSDATETIME())



     UPDATE [dbo].[GravityLegacySync]
     SET    TimeStamp = @CURRENT_TIME
     WHERE  Name = 'SI_SINOBACBANKMSGINFO'

     -- insert send_record_reply

     SELECT @PREVIOUS_TIME=TimeStamp
     FROM [dbo].[GravityLegacySync]
     WHERE Name='MSGMO'

     INSERT INTO [dbo].[send_record_reply]
          (customer_phone, update_time, reply_content, code)
     SELECT MsgMO.DestNo                                             AS customer_phone,
          Cast(Substring(MsgMO.ReceiveTime, 1, 4) + '-'
            + Substring(MsgMO.ReceiveTime, 5, 2) + '-'
            + Substring(MsgMO.ReceiveTime, 7, 2) + ' '
            + Substring(MsgMO.ReceiveTime, 9, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 11, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 13, 2) AS DATETIME2) AS update_time,
          MsgMO.MsgData                                            AS reply_content,
          MsgMO.MID                                                AS code

     FROM [SMSBank].[SMSDB].[dbo].[MsgMO] AS MsgMO,
          [dbo].[GravityLegacySync] AS gravitygegacysync

     WHERE  gravitygegacysync.TimeStamp <= Cast(Substring(MsgMO.ReceiveTime, 1, 4) + '-'
            + Substring(MsgMO.ReceiveTime, 5, 2) + '-'
            + Substring(MsgMO.ReceiveTime, 7, 2) + ' '
            + Substring(MsgMO.ReceiveTime, 9, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 11, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 13, 2) AS DATETIME2) AND

          @PREVIOUS_TIME > Cast(Substring(MsgMO.ReceiveTime, 1, 4) + '-'
            + Substring(MsgMO.ReceiveTime, 5, 2) + '-'
            + Substring(MsgMO.ReceiveTime, 7, 2) + ' '
            + Substring(MsgMO.ReceiveTime, 9, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 11, 2) + ':'
            + Substring(MsgMO.ReceiveTime, 13, 2) AS DATETIME2)


     UPDATE [dbo].[GravityLegacySync]
SET    TimeStamp = @CURRENT_TIME
WHERE  Name = 'MSGMO'

END

GO
