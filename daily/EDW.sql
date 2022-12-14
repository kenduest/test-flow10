SELECT
	isnull(REPLACE(A.SerialNum,'|','^'),'NULL')
	   , ''
	   , isnull(REPLACE(A.MsgData,'|','^'),'NULL')
	   , isnull(REPLACE(A.[Priority],'|','^'),'NULL')
	   , isnull(CONVERT(varchar ,A.BookingTime,120),'NULL')
	   , isnull(REPLACE(A.ExpireTime,'|','^'),'NULL')
	   , isnull(REPLACE(DepID,'|','^'),'NULL')
	   , isnull(REPLACE(MsgType,'|','^'),'NULL')
	   , isnull(REPLACE(Memo,'|','^'),'NULL')
	   , isnull(REPLACE(SenderID,'|','^'),'NULL')
	   , isnull(REPLACE(Bu,'|','^'),'NULL')
	   , isnull(REPLACE(Company,'|','^'),'NULL')
       , isnull(REPLACE(Channel,'|','^'),'NULL')
       , isnull(REPLACE(Reference,'|','^'),'NULL')
	   , isnull(REPLACE(StatusFlag,'|','^'),'NULL')
	   , isnull(REPLACE(StatusTime,'|','^'),'NULL')
FROM [NBPReport].[dbo].[SI_SinoPacBankMsgInfo]
where CONVERT(varchar(10),[BookingTime],112) = CONVERT(varchar(10),DATEADD("d", -2, GETDATE()),112) -- 兩天前
	and Channel='UNICA'
