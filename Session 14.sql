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

DECLARE @I AS INT =  1;
WHILE @I <= 10
BEGIN
	SELECT * FROM dbo.Customers
		WHERE CustomerID = @I
	SET @I = @I + 1;
END
GO

-- جهت خروج از حلقه BREAK استفاده از
DECLARE @I AS INT = 1;
WHILE @I <= 10
BEGIN
	IF @I = 6 BREAK;
	PRINT @I;
	SET @I = @I + 1;
END
GO

-- جهت نادیده گرفتن دستورات بعدی و پرش به ابتدای حلقه CONTINUE استفاده از 
DECLARE @I AS INT = 0;
WHILE @I < 92
BEGIN
	SET @I = @I + 1;
	IF(SELECT Region FROM dbo.Customers
			WHERE CustomerID  = @I) IS NULL CONTINUE;
	SELECT CustomerID, Region FROM dbo.Customers
		WHERE CustomerID = @I
END
GO


--------------------------------------------------------------------

-- IF & WHILE
DROP TABLE IF EXISTS dbo.Digits;
GO

CREATE TABLE dbo.Digits
(
	Num INT
);
GO

DECLARE @i AS INT = 1;
WHILE @i <= 1000
BEGIN
	IF @i % 2 = 0 -- طرح زوج و فرد
	INSERT INTO dbo.Digits(Num)
		VALUES(@i);
	SET @i = @i + 1;
END
GO

SELECT * FROM dbo.Digits;
GO



-- Dynamic T-SQL

-- جهت تعیین ستون‌های دلخواه در کوئری SELECT عدم استفاده از متغیر در بخش
DECLARE @Col VARCHAR(50) = 'CustomerID';
SELECT @Col FROM dbo.Customers;
GO

-- جهت تعیین ستون‌ دلخواه جهت اعمال شرط WHERE عدم استفاده از متغیر در بخش
DECLARE @Col VARCHAR(50) = 'CustomerID';
SELECT * FROM dbo.Customers
	WHERE @Col > 80;
GO
--------------------------------------------------------------------

/*
EXEC یا EXECUTE
قابلیت استفاده با رشته‌های یونیکدی و غیر‌یونیکدی
*/

DECLARE @Col VARCHAR(50) = 'CustomerID';
DECLARE @Sql VARCHAR(200) = 'SELECT ' + @Col +' FROM dbo.Customers';
--PRINT @Sql
EXEC (@Sql); -- !پرانتز‌گذاری فراموش نشود
GO

DECLARE @City NVARCHAR(20) = N'تهران';
DECLARE @Sql NVARCHAR(200) = 'SELECT * FROM dbo.Customers WHERE City = N''' + @City +'''';
--PRINT @Sql
EXEC (@Sql); -- !پرانتز‌گذاری فراموش نشود
GO
--------------------------------------------------------------------

/*
sp_executesql
قابلیت استفاده فقط با رشته‌های یونیکدی
:فقط یکی از انواع‌داده زیر با این روش قابل استفاده است
NTEXT/NCHAR/NVARCHAR
*/

DECLARE @Col NVARCHAR(50) = 'CustomerID';
DECLARE @Sql NVARCHAR(200) = 'SELECT ' + @Col +' FROM dbo.Customers';
--PRINT @Sql;
EXEC sp_executesql @Sql;
GO

-- معادل کوئری بالا
EXEC sp_executesql N'SELECT CustomerID FROM dbo.Customers';
GO

-- !غلط است
EXEC sp_executesql 'SELECT @@VERSION'
GO

-- اصلاح کوئری بالا
EXEC sp_executesql N'SELECT @@VERSION'
GO

-- روش اول پارامتری
EXEC sp_executesql N'SELECT * FROM dbo.Orders WHERE CustomerID = @Customerid',
	N'@Customerid INT', @Customerid = 80;
GO

EXEC sp_executesql N'SELECT * FROM dbo.Orders WHERE OrderID = @OrderID OR CustomerID = @Customerid',
	N'@OrderID INT, @Customerid INT', @OrderID=10249 ,@Customerid=79;
GO

-- روش دوم پارامتری
DECLARE @Sql AS NVARCHAR(100);
SET @Sql = N'SELECT OrderID, CustomerID, EmployeeID, Orderdate FROM dbo.Orders
				WHERE OrderID = @OrderID;';
EXEC sp_executesql
	@stmt = @sql,
	@params = N'@OrderID AS INT',
	@OrderID = 10250;
GO-- !!!ترتیب پارامترها مهم است

-- ???
DECLARE @Sql AS NVARCHAR(100); /*DECLARE @Sql AS NVARCHAR(200)*/
SET @Sql = N'SELECT OrderID, CustomerID, EmployeeID, Orderdate FROM dbo.Orders
				WHERE OrderID BETWEEN @Min AND @Max';
EXEC sp_executesql
	@stmt = @Sql,
	@params = N'@Min AS INT, @MAX AS INT',
	@Min= 10248, @Max= 10250;
GO



-- Stored procedure

/*
CREATE { PROC | PROCEDURE } 
    [schema_name.] procedure_name
    [ { @parameter data_type }  
        [ = default ] [ OUT | OUTPUT | [READONLY]  
    ] [ ,...n ]   
AS { [ BEGIN ] sql_statement [;] [ ...n ] [ END ] }  
[;]  
*/

-- ساده SP ایجاد یک
DROP PROCEDURE IF EXISTS GetAllCustomers;
GO

CREATE PROCEDURE GetAllCustomers
AS
BEGIN 
	SELECT
		CustomerID, City
	FROM dbo.Customers
END
GO

-- SP روش‌های فراخوانی
EXEC GetAllCustomers;
GO
GetAllCustomers;
GO
--------------------------------------------------------------------

-- SP ویرایش
ALTER PROCEDURE GetAllCustomers
AS
BEGIN	
	SELECT 
		CustomerID, State, City
	FROM dbo.Customers;
END
GO

EXEC GetAllCustomers;
GO
--------------------------------------------------------------------

/*
SP With Input Parameters
*/

DROP PROCEDURE IF EXISTS GetEmployeeByID;
GO

CREATE PROCEDURE GetEmployeeByID
(
	@ID INT
)
AS
BEGIN
	SELECT
		EmployeeID, FirstName, LastName
	FROM dbo.Employees
		WHERE EmployeeID = @ID;
END
GO

-- با پارامتر ورودی SP روش اول فراخوانی
EXEC GetEmployeeByID 1;
GO

-- با پارامتر ورودی SP روش دوم فراخوانی
EXEC GetEmployeeByID @ID = 1;
GO

-- با پارامتر ورودی SP روش سوم فراخوانی
GetEmployeeByID 1;
GO
--------------------------------------------------------------------

/*
SP With Output Parameters
*/
