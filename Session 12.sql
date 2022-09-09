use SampleDb
use NikamoozDB
/*
Session 12
*/

DROP TABLE IF EXISTS dbo.InsertVal1;
GO

CREATE TABLE dbo.InsertVal1
(
	ID INT,
	Family NVARCHAR(100),
	City NVARCHAR(50),
	DateRegister DATE
);
GO

INSERT INTO dbo.InsertVal1 (ID, Family, City, DateRegister)
	VALUES (1, N'احمدی', N'تهران', '2019-01-01');
GO

SELECT * FROM dbo.InsertVal1;
GO


/*
Table Value Constructor
.به‌بعد امکان درج بیش از یک رکورد در هر لحظه فراهم شد SQL 2008 از
*/
INSERT INTO dbo.Insert_Val1 --(ID, Family, City, DateRegister)
	VALUES	(2, N'محمدی', N'شیراز', '20150211'),
			(3, N'اکبری', N'تبریز', GETDATE());
GO

SELECT * FROM dbo.Insert_Val1;
GO

-- .این فرایند اتمیک است
INSERT INTO dbo.Insert_Val1
	VALUES	(4, N'شادکام', N'اراک', '20150211'),
			(5, N'خسروی', N'ایلام', 'UNKNOWN');
GO

SELECT * FROM dbo.Insert_Val1;
GO
--------------------------------------------------------------------

/*
INSERT در عملیات DEFAULT و NULL بررسی مقادیر
*/

DROP TABLE IF EXISTS dbo.Insert_Val2;
GO


CREATE TABLE dbo.Insert_Val2
(
	ID INT NOT NULL,
	Family NVARCHAR(50) NOT NULL,
	City NVARCHAR(20),
	DateRegister DATE DEFAULT GETDATE()
);
GO

INSERT INTO dbo.Insert_Val2 (id, family)
	VALUES (1, N'partoei');
GO

SELECT * FROM dbo.Insert_Val2;
GO

INSERT INTO dbo.Insert_Val2 
	VALUES (1, N'Saadat', DEFAULT, DEFAULT);
GO

--Forbidden INSERT operations
DROP TABLE IF EXISTS dbo.Insert_Val3;
GO


CREATE TABLE dbo.Insert_Val3
(
	ID TINYINT,
	Family NVARCHAR(50),
	City NVARCHAR(20),
	DateRegister DATE
);
GO

INSERT INTO dbo.Insert_Val3 
	VALUES (256, N'Saadat',N'BandarAbbas','547123');
GO

INSERT INTO dbo.Insert_Val3 
	VALUES (255, N'Saadat',N'BandarAbbas','2019');
GO

SELECT * FROM dbo.Insert_Val3;
GO

-- Insert and Identity
DROP TABLE IF EXISTS dbo.Insert_Val4;
GO


CREATE TABLE dbo.Insert_Val4
(
	Code INT,
	ID INT IDENTITY,
	Family NVARCHAR(50),
	City NVARCHAR(20),
	DateRegister DATE
);
GO

INSERT INTO dbo.Insert_Val4 
	VALUES (1, N'Bahmani',N'Esfahan',GETDATE());
GO

SELECT * FROM dbo.Insert_Val4;
GO

- عملیات درج غیرمجاز
INSERT INTO dbo.Insert_Val4
	VALUES	(1, 2, N'بهمنی', N'اصفهان', GETDATE());
GO

SELECT * FROM dbo.Insert_Val4;
GO

/*
روش اول:
حذف این قابلیت از فیلد

روش دوم:
INSERT_IDENTITY ON استفاده از تنظیمات
*/

SET IDENTITY_INSERT dbo.Insert_Val4 ON;
GO

-- IDENTITY درج غیرمجاز به‌دلیل عدم انتخاب نام فیلد حاوی
INSERT INTO dbo.Insert_Val4
	VALUES	(2, 2, N'محمودی', N'شیراز', '20190315');
GO

SELECT * FROM dbo.Insert_Val4;
GO

INSERT INTO dbo.Insert_Val4 (Code, ID, Family, City, DateRegisteR)
	VALUES	(2, 2, N'محمودی', N'شیراز', '20190315');
GO

SELECT * FROM dbo.Insert_Val4;
GO

INSERT INTO dbo.Insert_Val4 (Code, ID, Family, City, DateRegisteR)
	VALUES	(3, 2, N'فروهر', N'مشهد', '20191021'),
			(4, 100, N'کاویانی', N'تهران', '20191201');
GO

SELECT * FROM dbo.Insert_Val4;
GO

/*
INSERT_IDENTITY غیر‌فعال کردن قابلیت

1: جاری Session خارج شدن از
2: IDENTITY_INSERT کردن OFF
*/

SET IDENTITY_INSERT dbo.Insert_Val4 OFF;
GO

INSERT INTO dbo.Insert_Val4
	VALUES	(5, N'جدیدی', N'همدان', '20190215');
GO

SELECT * FROM dbo.Insert_Val4;
GO

/*
در سایت نیک‌آموز IDENTITY لینک مقالات
http://nikamooz.com/what-is-identity-01/
*/

/*
INSERT INTO <table_name1> (column1, column2, ...)
SELECT Statement;
*/

DROP TABLE IF EXISTS dbo.Insert_Select;
GO

CREATE TABLE dbo.Insert_Select
(
	CustomerID INT,
	LastName NVARCHAR(50),
	City NVARCHAR(20)
);
GO

-- نمایش تمامی اطلاعات مربوط به مشتریان تهرانی و کارمندان مرتبط با ثبت‌سفارش 
SELECT
	DISTINCT C.CustomerID, C.City, E.LastName
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON O.CustomerID = C.CustomerID
JOIN Employees AS E
	ON E.EmployeeID = O.EmployeeID
	WHERE C.City = N'تهران';
GO

SELECT
	C.CustomerID, C.City, Tmp.LastName
FROM dbo.Customers AS C
CROSS APPLY
	(SELECT E.LastName FROM dbo.Employees AS E
		WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
							WHERE O.EmployeeID = E.EmployeeID
							AND O.CustomerID = C.CustomerID)) AS Tmp 
	WHERE C.City = N'تهران' 
ORDER BY C.CustomerID;
GO

INSERT INTO dbo.Insert_Select
SELECT
	C.CustomerID, Tmp.LastName, C.City
FROM dbo.Customers AS C
CROSS APPLY
	(SELECT E.LastName FROM dbo.Employees AS E
		WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
							WHERE O.EmployeeID = E.EmployeeID
							AND O.CustomerID = C.CustomerID
							AND C.City = N'تهران')) AS Tmp ORDER BY C.CustomerID;
GO

SELECT * FROM dbo.Insert_Select
ORDER BY CustomerID;
GO


/*
SELECT INTO یا Make Table Query

.جدول مقصد نباید از قبل وجود داشته باشد

:آن‌چه منتقل می‌شود
 ساختار جدول و رکوردهای آن

:آن‌چه منتقل نمی‌شود
Permission ،محدودیت‌ها، ایندکس ، تریگر‌
*/

DROP TABLE IF EXISTS dbo.Orders1,dbo.Orders2,dbo.Orders3;
GO

-- کپی از جدول بر اساس تمامی فیلدهای آن
SELECT * INTO dbo.Orders1
FROM dbo.Orders;
GO

SELECT * FROM dbo.Orders1;
GO

-- کپی از جدول بر اساس برخی از فیلدهای آن
SELECT
	OrderID, CustomerID
INTO dbo.Orders2
FROM dbo.Orders
	WHERE OrderID > 11076;
GO

SELECT * FROM dbo.Orders2;
GO

SELECT
	OrderID,CustomerID
INTO dbo.Orders3
FROM dbo.Orders
	WHERE OrderID > 1000000;
GO

SELECT * FROM dbo.Orders3;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
مشتریان دارای سفارش شامل کد مشتری، شهر و کد سفارش
*/

DROP TABLE IF EXISTS dbo.Cust_Ord;
GO

-- JOIN با استفاده از
SELECT
	C.CustomerID, C.City, O.OrderID
INTO dbo.Cust_Ord
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID;
GO

DROP TABLE IF EXISTS dbo.Cust_Ord;
GO
-- Subquery با استفاده از
SELECT
	O.CustomerID, O.OrderID,
	(SELECT C.City FROM dbo.Customers AS C
		WHERE C.CustomerID = O.CustomerID) AS City
INTO dbo.Cust_Ord
FROM dbo.Orders AS O;
GO

-- عملیات غیرمجاز
SELECT *
INTO dbo.Cust_Ord
FROM
SELECT
	C.CustomerID, C.City, O.OrderID
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID;
GO

DROP TABLE IF EXISTS dbo.Cust_Ord;
GO
-- عملیات مجاز
SELECT
*
INTO dbo.Cust_Ord
FROM (SELECT
		C.CustomerID, C.City, O.OrderID
	  FROM dbo.Customers AS C
	  JOIN dbo.Orders AS O
		ON C.CustomerID = O.CustomerID) AS Tmp;
GO

SELECT * FROM dbo.Cust_Ord;
GO


/*
DELETE FROM <table_name>
	WHERE condition;
*/

DROP TABLE IF EXISTS dbo.DELETE_ChildTbl, dbo.DELETE_ParentTbl;
GO

CREATE TABLE dbo.DELETE_ParentTbl
(
	ID INT IDENTITY PRIMARY KEY,
	Code VARCHAR(10),
	City NVARCHAR(20)
);
GO

INSERT INTO dbo.DELETE_ParentTbl
	VALUES ('CD-01', N'تهران'),('CD-02', N'تهران'),('CD-03', N'تهران'),
		   ('CD-04', N'اصفهان'),('CD-05', N'مشهد'),('CD-06', N'تبریز'),
		   ('CD-07', N'شیراز'),('CD-08', N'تبریز'),('CD-09', N'مشهد'),
		   ('CD-10', N'رشت'),('CD-11', N'رشت'),('CD-12', N'رشت');
GO

SELECT * FROM dbo.DELETE_ParentTbl;
GO

/*
حذف تمامی رکوردهای یک جدول
DELETE dbo.DELETE_ParentTbl;
GO
*/

-- .حذف تمامی رکوردهایی که شهر آن‌ها رشت است
DELETE FROM dbo.DELETE_ParentTbl
	WHERE City = N'رشت';
GO

SELECT * FROM dbo.DELETE_ParentTbl;
GO
--------------------------------------------------------------------

/*
Parent/Child عملیات حذف با جداول
!!!در کلاس، این دو جدول را بر روی سرور هم ایجاد کنم
*/

CREATE TABLE dbo.DELETE_ChildTbl
(
	ID INT REFERENCES dbo.DELETE_ParentTbl(ID), -- ON DELETE CASCADE
	OrderID INT
);
GO

INSERT INTO dbo.DELETE_ChildTbl
	VALUES 
		   (1,1001),(1,1002),(1,1003),(2,1004),(2,1005),(2,1006),
		   (3,1007),(3,1008),(3,1009),(4,1010),(4,1011),(4,1012),
		   (5,1013),(6,1014),(7,1015),(8,1016),(9,1017),(9,1018);
GO

SELECT * FROM dbo.DELETE_ParentTbl;
SELECT * FROM dbo.DELETE_ChildTbl;

-- عدم انجام عملیات حذف رکوردها از جدول پدر
DELETE FROM dbo.DELETE_ParentTbl
	WHERE City = N'مشهد';
GO

-- مشاهده محدودیت‌های موجود بر روی جدول فرزند
sp_helpconstraint 'dbo.DELETE_ChildTbl';
GO
--------------------------------------------------------------------

/*
DELETE و JOIN
*/

SELECT
	C.ID, C.OrderID
FROM dbo.DELETE_ChildTbl AS C
JOIN dbo.DELETE_ParentTbl AS P
	ON P.ID = C.ID
	WHERE P.City = N'تبریز';
GO

/*
.که شهر آن‌ها برابر با تبریز باشد Child حذف تمامی رکوردهایی از جدول
!نکته مربوط به رابطه پدر و فرزندی جداول فراموش نشود
*/
DELETE FROM P
FROM dbo.DELETE_ChildTbl AS C
JOIN dbo.DELETE_ParentTbl AS P
	ON P.ID = C.ID
	WHERE P.City = N'تبریز';
GO

/*
تمرین کلاسی
کوئری بالا را به‌گونه‌ای بازنویسی کنید
.باشد FROM فقط شامل یک DELETE که دستور
*/

DELETE FROM P
FROM dbo.DELETE_ChildTbl AS C
JOIN dbo.DELETE_ParentTbl AS P
	ON P.ID = C.ID
	WHERE P.City = N'تبریز';
GO



DELETE FROM dbo.DELETE_ParentTbl
	WHERE EXISTS (SELECT 1 FROM dbo.DELETE_ChildTbl AS C
					WHERE C.ID = dbo.DELETE_ParentTbl.ID
					AND dbo.DELETE_ParentTbl.City = N'تبریز');
GO
--------------------------------------------------------------------

/*
DELETE و Subquery
*/

-- .حذف تمامی رکوردهایی که شهر آن‌ها برابر با شیراز باشد
DELETE FROM dbo.DELETE_ChildTbl
	WHERE EXISTS (SELECT P.ID FROM dbo.DELETE_ParentTbl AS P
						WHERE P.ID = dbo.DELETE_ChildTbl.ID
						AND P.City = N'شیراز');
GO

-- معادل کوئری بالا 
DELETE FROM C
FROM dbo.DELETE_ChildTbl AS C
	WHERE EXISTS (SELECT P.ID FROM dbo.DELETE_ParentTbl AS P
						WHERE P.ID = C.ID
						AND P.City = N'شیراز');
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
.ایجاد کنید Employees را به‌کمک جدول EmployeeAge ابتدا جدولی با عنوان


    EmployeeAge
---------------------
EmployeeID	Birthdate

تمامی کارمندان بالای 50 سال حذف شود EmployeeAge سپس از جدول
EmployeeID
-----------
   1
   2
   4
   5
*/

DROP TABLE IF EXISTS dbo.EmployeeAge;
GO

SELECT
	E.EmployeeID, E.Birthdate
INTO dbo.EmployeeAge
FROM dbo.Employees AS E;
GO

DELETE dbo.EmployeeAge
	WHERE DATEDIFF(YEAR,Birthdate,GETDATE()) > 51;
GO
