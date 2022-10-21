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

--كاربر دوم
--4
USE NikamoozDB;
GO

--5
BEGIN TRAN 
GO

--6
INSERT INTO dbo.Tbl2 VALUES (100,'Val100');
GO

--8
SELECT * FROM dbo.Tbl1;
GO
--ROLLBACK TRAN

