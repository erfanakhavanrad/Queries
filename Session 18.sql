use SampleDb
use NikamoozDB
/*
Session 18
*/

--01- NonClustered Index

use AdventureWorks
Go

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.SalesOrderDetail2;
GO

-- Sales.SalesOrderDetail تهیه کپی از جدول
SELECT * INTO dbo.SalesOrderDetail2 FROM Sales.SalesOrderDetail;
GO

SP_HELPINDEX SalesOrderDetail2
GO

/*
ProductID اعمال جستجو بر روی فیلد 
IO, Execution Plan بررسی 
*/
SET STATISTICS IO ON;
GO

SELECT * FROM dbo.SalesOrderDetail2
	WHERE ProductID = 900;
GO


--------------------------------------------------------------------

-- SalesOrderDetail2 بر روی جدول NONCLUSTERED INDEX ایجاد
CREATE NONCLUSTERED INDEX IX_ProductID ON dbo.SalesOrderDetail2(ProductID);
GO
/*
.معادل دستور بالا است
CREATE INDEX IX_ProductID ON dbo.SalesOrderDetail2(ProductID);
GO
*/

-- مشاهده ایندکس
SP_HELPINDEX SalesOrderDetail2;
GO

-- IO, Execution Plan بررسی 
SELECT * FROM dbo.SalesOrderDetail2
	WHERE ProductID  = 900;
GO
--------------------------------------------------------------------

-- IO, Execution Plan بررسی 
SELECT * FROM dbo.SalesOrderDetail2
	WHERE ProductID = 900;
GO
SELECT * FROM dbo.SalesOrderDetail2 WITH(INDEX(0))
	WHERE ProductID = 900;
GO
--------------------------------------------------------------------

/*
بررسی ساخت ایندکس در یک فضای دیگر
*/
SET STATISTICS IO OFF;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.SalesOrderDetail2;
GO
-- Sales.SalesOrderDetail تهیه کپی از جدول
SELECT * INTO dbo.SalesOrderDetail2 FROM Sales.SalesOrderDetail
GO

-- SalesOrderDetail2 های جدولPage مشاهده تعداد 
SELECT
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks'), OBJECT_ID ('SalesOrderDetail2'),
		NULL, NULL, 'DETAILED'
	)
GROUP BY page_type_desc;
GO

-- SalesOrderDetail2 بر روی جدول NONCLUSTERED INDEX ایجاد
CREATE NONCLUSTERED INDEX IX_ProductID ON dbo.SalesOrderDetail2(ProductID);
GO

-- SalesOrderDetail2 های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks'), OBJECT_ID('SalesOrderDetail2'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc;
GO

--اصل رکوردهای جدول
SELECT * FROM dbo.SalesOrderDetail2;
GO

-- NonClustered شبیه‌سازی در فضای
SELECT 
	'Other Info', ProductID
FROM dbo.SalesOrderDetail2
ORDER BY ProductID;
GO


-- آنالیز ایندکس
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('SalesOrderDetail2'),
	NULL,
	NULL,
	'DETAILED'
);
GO
--------------------------------------------------------------------

USE Index_DB;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.Employees;
GO
-- ایجاد جدول تستی
CREATE TABLE dbo.employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	StartYear CHAR(900)
);
GO

-- NonClustered Index بررسی ساخت 999 عدد  
DECLARE @Cmd VARCHAR(1000);
DECLARE @Cnt INT = 1;
WHILE @Cnt <= 1000
	BEGIN
		SET @Cmd = 'CREATE NONCLUSTERED INDEX IX_' + CAST(@Cnt AS VARCHAR(100))+ ' ON dbo.employees(StartYear)';
		PRINT @Cmd
		EXEC (@Cmd);
		SET @Cnt += 1;
	END
GO

-- مشاهده ایندکس‌های جدول‎‌
SP_HELPINDEX Employees;
GO
--------------------------------------------------------------------

/*
SQL Server بررسی افزایش طول کلید ایندکس در 
تست در حالت های
CHAR,NCHAR,NVARCHAR,
*/

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.Employees;
GO
-- ایجاد جدول تستی
CREATE TABLE dbo.Employees
(
	ID CHAR(900),
	FirstName NVARCHAR(3000),
	LastName NVARCHAR(3000),
	Barcode  CHAR(1700) -- NCHAR \ NVARCHAR
);
GO

CREATE INDEX IX_Barcode ON dbo.Employees(Barcode);
GO

--02- NonClustered On Heap

--ایجاد بانک اطلاعاتی تستی
USE Index_DB;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.HeapTable;
GO
-- Heap ایجاد یک جدول از نوع

USE Index_DB;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.ClusteredTable;
GO
--Heap ایجاد یک جدول از نوع
CREATE TABLE dbo.ClusteredTable
(
	ID CHAR(900),
	FirstName NCHAR(1750),
	LastName NCHAR(1750),
	BirthDay DATE
);
GO

-- ClusteredTable بر روی جدول Clustered ساخت ایندکس
CREATE CLUSTERED INDEX IX_Clustered ON dbo.ClusteredTable(ID);
GO

-- ClusteredTable بر روی جدول NonClustered ساخت ایندکس
CREATE NONCLUSTERED INDEX IX_NonClustered ON dbo.ClusteredTable(BirthDay);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('Index_DB'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED');
GO

-- درج تعدادی رکورد تستی
INSERT INTO dbo.ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد','1978-01-01'),
			(5, N'پریسا', N'یزدانیان','1983-03-21'),
			(3, N'علی', N'تقوی','1990-11-25'),
			(4, N'مجید', N'پاکروان','1983-09-16'),
			(2, N'فرهاد', N'رضایی','1994-11-04'),
			(10, N'زهرا', N'غفاری','1988-07-13'),
			(8, N'مهدی', N'پوینده','1985-12-06'),
			(9, N'سمانه', N'اکبری','1996-09-28'),
			(7, N'بیژن', N'تولایی','1990-05-13'),
			(6, N'فاطمه', N'شریفی','1984-08-13');
GO

--بررسی حجم جدول
SP_SPACEUSED ClusteredTable;
GO

/*
بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
! در یک فضای دیگر ایجاد شده است NonClustered ایندکس
*/
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('Index_DB'),
		 OBJECT_ID('ClusteredTable'),
		 NULL,
		 NULL,
		 'DETAILED');
GO
--------------------------------------------------------------------

--آنالیز ایندکس

/*
صحفات وابسته به جدول
های تخصیص یافتهPage تعداد 
.را جداگانه داریم ClusteredTable ,NonClustered توجه شود که در درخت وابسته به ایندکس

.می‌باشد Nonclustered های Page و Clustered های ریشه و سطح میانی Page ها شامل Index Page تعداد
*/
SELECT 
	COUNT(*), page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Index_DB'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc;
GO

/*
صحفات وابسته به جدول
را جداگانه داریمClusteredTable , NonClustered توجه شود که در درخت وابسته به ایندکس 
*/
SELECT 
	page_type_desc, allocated_page_page_id,
	next_page_page_id, previous_page_page_id
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('Index_DB'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED'
	)
GO
--------------------------------------------------------------------

--???
USE AdventureWorks;
GO

DROP TABLE IF EXISTS dbo.SalesOrderHeader2;
GO

SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader;
GO

CREATE UNIQUE CLUSTERED INDEX IX_C_OrderDate ON dbo.SalesOrderHeader2(SalesOrderID);
GO

CREATE INDEX IX_NC_OrderDate ON dbo.SalesOrderHeader2(OrderDate);
GO

SET STATISTICS IO ON;
GO

SELECT * FROM dbo.SalesOrderHeader2
	WHERE OrderDate = '2014-01-05';
GO

SELECT * FROM dbo.SalesOrderHeader2
	WHERE OrderDate = '2014-05-01';
GO

SELECT * FROM dbo.SalesOrderHeader2 WITH(INDEX(IX_NC_OrderDate))
	WHERE OrderDate = '2014-05-01';
GO

/*
نکته مهم
. این است که تعداد رکوردهای بازگشتی آن کم باشد Nonclustered شانس اصلی برای استفاده از ایندکس
*/

USE AdventureWorks
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS SalesOrderHeader_Heap;
DROP TABLE IF EXISTS SalesOrderHeader_Clustered;
GO

-- تهیه کپی از جداول
SELECT * INTO SalesOrderHeader_Heap FROM Sales.SalesOrderHeader;
SELECT * INTO SalesOrderHeader_Clustered FROM Sales.SalesOrderHeader;
GO
--------------------------------------------------------------------

-- Heap بر روی جدول NonClustered Index ساخت 
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Heap(OrderDate);
GO

-- مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Heap;
GO

-- SalesOrderHeader_Heap بر روی جدول NonClustered شبیه‌سازی فضای ساخته‌شده با ایندکس
SELECT 
	'00:00' AS RowID,
	OrderDate
FROM SalesOrderHeader_Heap 
ORDER BY OrderDate;
GO
--------------------------------------------------------------------

-- Clustered بر روی جدول NonClustered Index ساخت 
CREATE CLUSTERED INDEX IX_SalesOrderID ON SalesOrderHeader_Clustered(SalesOrderID);
CREATE INDEX IX_OrderDate ON SalesOrderHeader_Clustered(OrderDate);
GO

-- مشاهده ایندکس های ساخته شده روی جدول
SP_HELPINDEX SalesOrderHeader_Clustered;
GO

-- SalesOrderHeader_Clustered بر روی جدول NonClustered شبیه‌سازی فضای ساخته‌شده با ایندکس
SELECT 
	SalesOrderID AS Clustered_Key,
	OrderDate
FROM SalesOrderHeader_Clustered 
ORDER BY OrderDate;
GO
--------------------------------------------------------------------

-- های مربوط به ایندکسPage آنالیز 
-- های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks'),OBJECT_ID('SalesOrderHeader_Heap'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc;
GO

-- های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks'),OBJECT_ID('SalesOrderHeader_Clustered'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc;
GO
--------------------------------------------------------------------

-- آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('SalesOrderHeader_Heap'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- آنالیز ایندکس
SELECT 
	index_type_desc,index_depth,index_level,
	page_count,record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('SalesOrderHeader_Clustered'),
	NULL,
	NULL,
	'DETAILED'
);
GO

/*
	LOOKUP
*/
/*
RID Lookup بررسی مفهوم 
*/

USE AdventureWorks;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS  dbo.HeapTable;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO dbo.HeapTable FROM Sales.SalesOrderDetail;
GO

--ایجاد ایندکس روی جدول
CREATE NONCLUSTERED INDEX IX_NonClustered ON dbo.HeapTable(ProductID,OrderQty,SpecialOfferID);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX HeapTable;
GO

-- بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED');
GO

--بررسی حجم جدول
SP_SPACEUSED HeapTable;
GO

SET STATISTICS IO ON;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO

SET STATISTICS IO ON;

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE OrderQty = 1;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable WITH(INDEX(IX_NonClustered))
	WHERE OrderQty = 1;
GO
--------------------------------------------------------------------

/*
Key Lookup بررسی مفهوم 
*/

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO dbo.ClusteredTable FROM Sales.SalesOrderDetail;
GO

-- ایجاد ایندکس روی جدول
CREATE CLUSTERED INDEX IX_Clustered ON dbo.ClusteredTable(SalesOrderID);
CREATE NONCLUSTERED INDEX IX_NonClustered ON dbo.ClusteredTable(ProductID,OrderQty,SpecialOfferID);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
SELECT
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED');
GO

-- بررسی حجم جدول
SP_SPACEUSED ClusteredTable;
GO

SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.ClusteredTable
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

-- RID Lookup نسبت به Key Lookup مربوط به IO مقایسه

SET STATISTICS TIME ON;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.ClusteredTable
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

-- Non Clustered Index مقایسه استفاده و یا عدم استفاده از 

-- Heap Table
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable WITH (INDEX(0))
	WHERE ProductID = 789;
GO

-- Clustered Table
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.ClusteredTable
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.ClusteredTable WITH(INDEX(0))
	WHERE ProductID = 789;
GO

/*
	Tipping Point
*/

USE Index_DB;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.Customers;
GO
-- ایجاد جدول تستی
CREATE TABLE dbo.Customers
(
   CustomerID INT NOT NULL,
   CustomerName CHAR(100) NOT NULL,
   CustomerAddress CHAR(100) NOT NULL,
   Comments CHAR(185) NOT NULL,
   Val INT NOT NULL
);
GO

-- Clustered Index ایجاد ایندکس 
CREATE UNIQUE CLUSTERED INDEX IX_Customers ON dbo.Customers(CustomerID);
GO

-- NonClustered Index ایجاد ایندکس 
CREATE NONCLUSTERED INDEX IX_Value ON dbo.Customers(Val);
GO

-- درج هشتاد هزار رکورد در جدول تستی
SET NOCOUNT ON;
DECLARE @i INT = 1
WHILE (@i <= 80000)
BEGIN
	INSERT INTO dbo.Customers VALUES
	(
	   @i,
	   'CustomerName' + CAST(@i AS CHAR),
	   'CustomerAddress' + CAST(@i AS CHAR),
	   'Comments' + CAST(@i AS CHAR),
	   @i
	)
	SET @i += 1;
END
GO

SELECT * FROM dbo.Customers;
GO

--بررسی ایندکس های موجود در جدول 
SP_HELPINDEX 'Customers';
GO

SET STATISTICS IO ON;
GO

SELECT * FROM dbo.Customers
	WHERE Val = 1023;
GO

SELECT * FROM dbo.Customers WITH(INDEX(0))
	WHERE Val = 1023;
GO

-- ? داریم Bookmark Lookup آیا
SELECT
	CustomerID, Val
FROM dbo.Customers
	WHERE Val = 1023;
GO

SELECT *  FROM Customers
	WHERE Val < 100;
GO

SELECT *  FROM Customers
	WHERE Val < 1060;
GO

-- .منصرف می‌شود Lookup از انجام Tipping Point با استفاده از مفهوم
SELECT *  FROM Customers
	WHERE Val < 1200;
GO

SELECT *  FROM Customers WITH(INDEX(IX_Value))
	WHERE Val < 1200;
GO


/**
	07- Suitable IndexKey
*/
USE AdventureWorks;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.SalesOrderHeader2;
GO
-- تهیه کپی از جدول
SELECT * INTO dbo.SalesOrderHeader2 FROM Sales.SalesOrderHeader;
GO

-- ایجاد ایندکس کلاستر
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON dbo.SalesOrderHeader2(SalesOrderID);
GO

-- بررسی مقادیر کاندیداهای کلید ایندکس
SELECT COUNT(*) FROM dbo.SalesOrderHeader2;
GO

-- Wide
SELECT 
	OrderDate, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY OrderDate;

-- Not Wide
SELECT 
	OnlineOrderFlag, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;

-- Wide & Not Wide
SELECT
	RevisionNumber, COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY RevisionNumber;
GO

-- NonClustered ایجاد ایندکس های
CREATE INDEX IX_OrderDate ON dbo.SalesOrderHeader2(OrderDate);
CREATE INDEX IX_OnlineOrderFlag ON dbo.SalesOrderHeader2(OnlineOrderFlag);
CREATE INDEX IX_RevisionNumber ON dbo.SalesOrderHeader2(RevisionNumber);
GO

--بررسی وضعیت استفاده از ایندکس ها
SET STATISTICS IO ON;
GO

-- Wide
SELECT * FROM dbo.SalesOrderHeader2
	WHERE OrderDate = '2014-01-05';
GO

-- Not Wide
SELECT * FROM dbo.SalesOrderHeader2
	WHERE OnlineOrderFlag = 0;
SELECT * FROM dbo.SalesOrderHeader2
	WHERE OnlineOrderFlag = 1;
GO

-- Wide
SELECT * FROM dbo.SalesOrderHeader2
	WHERE RevisionNumber = 9;
-- Not Wide
SELECT * FROM dbo.SalesOrderHeader2
	WHERE RevisionNumber = 8;
GO

/**
	08- Composite Key
*/


USE Index_DB;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
CREATE TABLE dbo.ClusteredTable
(
	ID CHAR(700),
	FirstName NCHAR(400),
	LastName NCHAR(400),
	BirthDay  NCHAR(200)
);
GO

-- بر روی جدول Clustered ایجاد ایندکس
CREATE CLUSTERED INDEX IX_Clustered ON dbo.ClusteredTable(ID);
GO

-- بر روی جدول NonClustered ایجاد ایندکس
CREATE NONCLUSTERED INDEX IX_NonClustered ON dbo.ClusteredTable(BirthDay);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- بررسی تعداد صفحات تخصیص داده‌شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('Index_DB'),OBJECT_ID('ClusteredTable'),
		NULL,NULL,'DETAILED');
GO

--درج تعدادی رکورد تستی
INSERT INTO dbo.ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد','1359'),
			(5, N'پریسا', N'یزدانیان','1347'),
			(3, N'علی', N'تقوی','1371'),
			(4, N'مجید', N'پاکروان','1368'),
			(2, N'فرهاد', N'رضایی','1358'),
			(10, N'زهرا', N'غفاری','1362'),
			(8, N'مهدی', N'پوینده','1367'),
			(9, N'سمانه', N'اکبری','1370'),
			(7, N'بیژن', N'تولایی','1358'),
			(6, N'فاطمه', N'شریفی','1369');
GO

-- بررسی حجم جدول
SP_SPACEUSED ClusteredTable;
GO

/*
بررسی تعداد صفحات تخصیص داده شده به جدول و ایندکس
در یک فضای دیگر ایجاد شده است NonClustered ایندکس
*/
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('Index_DB'),OBJECT_ID('ClusteredTable')
		,NULL,NULL,'DETAILED');
GO

SELECT
	ID, FirstName, BirthDay
FROM dbo.ClusteredTable
	WHERE BirthDay = '1368';
GO

-- بر روی جدول Composite NonClustered ایجاد ایندکس جدید
CREATE NONCLUSTERED INDEX IX_NonClustered_Composite ON dbo.ClusteredTable(BirthDay,FirstName);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

SELECT
	ID, FirstName, BirthDay
FROM dbo.ClusteredTable
	WHERE BirthDay = '1368';
GO

SELECT
	ID, FirstName, BirthDay
FROM dbo.ClusteredTable WITH(INDEX(IX_NonClustered))
	WHERE BirthDay = '1368';
GO

DROP INDEX IF EXISTS dbo.ClusteredTable.IX_NonClustered_Composite;
GO

-- بر روی جدول Composite NonClustered ایجاد ایندکس جدید
CREATE NONCLUSTERED INDEX IX_NonClustered_Composite ON dbo.ClusteredTable(FirstName,BirthDay);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

SELECT
	ID, FirstName, BirthDay
FROM dbo.ClusteredTable
	WHERE BirthDay = '1368';
GO

SELECT
	ID, FirstName, BirthDay
FROM dbo.ClusteredTable WITH(INDEX(IX_NonClustered))
	WHERE BirthDay = '1368';
GO

/**
	09- Cover Index
*/

USE AdventureWorks;
GO

/*
Heap بر روی Cover Index ایجاد
*/

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.HeapTable;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO dbo.HeapTable FROM Sales.SalesOrderDetail;
GO

-- Composit ایجاد
CREATE NONCLUSTERED INDEX IX_NonClustered01 ON dbo.HeapTable(ProductID,OrderQty,SpecialOfferID);
GO

SET STATISTICS IO ON;
GO

-- Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO

-- CoverIndex ایجاد
CREATE NONCLUSTERED INDEX IX_NonClustered02 ON dbo.HeapTable(ProductID,OrderQty,SpecialOfferID)
INCLUDE(SalesOrderID,SalesOrderDetailID);
GO

-- Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable WITH(INDEX(IX_NonClustered01))
	WHERE ProductID = 789;
GO

SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO

-- .با توجه به کوئری می‌توانستیم ایندکس را به‌صورت زیر هم ایجاد کنیم
CREATE NONCLUSTERED INDEX IX_NonClustered03 ON dbo.HeapTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID);
GO

--Execution Plan مقایسه
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable WITH(INDEX(IX_NonClustered01))
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable WITH(INDEX(IX_NonClustered02))
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.HeapTable
	WHERE ProductID = 789;
GO
--------------------------------------------------------------------

/*
Clustered Table بر روی Cover Index ایجاد
*/

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO ClusteredTable FROM Sales.SalesOrderDetail;
GO

-- ایجاد ایندکس روی جدول
CREATE CLUSTERED INDEX IX_Clustered ON dbo.ClusteredTable(SalesOrderID);
CREATE NONCLUSTERED INDEX IX_NonClustered01 ON dbo.ClusteredTable(ProductID,OrderQty,SpecialOfferID);
GO

-- Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM dbo.ClusteredTable
	WHERE ProductID = 789;
GO

-- CoverIndex ایجاد
CREATE NONCLUSTERED INDEX IX_NonClustered02 ON dbo.ClusteredTable(ProductID,OrderQty,SpecialOfferID)
INCLUDE(SalesOrderDetailID);
GO

-- Execution Plan بررسی
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO

-- .با توجه به کوئری می‌توانستیم ایندکس را به‌صورت زیر هم ایجاد کنیم
CREATE NONCLUSTERED INDEX IX_NonClustered03 ON dbo.ClusteredTable (ProductID)
INCLUDE (SalesOrderID,SalesOrderDetailID,OrderQty,SpecialOfferID);
GO

-- Execution Plan بررسی
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable WITH(INDEX(IX_NonClustered01))
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable WITH(INDEX(IX_NonClustered02))
	WHERE ProductID = 789;
GO
SELECT
	SalesOrderID, SalesOrderDetailID,
	ProductID, OrderQty, SpecialOfferID
FROM ClusteredTable
	WHERE ProductID = 789;
GO


/**
	10- Filtered Index
*/

USE AdventureWorks;
GO

-- بررسی وجود جدول و حذف آن
DROP TABLE IF EXISTS dbo.SalesOrderHeader;
GO

-- Heap ایجاد یک جدول از نوع
SELECT * INTO SalesOrderHeader FROM Sales.SalesOrderHeader;
GO

--ایجاد یک کلاستر ایندکس بر روی جدول 
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON dbo.SalesOrderHeader(SalesOrderID);
GO

-- Filtered ایجاد ایندکس
CREATE INDEX IX_Filtered ON dbo.SalesOrderHeader(CustomerID,AccountNumber,OrderDate)
    WHERE OrderDate >= '2012-01-01'
	AND OrderDate <= '2012-12-31';
GO

-- NonClustered ایجاد ایندکس
CREATE INDEX IX_NonFiltered ON dbo.SalesOrderHeader(CustomerID,AccountNumber,OrderDate);
GO

-- بررسی تعداد صفحات تخصیص داده‌شده به جدول و ایندکس
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks'),OBJECT_ID('SalesOrderHeader'),
		NULL,NULL,'DETAILED');
GO

-- NonClustered مقايسه تعداد صفحات تخصیص‌یافته به‌ازای ایندکس‌های 
SELECT 
	index_id, index_type_desc, alloc_unit_type_desc,
	index_depth, index_level, page_count, record_count
FROM 
	sys.dm_db_index_physical_stats
		(DB_ID('AdventureWorks'),OBJECT_ID('SalesOrderHeader'),
		NULL,NULL,'DETAILED')
	WHERE index_type_desc <> 'CLUSTERED INDEX'
	AND index_level = 0;
GO

SET STATISTICS IO ON
GO

-- Execution Plan بررسی
-- '2012-01-01' ---> '2012-12-31'
SELECT
	CustomerID, AccountNumber, OrderDate
FROM dbo.SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO

SELECT
	CustomerID, AccountNumber, OrderDate
FROM dbo.SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2013-01-01';
GO

-- مقایسه دو کوئری مشابه با ایندکس‌های متفاوت
SELECT
	CustomerID, AccountNumber, OrderDate
FROM dbo.SalesOrderHeader  
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO
SELECT
	CustomerID, AccountNumber, OrderDate
FROM dbo.SalesOrderHeader WITH(INDEX(IX_NonFiltered))
	WHERE OrderDate BETWEEN '2012-01-01' AND '2012-03-01';
GO
--------------------------------------------------------------------
/*
تمرین کلاسی
:ساختار جدول به‌صورت زیر است

CREATE TABLE dbo.Person
(
	ID INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	NationalCode NVARCHAR(20)
);
GO

به‌صورت یکتا باشد اما قابلیت NationalCode می‌خواهیم مقادیر موجود در فیلد
.به‌ازای کاربرانی که فاقد این فیلد هستند وجود داشته باشد NULL یا Blank درج مقدار
?راه‌کار شما برای انجام این کار چیست

*/

USE NikamoozDB;
GO

DROP TABLE IF EXISTS dbo.Person;
GO

CREATE TABLE dbo.Person
(
	ID INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	NationalCode NVARCHAR(20)
);
GO

SP_HELPINDEX Person;
GO

INSERT INTO dbo.Person(FirstName, LastName, NationalCode)
	VALUES	(N'سعید', N'شجاعی', '111-111-111-111'),
		    (N'فريد', N'تقوی', NULL),
		    (N'سحر', N'زمانی', '222-222-222-222'),
		    (N'علي', N'پوینده', '333-333-333-333'),
		    (N'عليرضا', N'نصيري', NULL),
		    (N'فاطمه', N'اكبر مقدم', '444-444-444-444'),
		    (N'بهروز', N'پویان', ''),
		    (N'صادق', N'نوري', ''),
		    (N'مجید', N'سعادت', NULL);
GO

SELECT * FROM dbo.Person;
GO

-- .در صورتي‌كه بخواهیم كد ملي داراي مقدار يكتا باشد
--CREATE UNIQUE NONCLUSTERED INDEX IX1 ON dbo.Person(NationalCode);
--GO

CREATE UNIQUE NONCLUSTERED INDEX IX1 ON dbo.Person(NationalCode) 
	WHERE (NationalCode <> '' AND  NationalCode IS NOT NULL);
GO

SP_HELPINDEX Person;
GO

INSERT INTO dbo.Person(FirstName, LastName, NationalCode)
    VALUES	(N'امین', N'امینی', NULL);
GO

INSERT INTO dbo.Person(FirstName, LastName, NationalCode)
    VALUES (N'علي', N'سعادتی', '');
GO

INSERT INTO dbo.Person(FirstName, LastName, NationalCode)
    VALUES (N'محمد', N'کشاورز', '');
GO

INSERT INTO dbo.Person(FirstName, LastName, NationalCode)
    VALUES (N'فرناز', N'فلاحتی' , '222-222-222-222');
GO






