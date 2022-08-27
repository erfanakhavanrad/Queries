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