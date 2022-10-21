use SampleDb
use NikamoozDB
/*
Session 14
*/

-- تعریف متغیر
DECLARE @Var INT;
-- مقداردهی متغیر
SET @var = 190;
PRINT @VAR
GO

-- معادل دستورات بالا
DECLARE @VAR INT = 100;
SELECT @VAR;
GO


--------------------------------------------------------------------
-- DECLARE تعریف چند متغیر با یک دستور
DECLARE @VAR INT, @VAR@ INT, @VAR3 DATE;
-- مقداردهی
SELECT @VAR = 193, @VAR@ =566, @VAR3 = GETDATE();
--.مقداردهی کرد SET هر متغیر را می‌توان با یک دستور
PRINT @VAR;
PRINT @VAR@;
PRINT @VAR3;
GO


-- DECLARE تعریف چند متغیر با یک دستور
DECLARE @Var1 INT, @Var2 INT, @Var3 DATE;
--.مقداردهی کرد SET هر متغیر را می‌توان با یک دستور
SET @Var1 = 1000;
SET @Var2 = 1000;
SET @Var3 = GETDATE();
SELECT @Var1, @Var2, @Var3;
GO

-- DECLARE تعریف چند متغیر با یک دستور
DECLARE @Var1 INT, @Var2 INT, @Var3 DATE;
-- مقداردهی
SELECT @Var1 = 1000 , @Var2 = 2000 , @Var3 = GETDATE(); 
--.می‌توان مشاهده کرد PRINT مقدار متغیر را با دستور
PRINT @Var1;
PRINT @Var2;
PRINT @Var3;
GO
--------------------------------------------------------------------

SELECT * FROM dbo.Employees;
GO

-- ؟؟؟
DECLARE @Family NVARCHAR(50);
SET @Family = (SELECT LastName FROM dbo.Employees
					WHERE mgrid = 2);
PRINT @Family;
GO

-- ؟؟؟
DECLARE @Family NVARCHAR(50);
SELECT @Family = LastName FROM dbo.Employees
	WHERE mgrid = 2;
PRINT @Family;
GO
/*
آن mgrid کوئری بالا آخرین رکوردی را که مقدار فیلد
.برابر با 2 می‌باشد، نمایش می‌دهد
*/



-- Valid Batches
PRINT 'First Batches';
USE NikamoozDB;
GO

-- Invalid Batches
PRINT 'Second Batches';
SELECT CustomerID FROM dbo.Customers;
SELECT OrderID FOM dbo.Orders; -- Compile Error
GO

-- valid & Invalid Batches
PRINT 'Second Batches';
SELECT CustomerID FROM dbo.Customers;
SELECT OrderID FROM db.Customers;-- Binding!!!
SELECT * FROM dbo.Orders; 
GO

-- Valid Batches
PRINT 'Third Batches';
SELECT EmployeeID FROM HR.Employees;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS #Test;
GO

CREATE  TABLE #Test
(
    ID INT CHECK(ID > 10),
    FAMILY VARCHAR(100)
);

INSERT #Test
    VALUES(11,'A'),(12,'B'),(13,'C'),(14,'D');
INSERT #Test
	VALUES(10,'E');
INSERT #Test
	VALUES(15,'E');
GO

SELECT * FROM #Test;
GO


DROP TABLE IF EXISTS #Test;
GO

CREATE  TABLE #Test
(
    ID INT CHECK(ID > 10),
    FAMILY VARCHAR(100)
);

INSERT #Test
	VALUES(10,'E');
INSERT #Test
    VALUES(11,'A'),(12,'B'),(13,'C'),(14,'D');
INSERT #Test
	VALUES(15,'E');
GO

SELECT * FROM #Test;
GO

https://technet.microsoft.com/en-us/library/ms175502(v=sql.105).aspx
--------------------------------------------------------------------

DECLARE @Var INT;
SET @Var = 100;
SELECT @Var;
GO

-- آن Scope عدم دسترسی به متغیر در خارج از
SELECT @Var;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Batches_GO;
GO

CREATE TABLE dbo.Batches_GO
(
	Col1 INT IDENTITY,
	Col2 INT
);
GO

INSERT INTO dbo.Batches_GO
	VALUES (100);
GO 20

SELECT * FROM dbo.Batches_GO;
GO



/*
Local Temporary Table
جاری Session قابلیت دسترسی در تمامی بخش‌های مختلف
*/

CREATE TABLE #Local_Tmp_Table
(
	Code INT
);
GO

INSERT #Local_Tmp_Table
	VALUES (1), (2), (3), (4), (5);
SELECT * FROM #Local_Tmp_Table;
GO -- .باشد Tempdb ایجاد‌شده مربوط به دیتابیس Session دیگر حتی اگر Session عدم استفاده در

-- آزادسازی منابع
DROP TABLE #Local_Tmp_Table;
GO


--------------------------------------------------------------------

/*
Global Temporary Table
جاری Session ها تا زمان باز بودنSession قابلیت دسترسی در تمامی
*/
CREATE TABLE ##Global_Tmp_Table
(
	Code INT
);
GO

INSERT ##Global_Tmp_Table
	VALUES (1), (2), (3), (4), (5);
SELECT * FROM ##Global_Tmp_Table;
GO



--------------------------------------------------------------------
/*
Table Variable
جاری Batche و Session فقط در
*/

DECLARE @TV TABLE
(
	F1 INT
);

INSERT INTO @TV
	VALUES (100), (200), (300);
SELECT * FROM @TV;
GO

-- عدم دسترسی به متغیر جدول
SELECT * FROM @TV;
GO



-- FLOW_CONTROL
/*
IF ... ELSE IF
*/
DECLARE @VAR VARCHAR(5) = 'ASC';
IF @VAR = 'DESC'
BEGIN
	PRINT N'جدیدترین ده سفارش';
	SELECT TOP (10) * FROM dbo.Orders
	ORDER BY OrderID DESC;
END
ELSE IF @VAR = 'ASC'
BEGIN
	PRINT N'قدیمی ترین ده سفارش';
	SELECT TOP (10) * FROM dbo.Orders
	ORDER BY OrderID;	
END
ELSE 
BEGIN 
	PRINT N'ده سفارش تصادفی';
	SELECT TOP (10) * FROM dbo.Orders
	ORDER BY NEWID();
END
--------------------------------------------------------------------

/*
WHILE
اجرای کد در یک حلقه
*/

