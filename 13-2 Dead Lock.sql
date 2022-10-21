--------------------------------------------------------------------
/*
SQL Server 2019 دوره آموزشی کوئری‌نویسی در 
Site:        http://www.NikAmooz.com
Email:       Info@NikAmooz.com
Instagram:   https://instagram.com/nikamooz/
Telegram:	 https://telegram.me/nikamooz
Created By:  Mehdi Shishebory 
*/
--------------------------------------------------------------------


--كاربر اول
--1
USE NikamoozDB;
GO

--2
BEGIN TRAN 
GO

--3
INSERT INTO dbo.Tbl1 VALUES (1,'Val1');
GO

--7
SELECT * FROM dbo.Tbl2;
GO
--ROLLBACK TRAN