use SampleDb
use NikamoozDB
/*
Session 10
*/

 /*
CREATE VIEW view_name
AS
SELECT_statement;
 */

 -- تعداد سفارشات هر شرکت
SELECT
	c.CompanyName,
	c.CustomerID,
	COUNT(o.OrderID) AS num
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
	ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName,
	c.CustomerID;
GO

SELECT
	c.CompanyName,
	c.City,
	(SELECT COUNT(o.OrderID) FROM dbo.Orders AS o
		WHERE c.CustomerID = o.CustomerID ) AS Num
FROM dbo.Customers AS c;
GO

SELECT
	c.CompanyName,
	c.City,
	(SELECT COUNT(o.OrderID) FROM dbo.Orders AS o
		WHERE c.CustomerID = o.CustomerID ) AS Num
FROM dbo.Customers AS c
	WHERE c.City = N'تهران';
GO

CREATE VIEW dbo.companyList
AS
	SELECT
	c.CompanyName,
	c.City,
	(SELECT COUNT(o.OrderID) FROM dbo.Orders AS o
		WHERE c.CustomerID = o.CustomerID ) AS Num
	FROM dbo.Customers AS c;
GO

SELECT * FROM dbo.companyList

SELECT cl.CompanyName FROM dbo.companyList AS cl

SELECT * FROM dbo.companyList AS cl
	WHERE cl.City = N'تهران';
GO



/* 
تمرین کلاسی

.ای بنویسید که شامل تعداد کل سفارشات به‌تفکیک هر سال باشدVIEW

OrderYear   Num
---------   ---
  2016      270
  2014      152
  2015      408

ساده  SELECT در یک دستور VIEW در ادامه با فراخوانی این
.تعداد سفارشات برحسب سال دلخواه مثلا 2014 را نمایش دهید
*/
CREATE VIEW dbo.allOrders
AS
SELECT
	YEAR(o.OrderDate) AS OrderYear,
	COUNT(o.OrderID ) AS Num
FROM dbo.Orders AS o
GROUP BY YEAR(o.OrderDate);
GO

SELECT * FROM dbo.allOrders AS ao
	WHERE ao.OrderYear = 2014;
GO


/*
.استفاده نکنید SELECT * از VIEW هیچ‌گاه در
*/

DROP TABLE IF EXISTS dbo.TestTbl;
GO

CREATE TABLE dbo.TestTbl
(
	ID INT
);
GO

INSERT INTO dbo.TestTbl
VALUES
	(100),
	(200),
	(300);
GO

DROP VIEW IF EXISTS dbo.All_Fields;
GO

-- VIEW ایجاد
CREATE VIEW dbo.All_Fields
AS
	SELECT * FROM dbo.TestTbl;
GO

-- All_Fields فراخوانی
SELECT * FROM dbo.All_Fields;
GO

-- TestTbl اضافه کردن فیلد جدید به جدول
ALTER TABLE dbo.TestTbl
	ADD Code INT IDENTITY;
GO

SELECT * FROM dbo.TestTbl;
GO

-- ذخیره شده است VIEW فقط اطلاعات مربوط به قبل از تغییرات جدول در متا‌دیتای
SELECT * FROM dbo.All_Fields;
GO

/*
(VIEW به‌روزرسانی) VIEW اعمال تغییرات جدول بر روی
*/
EXEC sp_refreshview 'All_Fields';
GO

EXEC sp_refreshsqlmodule 'All_Fields';
GO

SELECT * FROM dbo.All_Fields;
GO

-- VIEW تغییر ساختار
ALTER VIEW dbo.All_Fields
AS
	SELECT ID, Code FROM dbo.TestTbl;
GO

SELECT * FROM dbo.All_Fields;
GO

-- Info about VIEW
SP_HELPTEXT 'All_Fields'

SELECT * FROM sys.sql_modules
	WHERE object_id = object_id('All_Fields');
GO

-- دیگر VIEW در VIEW فراخوانی یک
DROP VIEW IF EXISTS
	dbo.Employees_OrderCount, dbo.Range_Employees_OrderCount;
GO

-- .ای که از طریق آن تعداد سفارشات هر کارمند شمارش می‌شود VIEW
CREATE VIEW dbo.Employees_OrderCount
AS
	SELECT 
		EmployeeID,
		COUNT(OrderID) AS Num
	FROM dbo.Orders
	GROUP BY EmployeeID;
GO

-- Employees_OrderCount فراخوانی
SELECT * FROM dbo.Employees_OrderCount;
GO

-- دیگری فراخوانی می‌شود VIEW ای که در آن VIEW
CREATE VIEW dbo.Range_Employees_OrderCount
AS
	SELECT * FROM dbo.Employees_OrderCount
		WHERE Num > 100;
GO

SELECT * FROM dbo.Range_Employees_OrderCount;
GO

DROP TABLE IF EXISTS dbo.SchemaBindingTbl;
GO

CREATE TABLE dbo.SchemaBindingTbl
(
	ID INT,
	Family NVARCHAR(50)
);
GO

INSERT INTO dbo.SchemaBindingTbl
VALUES
	(100,N'سعیدی'),
	(200,N'کاردان'),
	(300,N'شاکری');
GO

DROP VIEW IF EXISTS dbo.ViewBinding;
GO

CREATE VIEW ViewBinding
AS
	SELECT
		ID, Family
	FROM SchemaBindingTbl;
GO

SELECT * FROM dbo.ViewBinding;
GO

-- یکی از فیلدهای جدول Data Type تغییر 
ALTER TABLE SchemaBindingTbl
	ALTER COLUMN Family NVARCHAR(100);
GO

-- VIEW بر روی WITH SCHEMABINDING اضافه کردن تنظیمات
ALTER VIEW ViewBinding WITH SCHEMABINDING
AS
	SELECT 
		ID, Family
	FROM dbo.SchemaBindingTbl;
GO

/*
WITH SCHEMABINDING به‌دلیل وجود تنظیمات
.داده نخواهد شد Family فیلد Data Type اجازه تغییر
*/
ALTER TABLE SchemaBindingTbl
	ALTER COLUMN Family NVARCHAR(100);
GO

/*
را تغییر داده و فیلد VIEW
.را از آن حذف می‌کنیم Family
*/
ALTER VIEW ViewBinding WITH SCHEMABINDING
AS
	SELECT 
		ID
	FROM dbo.SchemaBindingTbl;
GO

SELECT * FROM ViewBinding;
GO

/*
VIEW در Family با توجه به عدم وجود فیلد
.تغییرات بدون هیچ‌گونه مشکلی در سمت جدول انجام خواهد شد
*/
ALTER TABLE SchemaBindingTbl
	ALTER COLUMN Family NVARCHAR(100);
GO

/*
کردن جدول داده نمی‌شود چرا که DROP اجازه
.با جدول در ارتباط است WITH SCHEMABINDING از طریق VIEW
*/
DROP TABLE IF EXISTS SchemaBindingTbl;
GO
--------------------------------------------------------------------

/*
در حالت استفاده Object عدم نوشتن نام اسکیمای
.موجب بروز خطا خواهد شد WITH SCHEMABINDING از تنظیمات 
*/
ALTER VIEW ViewBinding WITH SCHEMABINDING
AS
	SELECT 
		ID
	FROM SchemaBindingTbl; -- dbo.SchemaBindingTbl
GO

/*
در حالت استفاده  SELECT * استفاده از
.موجب بروز خطا خواهد شد WITH SCHEMABINDING از تنظیمات 
*/
ALTER VIEW ViewBinding WITH SCHEMABINDING
AS
	SELECT * FROM dbo.SchemaBindingTbl;
GO


/*
CHECK OPTION
*/

DROP TABLE IF EXISTS dbo.Company;
GO

CREATE TABLE dbo.Company
(
	CompanyID INT IDENTITY,
	CompanyName NVARCHAR(50),
	City NVARCHAR(30)
);
GO

INSERT INTO dbo.Company
VALUES
	(N'شرکت 1', N'تهران'),
	(N'شرکت 2', N'تهران'),
	(N'شرکت 3', N'اصفهان'),
	(N'شرکت 4', N'تبریز'),
	(N'شرکت 5', N'تهران'),
	(N'شرکت 6', N'شیراز');
GO

DROP VIEW IF EXISTS dbo.Comp_View;
GO

CREATE VIEW dbo.Comp_View
AS
	SELECT
		CompanyName, City
	FROM dbo.Company
		WHERE City = N'تهران';
GO

-- Comp_View فراخوانی
SELECT * FROM dbo.Comp_View;
GO

-- VIEW از طریق Customers درج رکورد در جدول
INSERT INTO dbo.Comp_View (CompanyName, City)
VALUES
	(N'شرکت 7', N'رشت');
GO

SELECT * FROM dbo.Company;
GO

/*
Comp_View عدم نمایش رکورد درج شده توسط
VIEW به‌دلیل وجود فیلتر موجود در Company در جدول
*/
SELECT * FROM dbo.Comp_View
	WHERE CompanyName = N'شرکت 7';
GO

/*
بر روی آن WITH CHECK OPTION و اعمال تنظیمات VIEW تغییر
*/
ALTER VIEW dbo.Comp_View
AS
SELECT
	City,CompanyName
FROM dbo.Company
	WHERE City = N'تهران'
WITH CHECK OPTION;
GO

-- VIEW از طریق Customers عدم درج رکورد در جدول
INSERT INTO dbo.Comp_View (CompanyName, City)
VALUES
	(N'شرکت 8', N'ساری');
GO

-- VIEW از طریق Customers درج رکورد در جدول
INSERT INTO dbo.Comp_View (CompanyName, City)
VALUES
	(N'شرکت 8', N'تهران');
GO

SELECT * FROM dbo.Company;
SELECT * FROM dbo.Comp_View;
GO
--------------------------------------------------------------------

-- Updateable VIEW در GROUP BY عدم استفاده از
ALTER VIEW dbo.Comp_View
AS
SELECT
	City
FROM dbo.Company
	WHERE City = N'تهران'
GROUP BY City
WITH CHECK OPTION;
GO

SELECT * FROM dbo.Comp_View;
GO

INSERT INTO dbo.Comp_View (City)
VALUES
	(N'تهران');
GO
--------------------------------------------------------------------

-- Updateable VIEW در DISTINCT عدم استفاده از
ALTER VIEW dbo.Comp_View
AS
SELECT
	DISTINCT City
FROM dbo.Company
	WHERE City = N'تهران'
WITH CHECK OPTION;
GO

INSERT INTO dbo.Comp_View (City)
VALUES
	(N'تهران');
GO
--------------------------------------------------------------------

-- Updateable VIEW در Set Operator عدم استفاده از
ALTER VIEW dbo.Comp_View
AS
SELECT N'نام شهر' AS City, N'عنوان شرکت' AS CompanyName
UNION
SELECT
	CompanyName, City
FROM dbo.Company
	WHERE City = N'تهران'
WITH CHECK OPTION;
GO

INSERT INTO dbo.Comp_View (CompanyName,City)
VALUES
	(N'شرکت 9', N'تهران');
GO


/*
Scalar-Value FUNCTION

CREATE FUNCTION FUNCTION_Name
	({@Parameter [AS] type[=default]}[,...n])
	RETURNS Type
AS
BEGIN
	Function_Body
	RETURN Expression
END
*/

DROP FUNCTION IF EXISTS dbo.Abbreviation;
GO

-- تعریف تابع
CREATE FUNCTION dbo.Abbreviation (@FirstName NVARCHAR(50), @LastName NVARCHAR(50))
	RETURNS NCHAR(3)
AS
	BEGIN
		DECLARE @Ret NCHAR(3)
		SET @Ret = LEFT(@FirstName, 1) + '.' + LEFT(@LastName, 1)
		RETURN @Ret
		-- RETURN LEFT(@FirstName, 1) + '.' + LEFT(@LastName, 1)
	END
GO
-- استفاده از تابع در حالت عادی
SELECT dbo.Abbreviation(N'رضا', N'محمدی');
GO

/*
استفاده از تابع برای بازیابی رکوردهای جداول

ترکیب نام و نام‌خانوادگی کارمندان
*/
SELECT
	FirstName, LastName,
	dbo.Abbreviation(FirstName, LastName) AS Abbreviation
FROM dbo.Employees;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
.تابعی بنویسید که سن کارمندان را نمایش دهد

EmployeeID    Age
----------   -----
   1          60
   2          56
   3          45
   4          71
   5          53
   6          45
   7          48
   8          50
   9          42

(9 rows affected)

*/

DROP FUNCTION IF EXISTS dbo.GetAge;
GO

CREATE FUNCTION dbo.GetAge (@birthDay DATE)
	RETURNS TINYINT
AS
	BEGIN
	DECLARE @Age TINYINT
	SET @Age = DATEDIFF(YEAR, @birthDay, GETDATE())
	RETURN @Age
	END
GO

SELECT
	
	dbo.GetAge(1990/01/01) AS Age
GO

SELECT
	EmployeeID,
	dbo.GetAge(Birthdate) AS Age
FROM dbo.Employees

--Inline Table-Value Function


--CREATE FUNCTION Statement (Inline Table Valued Function)
-- Parameterized View
/*
CREATE FUNCTION  function_name 
    ( [ { @parameter_name [AS] scalar_parameter_data_type [ = default ] } [ ,...n ] ] ) 
RETURNS TABLE 
[ WITH < function_option > [ [,] ...n ] ] 
[ AS ] 
RETURN [ ( ] select-stmt [ ) ] 
*/

DROP VIEW IF EXISTS dbo.customers_info
/*
اطلاعات شرکت و سفارش مشتریان
*/
CREATE VIEW dbo.customers_info
AS
	SELECT
		c.CompanyName, c.City, o.OrderID, o.OrderDate
	FROM dbo.Customers AS c
	JOIN dbo.Orders AS o
		ON c.CustomerID = o.CustomerID
GO

/*
نمایش سفارش مشتریان تهرانی
*/

SELECT * FROM dbo.customers_info
	WHERE City = N'تهران';
GO

/*
Inline Table Valued Function
FUNCTION بالا با استفاده از VIEW ایجاد
*/
DROP FUNCTION IF EXISTS dbo.Func_Customers_Info;
GO

CREATE FUNCTION dbo.Func_Customers_Info (@CityName NVARCHAR(50))
	RETURNS TABLE
AS
	RETURN 
		SELECT
			c.CompanyName, c.City, o.OrderID, o.OrderDate
		FROM dbo.Customers AS c
		JOIN dbo.Orders AS o
			ON c.CustomerID = o.CustomerID
			WHERE c.City = @CityName
GO

SELECT * FROM dbo.Func_Customers_Info (N'اصفهان')
GO


/*
JOIN مشاهده جزئیات سفارش کارمندان از طریق
OrderDetails با جدول Func_Customers_Info میان تابع
*/
SELECT * FROM dbo.Func_Customers_Info (N'اصفهان') AS F
JOIN dbo.OrderDetails AS od
	ON f.OrderID = od.OrderID;
GO


--------------------------------------------------------------------

--تمرین کلاسی

/*
.تابعی بنویسید که تعداد مشخصی از جدیدترین سفارش یک مشتری را نمایش دهد
پارامترهای ورودی: کد مشتری - عدد مربوط به تعداد سفارشات جدید

OrderID   CustomerID            OrderDate
-------   -----------    -----------------------
 11011       1            2016-04-09 00:00:00.000
 10952       1            2016-03-16 00:00:00.000
 10835       1            2016-01-15 00:00:00.000
 10702       1            2015-10-13 00:00:00.000
 10692       1            2015-10-03 00:00:00.000

(5 row(s) affected)
*/
ALTER FUNCTION dbo.Func_latest_orders (@CustomerID Int, @OrderCount INT)
	RETURNS TABLE
AS
	RETURN
	SELECT TOP (@OrderCount)
		o.CustomerID,
		o.OrderID,
		o.OrderDate
	FROM dbo.Orders AS o
		WHERE o.CustomerID = @CustomerID
	ORDER BY o.OrderDate DESC
GO

SELECT * FROM dbo.Func_latest_orders (14, 3)


/*
Multi Statement Table-Value FUNCTION
*/

--CREATE FUNCTION Statement (Multi Statement Table Valued)
/*
CREATE FUNCTION [owner_name.] function_name 
    ({@parameter [AS] type [= default]}[,...n ]) 
	RETURNS @return_variable TABLE < table_type_definition > 
AS
	BEGIN 
	    function_body 
	    RETURN
	END
*/

DROP FUNCTION IF EXISTS dbo.Multi_Statement_Table_Valued;
GO

CREATE FUNCTION dbo.Multi_Statement_Table_Valued()
	RETURNS @Tbl TABLE (Col1 INT, Col2 NVARCHAR(100))
AS
	BEGIN
		INSERT @Tbl
		VALUES (1,'Hello'), (2,'SQL')
		RETURN
	END
GO

SELECT * FROM dbo.Multi_Statement_Table_Valued()
GO

-- APPLY

SELECT
	E1.EmployeeID AS E1_Emp, E2.EmployeeID AS E2_Emp
FROM dbo.Employees AS E1
CROSS APPLY
	 dbo.Employees AS E2; -- .را دارد CROSS JOIN همان کارکرد
GO
--------------------------------------------------------------------

/*
APPLY & Derived Table
*/

-- نمایش 3 سفارش اخیر مشتری 1 
SELECT
	TOP (3) O.CustomerID, O.OrderID, O.OrderDate
FROM dbo.Orders AS O
	WHERE O.CustomerID = 1 -- 1 ... 91
ORDER BY O.OrderDate DESC;
GO

/*
نمایش 3 سفارش اخیر هر مشتری 
APPLY در سمت راست عملگر Derived Table با استفاده از
*/
SELECT
	C.CustomerID, Tmp.OrderID, Tmp.OrderDate
FROM dbo.Customers AS C
CROSS APPLY
	(SELECT
		TOP (3) O.OrderID, O.OrderDate
	 FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
	 ORDER BY O.OrderDate DESC) AS Tmp
ORDER BY C.CustomerID;
GO

/*
نمایش سه سفارش اخیر هر مشتری حتی مشتریان فاقد سفارش 
APPLY در سمت راست عملگر Derived Table با استفاده از
*/
SELECT
	C.CustomerID, Tmp.OrderID, Tmp.OrderDate
FROM dbo.Customers AS C
OUTER APPLY
	(SELECT
		TOP (3) O.OrderID, O.OrderDate
	 FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
	 ORDER BY O.OrderDate DESC) AS Tmp
ORDER BY C.CustomerID;
GO
--------------------------------------------------------------------

/*
APPLY & TVF
*/

/*
تابعی که قبلا به عنوان تمرین کلاسی نوشته بودید

DROP FUNCTION IF EXISTS dbo.Top_Orders;
GO

CREATE FUNCTION dbo.Top_Orders(@CustID AS INT, @n AS TINYINT)
RETURNS TABLE
AS
RETURN
	SELECT
		TOP (@n) OrderID, CustomerID, OrderDate
	FROM dbo.Orders
		WHERE CustomerID = @CustID
	ORDER BY OrderDate DESC, OrderID DESC;
GO
*/

-- فراخوانی تابع
SELECT * FROM dbo.Top_Orders(1,3);
GO

/*
نمایش سه سفارش اخیر هر مشتری 
APPLY در سمت راست عملگر TVF با استفاده از
*/
SELECT
	C.CustomerID,
	T.OrderID, T.OrderDate
FROM dbo.Customers AS C
CROSS APPLY dbo.Top_Orders(C.CustomerID,5) AS T;
GO