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
USE AdventureWorks2017;
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

USE AdventureWorks2017
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
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader_Heap'),
		NULL,NULL,'DETAILED'
	)
GROUP BY page_type_desc;
GO

-- های جدولPage مشاهده تعداد 
SELECT 
	COUNT(*),page_type_desc AS Page_Count
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('AdventureWorks2017'),OBJECT_ID('SalesOrderHeader_Clustered'),
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
	DB_ID('AdventureWorks2017'),
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
	DB_ID('AdventureWorks2017'),
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

USE AdventureWorks2017;
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
		(DB_ID('AdventureWorks2017'),OBJECT_ID('HeapTable'),NULL,NULL,'DETAILED');
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
		(DB_ID('AdventureWorks2017'),OBJECT_ID('ClusteredTable'),NULL,NULL,'DETAILED');
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













