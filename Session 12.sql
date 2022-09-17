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

/*
TRUNCATE اسکریپت دستور

TRUNCATE TABLE <table_name>
*/

DROP TABLE IF EXISTS dbo.TRUNCATE_Tbl;
GO

CREATE TABLE dbo.TRUNCATE_Tbl
(
	ID INT IDENTITY,
	Code VARCHAR(10),
	City NVARCHAR(20)
);
GO

INSERT INTO dbo.TRUNCATE_Tbl
	VALUES ('CD-01', N'تهران'),('CD-02', N'تهران'),('CD-03', N'تهران'),
		   ('CD-04', N'اصفهان'),('CD-05', N'مشهد'),('CD-06', N'تبریز'),
		   ('CD-07', N'شیراز'),('CD-08', N'تبریز'),('CD-09', N'مشهد');
GO

SELECT * FROM dbo.TRUNCATE_Tbl;
GO

-- عملیات غیرمجاز
TRUNCATE TABLE dbo.TRUNCATE_Tbl
	WHERE City = N'تهران';
GO

TRUNCATE TABLE dbo.TRUNCATE_Tbl;
GO

-- می‌شود Reset مجددا IDENTITY فیلد دارای
INSERT INTO dbo.TRUNCATE_Tbl
	VALUES ('CD-01', N'تهران'),('CD-02', N'تهران'),('CD-03', N'تهران'),
		   ('CD-04', N'اصفهان'),('CD-05', N'مشهد'),('CD-06', N'تبریز'),
		   ('CD-07', N'شیراز'),('CD-08', N'تبریز'),('CD-09', N'مشهد');
GO

SELECT * FROM dbo.TRUNCATE_Tbl;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.TRUNCATE_PT, dbo.TRUNCATE_CT;
GO

CREATE TABLE dbo.TRUNCATE_PT
(
	ID INT IDENTITY PRIMARY KEY,
	Code VARCHAR(10),
	City NVARCHAR(20)
);
GO

INSERT INTO dbo.TRUNCATE_PT
	VALUES ('CD-01', N'تهران'),('CD-02', N'تهران'),('CD-03', N'تهران'),
		   ('CD-04', N'اصفهان'),('CD-05', N'مشهد'),('CD-06', N'تبریز'),
		   ('CD-07', N'شیراز'),('CD-08', N'تبریز'),('CD-09', N'مشهد');
GO

CREATE TABLE dbo.TRUNCATE_CT
(
	ID INT REFERENCES dbo.TRUNCATE_PT(ID) ON DELETE CASCADE,
	OrderID INT
);
GO

INSERT INTO dbo.TRUNCATE_CT
	VALUES (1,1001),(1,1002),(1,1003),(2,1004),(2,1005),(2,1006),
		   (3,1007),(3,1008),(3,1009),(4,1010),(4,1011),(4,1012),
		   (5,1013),(6,1014),(7,1015),(8,1016),(9,1017),(9,1018);
GO

-- بر روی جدول پدر غیرمجاز است TRUNCATE عملیات
TRUNCATE TABLE dbo.TRUNCATE_PT;
GO

-- بر روی جدول فرزند مجاز است TRUNCATE عملیات
TRUNCATE TABLE dbo.TRUNCATE_CT;
GO

-- بر روی جدول پدر غیرمجاز است TRUNCATE جدول فرزند، باز هم TRUNCATE حتی پس از
TRUNCATE TABLE dbo.TRUNCATE_PT;
GO

/*
UPDATE <table_name>
	SET column1 = value1,
		column2 = value2, ...
WHERE condition;
*/

DROP TABLE IF EXISTS dbo.Customers1;
GO

SELECT * INTO dbo.customers1
FROM dbo.Customers;
GO

SELECT * FROM dbo.customers1

UPDATE dbo.customers1
	SET CompanyName = CompanyName + '*';
GO

UPDATE dbo.customers1
	SET CompanyName = REPLACE(CompanyName,'*', '');
GO

UPDATE dbo.customers1
	SET Region = N'مرکزی'
		WHERE Region = N'مرکز';
GO


-- .فاقد شرط، تمامی رکوردها را به‌روزرسانی می‌کند UPDATE عملیات
UPDATE dbo.Customers1
	SET City = N'فاقد شهر',
		Region = N'فاقد شهر';
GO

SELECT * FROM dbo.Customers1;
GO
--------------------------------------------------------------------

/*
UPDATE & JOIN
*/

SELECT * FROM dbo.Customers1 AS C
	JOIN dbo.Orders AS O
		ON C.CustomerID = O.CustomerID;
GO

UPDATE c
	SET CompanyName = CompanyName + '+'
FROM dbo.customers1 AS c
JOIN dbo.Orders AS o
	ON c.CustomerID = o.CustomerID;
GO


/*
Subquery بازنویسی کوئری بالا با استفاده از
*/
UPDATE C
	SET CompanyName = CompanyName + '++'
FROM dbo.customers1 AS c
	WHERE EXISTS (SELECT 1 FROM dbo.Orders As o
						WHERE o.CustomerID = c.CustomerID);
GO

SELECT * FROM dbo.customers1

DROP TABLE IF EXISTS dbo.update_test

CREATE TABLE dbo.update_test
(
	col1 INT,
	col2 INT
);
GO

INSERT INTO dbo.update_test
VALUES (1, 100);
GO

SELECT * FROM dbo.update_test

UPDATE dbo.UPDATE_Test
	SET Col1 = Col1 + 10,
		Col2 = Col1 + 10;
GO

SELECT * FROM dbo.UPDATE_Test;
GO

DELETE FROM dbo.UPDATE_Test;
GO

INSERT INTO dbo.UPDATE_Test
	VALUES (1,100);
GO

SELECT * FROM dbo.UPDATE_Test;
GO

-- جابه‌جایی مقادیر ستون‌ها
UPDATE dbo.UPDATE_Test
	SET Col1 = Col2,
		Col2 = Col1;
GO

SELECT * FROM dbo.UPDATE_Test;
GO

-- MERGE
DROP TABLE IF EXISTS dbo.S_Customers, dbo.T_Customers;
GO

-- Target جدول
CREATE TABLE dbo.T_Customers
(
	CustomerID INT NOT NULL PRIMARY KEY,
	CompanyName NVARCHAR(25) NOT NULL,
	City NVARCHAR(20) NOT NULL,
	Phone VARCHAR(15) NOT NULL
);
GO

-- Source جدول
CREATE TABLE dbo.S_Customers
(
	CustomerID INT NOT NULL PRIMARY KEY,
	CompanyName NVARCHAR(25) NOT NULL,
	City NVARCHAR(20) NOT NULL,
	Phone VARCHAR(15) NOT NULL
);
GO

INSERT INTO dbo.T_Customers
	VALUES	(1, N'شرکت تهران 1', N'تهران', '(021) 222-1111'),
			(2, N'شرکت تهران 2', N'تهران', '(021) 222-2222'),
			(3, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-1111'),
			(4, N'شرکت شیراز 1', N'شیراز', '(071) 777-1111'),
			(5, N'شرکت مشهد 1', N'مشهد', '(051) 555-1111');
GO

INSERT INTO dbo.S_Customers
	VALUES	(2, N'شرکت پردیس', N'پردیس', '(021) 222-2222'), -- تغییر یافته
			(3, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-1111'), -- بدون تغییر
			(5, N'شرکت مشهد 1', N'مشهد', '(051) 555-0000'), -- تغییر یافته
			(6, N'شرکت مشهد 2', N'مشهد', '(051) 555-1111'), -- جدید
			(7, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-1111');-- جدید
GO

/*
سناریو
T_Customers می‌خواهیم اطلاعات مشتریانی را که در جدول
.به آن اضافه کنیم S_Customers وجود ندارند، از جدول 

ضمنا می‌خواهیم به‌ازای رکوردهای مشابه در این دو جدول
.نیز انجام شود T_Customers عملیات به‌روزرسانی مقادیر فیلدهای جدول
*/

/*
MERGE <Target_TableName>
USING <Source_TableName>
	ON Predicate
WHEN MATCHED THEN -- تطابق داشته باشد T با رکورد جدول S زمانی که رکورد جدول
	UPDATE | DELETE
WHEN NOT MATCHED THEN -- تطابق نداشته باشد T با رکورد جدول S زمانی که رکورد جدول
	INSERT
WHEN NOT MATCHED BY SOURCE THEN -- تطابق نداشته باشد S با رکورد جدول T زمانی که رکورد جدول
	DELETE;
*/

SELECT * FROM dbo.T_Customers;
SELECT * FROM dbo.S_Customers;
GO

MERGE INTO dbo.T_Customers AS T -- TARGET جدول
USING dbo.S_Customers AS S -- Source جدول
	ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN -- تطابق داشته باشد T با رکورد جدول S زمانی که رکورد جدول
UPDATE
	SET	T.CompanyName = S.CompaNyname,
		T.phone = S.Phone,
		T.City = S.City
WHEN NOT MATCHED THEN -- تطابق نداشته باشد T با رکورد جدول S زمانی که رکورد جدول
INSERT (CustomerID, CompanyName, Phone, City)
VALUES (S.CustomerID, S.CompanyName, S.Phone, S.City); /*خاتمه این دستور حتما باید با سمی کولن باشد*/
GO

SELECT * FROM dbo.S_Customers;
SELECT * FROM dbo.T_Customers;
GO
-------------------------------------------------------------------

/*
SQL Server قابلیت اضافی در
WHEN NOT MATCHED BY SOURCE THEN
*/

SELECT * FROM dbo.T_Customers;
GO

MERGE INTO dbo.T_Customers AS T
USING dbo.S_Customers AS S
	ON T.CustomerID = S.CustomerID
WHEN NOT MATCHED BY SOURCE THEN -- تطابق نداشته باشد S با رکورد جدول T زمانی که رکورد جدول
	DELETE;
GO

SELECT * FROM dbo.S_Customers;
SELECT * FROM dbo.T_Customers;
GO

-- OUTPUT
DROP TABLE IF EXISTS dbo.OUTPUT_Insert;
GO

CREATE TABLE dbo.OUTPUT_Insert
(
	ID INT IDENTITY,
	City NVARCHAR(20)	
);
GO

INSERT INTO dbo.OUTPUT_Insert
	VALUES (N'تهران'),(N'مشهد'),(N'تبریز'),(N'شیراز'),(N'اصفهان');
GO

SELECT @@IDENTITY, SCOPE_IDENTITY(), IDENT_CURRENT('dbo.OUTPUT_Insert');
GO

INSERT INTO dbo.OUTPUT_Insert
		OUTPUT
		inserted.ID
	VALUES (N'اهواز'),(N'کرمان'),(N'رشت');
GO

/*
OUTPUT ذخیره نتایج
جدول مورد‌نظر می‌بایست از قبل وجود داشته باشد
*/

CREATE TABLE #OUTPUT_Tbl
(
	ID INT
);
GO

INSERT INTO dbo.OUTPUT_Insert
		OUTPUT -- در جدول موردنظر OUTPUT جهت ذخیره خروجی
		inserted.ID INTO #OUTPUT_Tbl 
		OUTPUT -- در خروجی OUTPUT جهت نمایش محتویات
		inserted.ID,
		inserted.City
	VALUES (N'اهواز'),(N'کرمان'),(N'رشت');
GO

SELECT * FROM #OUTPUT_Tbl;
GO
--------------------------------------------------------------------

/*
OUTPUT & DELETE
*/

DROP TABLE IF EXISTS dbo.OUTPUT_Delete;
GO

SELECT * INTO dbo.OUTPUT_Delete
FROM dbo.Orders;
GO

DELETE FROM dbo.OUTPUT_Delete
		OUTPUT
			deleted.OrderID,
			deleted.OrderDate,
			deleted.CustomerID
	WHERE OrderDate >= '2016-02-06';
GO
--------------------------------------------------------------------

/*
OUTPUT & UPDATE
*/

DROP TABLE IF EXISTS dbo.OUTPUT_Update;
GO

SELECT * INTO dbo.OUTPUT_Update
FROM dbo.Employees;
GO

UPDATE dbo.OUTPUT_Update
	SET Region = N'مرکزی'
		OUTPUT
		inserted.Region AS NewVal,
		deleted.Region AS OldVal
	WHERE Region = N'مرکز';
GO
--------------------------------------------------------------------

/*
OUTPUT & MERGE
*/

DROP TABLE IF EXISTS dbo.S_Customers,dbo.T_Customers;
GO

-- Target جدول
CREATE TABLE dbo.T_Customers
(
	CustomerID INT NOT NULL PRIMARY KEY,
	CompanyName NVARCHAR(25) NOT NULL,
	City NVARCHAR(20) NOT NULL,
	Phone VARCHAR(15) NOT NULL
);
GO

-- Source جدول
CREATE TABLE dbo.S_Customers
(
	CustomerID INT NOT NULL PRIMARY KEY,
	CompanyName NVARCHAR(25) NOT NULL,
	City NVARCHAR(20) NOT NULL,
	Phone VARCHAR(15) NOT NULL
);
GO

INSERT INTO dbo.T_Customers
	VALUES	(1, N'شرکت تهران 1', N'تهران', '(021) 222-1111'),
			(2, N'شرکت تهران 2', N'تهران', '(021) 222-2222'),
			(3, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-1111'),
			(4, N'شرکت شیراز 1', N'شیراز', '(071) 777-1111'),
			(5, N'شرکت مشهد 1', N'مشهد', '(051) 555-1111');
GO

INSERT INTO dbo.S_Customers
	VALUES	(2, N'شرکت پردیس', N'پردیس', '(021) 222-2222'), -- تغییر یافته
			(3, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-33333'), -- بدون تغییر
			(5, N'شرکت مشهد 1', N'مشهد', '(051) 555-0000'), -- تغییر یافته
			(6, N'شرکت مشهد 2', N'مشهد', '(051) 555-1111'), -- جدید
			(7, N'شرکت اصفهان 1', N'اصفهان', '(031) 333-1111');-- جدید
GO

SELECT * FROM dbo.S_Customers;
SELECT * FROM dbo.T_Customers;

MERGE INTO dbo.T_Customers AS T
USING dbo.S_Customers AS S
	ON T.CustomerID = S.CustomerID
WHEN MATCHED THEN
UPDATE
	SET	T.CompanyName = S.CompaNyname,
		T.phone = S.Phone,
		T.City = S.City
WHEN NOT MATCHED THEN
INSERT (CustomerID, CompanyName, Phone, City)
VALUES
	(S.CustomerID, S.CompanyName, S.Phone, S.City)
OUTPUT
	$Action AS Act,
	deleted.CompanyName AS Old_Value,
	inserted.CompanyName AS New_Value,
	inserted.CustomerID;
GO

-- OTHER

/*
نکات تکمیلی در خصوص انواع عملیات دست‌کاری داده‌ها
*/


/*
DML روش‌های تشخیص داده‌های تاثیر پذیر قبل از عملیات

روش اول
جهت شناسایی رکوردها SELECT استفاده از دستور

روش دوم
Table Expression
*/

DROP TABLE IF EXISTS dbo.Odetails;
GO

SELECT * INTO dbo.Odetails FROM dbo.OrderDetails;
GO

UPDATE OD
	SET Discount += 0.05
FROM dbo.Odetails AS OD
	JOIN dbo.Orders AS O
		ON OD.OrderID = O.OrderID
	WHERE O.CustomerID = 1;
GO

-- CTE
WITH C AS
(
	SELECT
		O.CustomerID, OD.OrderID, Productid, Discount, Discount + 0.05 AS NewDiscount
	FROM dbo.Odetails AS OD
		JOIN dbo.Orders AS O
			ON OD.OrderID = O.OrderID
		WHERE O.CustomerID = 1
)
UPDATE C
	SET Discount = NewDiscount;
GO

-- Derived Table
UPDATE Tmp
	SET Discount = NewDiscount
FROM (SELECT
		CustomerID, OD.OrderID, Productid, Discount, Discount + 0.05 AS NewDiscount
	  FROM dbo.Odetails AS OD
	  JOIN dbo.Orders AS O
			ON OD.OrderID = O.OrderID
		WHERE O.CustomerID = 1) AS Tmp;
GO
--------------------------------------------------------------------

/*
دست‌کاری داده‌های زیاد بر اساس دسته‌بندی

OFFSET و TOP عدم استفاده از قابلیت‌های
چرا که در عملیات دست‌کاری داده‌ها
.استفاده کرد ORDER BY نمی‌توان از
صرفا این عملیات براساس تعداد رکوردهایی که در 
.فرایند دست‌‌کاری تاثیر می‌پذیرند، انجام خواهد شد

Table Expression راه‌کار: استفاده از 
*/

DROP TABLE IF EXISTS dbo.Orders1;
GO

SELECT * INTO dbo.Orders1 FROM dbo.Orders;
GO

-- عملیات غیرمجاز
DELETE TOP(50) FROM dbo.Orders1
ORDER BY OrderID DESC;
GO

-- صرفا 50 رکورد حذف می‌شود
DELETE TOP(50) FROM dbo.Orders1;
GO

WITH CTE AS
(
	SELECT TOP(50) * FROM dbo.Orders1
	ORDER BY OrderID
)
DELETE FROM CTE;
GO

WITH CTE AS
(
	SELECT * FROM dbo.Orders1
	ORDER BY OrderID
	OFFSET 0 ROWS FETCH FIRST 50 ROWS ONLY
)
DELETE FROM CTE;
GO