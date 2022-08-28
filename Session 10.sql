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