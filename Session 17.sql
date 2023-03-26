use SampleDb
use NikamoozDB
/*
Session 17
*/

-- بررسی جهت وجود دیتابیس و حذف آن 
DROP DATABASE IF EXISTS TestDataFile;
GO

-- ایجاد دیتابیس
CREATE DATABASE TestDataFile;
GO 

USE TestDataFile;
GO

-- TestDataFile مشاهده مشخصات دیتابیس
SELECT * FROM sys.sysfiles;
GO

EXEC SP_HELPFILE;
GO

DROP TABLE IF EXISTS Students;
GO

-- Students ایجاد جدول
CREATE TABLE dbo.Students
(
	FirstName NVARCHAR(100), 
	LastName NVARCHAR(100), 
	Age INT
);
GO

-- Students درج رکورد در جدول
INSERT INTO dbo.Students 
	VALUES	(N'علی', N'سعیدی', 25),
			(N'سمیرا', N'شایان', 22);
GO

-- Students مشاهده رکوردهای جدول
SELECT * FROM dbo.Students;
GO

SELECT OBJECT_NAME(OBJECT_ID), * FROM sys.indexes 
	WHERE OBJECT_ID = OBJECT_ID('Students');
GO

/*
Data File مشاهده جزئیات هر 

PageFID : Data File ID
PagePID : Page ID
*/
-- Students های تخصیص داده‌شده به جدولpage مشاهده
-- DBCC: DataBase Consistency Checker
DBCC IND ('NikamoozDB', 'Students', 1);
GO

--DBCC IND معادل 
SELECT 
	* 
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB'), OBJECT_ID('Students'),
		NULL, NULL, 'DETAILED'
	);
GO

-- .ای قرار داردPageهر رکورد در چه 
SELECT 
	sys.fn_PhysLocFormatter (%%physloc%%) AS [Physical RID], * 
FROM Students;
GO

SELECT * FROM Students AS S 
	CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) AS FPLC
ORDER BY FPLC.file_id, FPLC.page_id, FPLC.slot_id;
GO

-- students مشاهده محتوای جدول
DBCC TRACEON (3604);
DBCC PAGE ('NikamoozDB', 1, 304, 3); -- !از کوئری بالا را جاگذاری کنید page_id به‌جای ؟؟؟ باید مقدار
GO
--------------------------------------------------------------------

/*
Show Page Information

DBCC IND ( { 'dbname' | dbid }, { 'objname' | objid }, { nonclustered indid | 1 | 0 | -1 | -2 });
nonclustered indid = non-clustered Index ID 
1 = Clustered Index ID 
0 = Displays information in-row data pages and in-row IAM pages (from Heap) 
-1 = Displays information for all pages of all indexes including LOB (Large object binary) pages and row-overflow pages 
-2 = Displays information for all IAM pages
/*
1= data page
2= index page
3 and 4 = text pages
8 = GAM page
9 = SGAM page
10 = IAM page
11 = PFS page


DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ]);Printopt:
0 - print just the page header
1 - page header plus per-row hex dumps and a dump of the page slot array 
2 - page header plus whole page hex dump
3 - page header plus detailed per-row interpretation
*/
*/

/*
مقایسه حالت های ذخیره سازی
Heap/Clustered/Columnstore
*/

USE master
GO

DROP DATABASE IF EXISTS DemoPageOrganization;
GO

-- .توجه کنید BACKUP در هنگام اجرای کوئری‌های زیر به مسیر فایل
RESTORE FILELISTONLY
FROM DISK ='F:\Programming\SQL\Mehdi Shishebori\T-Sql\Session 17\Scripts\Data File Details.bak';
GO

-- .توجه کنید BACKUP در هنگام اجرای کوئری‌های زیر به مسیر فایل
RESTORE DATABASE DemoPageOrganization
FROM DISK ='F:\Programming\SQL\Mehdi Shishebori\T-Sql\Session 17\Scripts\Data File Details.bak'
WITH 
	MOVE 'DemoPageOrganization' TO 'C:\Temp\DemoPageOrganization.mdf',
	MOVE 'DemoPageOrganization_log' TO 'C:\Temp\DemoPageOrganization_log.lmdf',
	STATS=1
GO
--------------------------------------------------------------------

USE DemoPageOrganization;
GO

-- بررسی حجم و تعداد رکوردهای هر کدام از جداول
SP_SPACEUSED ColumnstoreTable;
GO
SP_SPACEUSED ClusteredTable;
GO
SP_SPACEUSED HeapTable;
GO
--------------------------------------------------------------------

DBCC DROPCLEANBUFFERS;
CHECKPOINT;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ColumnstoreTable اجرای کوئری برای جدول 
SELECT
	OrderDateKey/100, ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM ColumnstoreTable
	WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100), ProductKey;
GO
PRINT '-------------------'
-- ClusteredTable اجرای کوئری برای جدول 
SELECT
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM ClusteredTable
	WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100), ProductKey;
GO
PRINT '-------------------'
-- HeapTable اجرای کوئری برای جدول 
SELECT
	OrderDateKey/100,ProductKey,
	COUNT(OrderQuantity) AS COUNT_OrderQuantity,
	SUM(SalesAmount) AS SUM_SalesAmount
FROM HeapTable
	WHERE OrderDateKey BETWEEN 20020701 AND 20030701
GROUP BY (OrderDateKey/100), ProductKey;
GO

--Heap ایجاد یک جدول از نوع
DROP TABLE IF EXISTS HeapTable
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE TABLE HeapTable
(
	ID INT,
	FirstName CHAR(3000),
	LastName CHAR(3000)
);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX HeapTable;
GO

-- Heap مشاهده جداول
SELECT OBJECT_NAME(OBJECT_ID), * FROM sys.indexes
	WHERE index_id = 0;
GO

-- Heap مشاهده جداول
SELECT OBJECT_NAME(sys.tables.object_id) FROM sys.indexes
JOIN sys.tables
	ON sys.indexes.object_ID = sys.tables.object_id
	WHERE sys.indexes.type = 0;
GO

/*
مشاهده تمامی جداول دیتابیس جاری
:در کوئری زیر توجه کنید index_id به مقدار فیلد
index_id = 0	(HEAP)
index_id = 1	(CLUSTERED)
index_id > 1	(NONCLUSTERED)
*/
SELECT OBJECT_NAME(OBJECT_ID),* FROM sys.indexes;
GO

-- بررسی صفحات جدول
DBCC IND('NikamoozDB','HeapTable',1) WITH NO_INFOMSGS;
GO

--درج تعدادی رکورد تستی
INSERT INTO HeapTable(ID,FirstName,LastName)
	VALUES	(1,N'سهیلا', N'تقوی'),
			(2,N'احمد', N'شریفی'),
			(3,N'رضا', N'کرمی'),
			(4,N'پریسا', N'سعادت'),
			(5,N'سهیل', N'عباس‌پور');
GO

--بررسی صفحات جدول
DBCC IND('NikamoozDB','HeapTable',1) WITH NO_INFOMSGS;
GO

/*
IAM کلیه آدرس صفحات در 
عدم وجود ارتباط مابین صفحات
*/
SELECT 
	*
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB'), OBJECT_ID('HeapTable'),
		NULL, NULL, 'DETAILED'
	)
	WHERE page_type_desc = 'DATA_PAGE';
GO

USE NikamoozDB;
GO

SET NOCOUNT ON;
GO

-- Heap ایجاد یک جدول از نوع 
DROP TABLE IF EXISTS dbo.SalesOrderDetail_Heap;
GO

CREATE TABLE dbo.SalesOrderDetail_Heap
(
	SalesOrderID INT NOT NULL,
	SalesOrderDetailID INT,
	CarrierTrackingNumber NVARCHAR(25) NULL,
	OrderQty SMALLINT NULL,
	ProductID INT NULL,
	SpecialOfferID INT NULL,
	UnitPrice MONEY  NULL,
	UnitPriceDiscount MONEY,
	LineTotal  MONEY,
	Rowguid UNIQUEIDENTIFIER,
	ModifiedDate DATETIME 
);
GO

-- Clustered ایجاد یک جدول از نوع 
DROP TABLE IF EXISTS dbo.SalesOrderDetail_Clustered;
GO

CREATE TABLE dbo.SalesOrderDetail_Clustered
(
	SalesOrderID INT NOT NULL,
	SalesOrderDetailID INT,
	CarrierTrackingNumber NVARCHAR(25) NULL,
	OrderQty SMALLINT NULL,
	ProductID INT NULL,
	SpecialOfferID INT NULL,
	UnitPrice MONEY  NULL,
	UnitPriceDiscount MONEY,
	LineTotal  MONEY,
	Rowguid UNIQUEIDENTIFIER,
	ModifiedDate DATETIME 
);
GO

-- ایجاد کلاستر ایندکس به ازای جدول
CREATE CLUSTERED INDEX IX_Clustered 
ON dbo.SalesOrderDetail_Clustered (SalesOrderID,SalesOrderDetailID);
GO
--------------------------------------------------------------------

SELECT
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
    OrderQty ,ProductID, SpecialOfferID, UnitPrice,
	UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
FROM AdventureWorks.Sales.SalesOrderDetail;
GO

-- Heap درج دیتا در جدول 
INSERT INTO dbo.SalesOrderDetail_Heap
(
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
	OrderQty, ProductID, SpecialOfferID, UnitPrice,
	UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
)
SELECT  
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber
    ,OrderQty ,ProductID, SpecialOfferID, UnitPrice,
	UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
FROM AdventureWorks.Sales.SalesOrderDetail;
GO 5

--Clustered درج دیتا در جدول 
INSERT INTO dbo.SalesOrderDetail_Clustered
(
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
	OrderQty, ProductID, SpecialOfferID, UnitPrice,
	UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
)
SELECT
	SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber
    ,OrderQty ,ProductID, SpecialOfferID, UnitPrice,
	UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
FROM AdventureWorks.Sales.SalesOrderDetail;
GO 5
--------------------------------------------------------------------

--مشاهده فضای تخصیص یافته به جداول
SP_SPACEUSED 'dbo.SalesOrderDetail_Heap';
GO
SP_SPACEUSED 'dbo.SalesOrderDetail_Clustered';
GO
--------------------------------------------------------------------

-- Heap های مربوط به جدولPage بررسی 
SELECT 
	COUNT(*)
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB'), OBJECT_ID('SalesOrderDetail_Heap'),
		NULL, NULL, 'DETAILED'
	)
	WHERE page_type_desc = 'DATA_PAGE';
GO

-- Clustered های مربوط به جدولPage بررسی 
SELECT 
	COUNT(*)
FROM sys.dm_db_database_page_allocations
	(
		DB_ID('NikamoozDB'), OBJECT_ID('SalesOrderDetail_Clustered'),
		NULL, NULL, 'DETAILED'
	)
	WHERE page_type_desc = 'DATA_PAGE';
GO

DBCC DROPCLEANBUFFERS;
CHECKPOINT;
GO

-- STATISTICS TIME و STATISTICS IO بررسی
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/*
:قبل از اجرای کوئری‌ها و برای مشاهده بهتر و دقیق‌تر زمان اجرای آ‌ن‌ها بهتر است تنظیمات زیر را انجام دهم

Query\Query Options\Results\Discard result after execution
*/

-- Clustered و Heap واکشی تعداد بسیار کمی از رکوردهای جدول
SELECT * FROM SalesOrderDetail_Heap
	WHERE SalesOrderID = 72855;
SELECT * FROM SalesOrderDetail_Clustered
	WHERE SalesOrderID = 72855;
GO

-- Clustered و Heap واکشی بخش عمده‌ای از رکوردهای جدول
SELECT * FROM SalesOrderDetail_Heap
	WHERE SalesOrderID < 75100;
SELECT * FROM SalesOrderDetail_Clustered
	WHERE SalesOrderID < 75100;
GO
--------------------------------------------------------------------

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- Clustered و Heap مربوط به Executio Plan مقایسه
SELECT * FROM SalesOrderDetail_Heap
	WHERE SalesOrderID = 72855;
SELECT * FROM SalesOrderDetail_Clustered
	WHERE SalesOrderID = 72855;
GO

-- Clustered و Heap مربوط به Executio Plan مقایسه
SELECT * FROM SalesOrderDetail_Heap
	WHERE SalesOrderID < 75100;
SELECT * FROM SalesOrderDetail_Clustered
	WHERE SalesOrderID < 75100;
GO

USE AdventureWorks;
GO

DROP TABLE IF EXISTS SalesOrderDetail2;
GO

-- Sales.SalesOrderDetail ساخت یک نمونه کپی از جدول
SELECT * INTO SalesOrderDetail2 FROM Sales.SalesOrderDetail;
GO


SP_HELPINDEX SalesOrderDetail2;
GO

SP_SPACEUSED SalesOrderDetail2;
GO
--------------------------------------------------------------------

/*
Seek و Scan بررسی مفهوم
*/

-- Scan بررسی عملیات 
SELECT * FROM SalesOrderDetail2
	WHERE SalesOrderID = 75000;
GO

SP_HELPINDEX 'Sales.SalesOrderDetail';
GO

-- Seek بررسی عملیات 
SELECT * FROM Sales.SalesOrderDetail
	WHERE SalesOrderID = 75000;
GO

-- Clustered Index Scan بررسی عملیات 
SELECT * FROM Sales.SalesOrderDetail
	WHERE OrderQty = 1;
GO
--------------------------------------------------------------------

/*
و زمان اجرای کوئری‌ها IO بررسی اطلاعات مربوط به
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/*
معادل دستورات بالا
SET STATISTICS IO,TIME ON;
GO
*/

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

-- Scan بررسی عملیات
SELECT * FROM SalesOrderDetail2
	WHERE SalesOrderID = 75000;
GO

-- Seek بررسی عملیات 
SELECT * FROM Sales.SalesOrderDetail
	WHERE SalesOrderID = 75000;
GO

/*
IO و Time استفاده از لینک زیر برای مشاهده اطلاعات
http://statisticsparser.com/index.html
*/

DROP DATABASE IF EXISTS Index_DB;
GO

CREATE DATABASE Index_DB;
GO

USE Index_DB;
GO

DROP TABLE IF EXISTS ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID INT,
	FirstName NCHAR(2000),
	LastName NCHAR(2000)
);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- درج تعدادی رکورد تستی
INSERT INTO ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

-- .فاقد هرگونه نظم و ترتیبی هستند ClusteredTable رکوردهای موجود در جدول 
SELECT * FROM ClusteredTable;
GO

SP_SPACEUSED ClusteredTable;
GO

-- ClusteredTable بر روی جدول CLUSTERED ساخت ایندکس
CREATE CLUSTERED INDEX Clustered_IX ON ClusteredTable(ID);
GO

SELECT * FROM ClusteredTable;
GO

-- Heap افزایش فضای تخصیص یافته به جدول نسبت به حالت
SP_SPACEUSED ClusteredTable;
GO
--------------------------------------------------------------------

/*
بررسی صفحات تخصیص داده شده به ایندکس
ها Index Page بررسی 
*/

-- صحفات وابسته به جدول
SELECT 
	page_type_desc, allocated_page_page_id,
	next_page_page_id, previous_page_page_id
FROM sys.dm_db_database_page_allocations -- SQL Server 2012
	(
		DB_ID('Index_DB'),OBJECT_ID('ClusteredTable'),
		NULL, NULL,'DETAILED'
	);
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS ClusteredTable;
GO

-- Heap ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID CHAR(900),
	FirstName NCHAR(1500),
	LastName NCHAR(1500)
);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- درج تعدادی رکورد تستی
INSERT INTO ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

-- ClusteredTable مشاهده رکوردهای موجود در جدول 
SELECT * FROM ClusteredTable;
GO

CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(ID);
GO

/*
DMF آنالیز ایندکس با استفاده از 
مشاهده وضعیت فیزیکی ایندکس 

sys.dm_db_index_physical_stats
 (
	  { database_id| NULL | 0 | DEFAULT }
	, { object_id| NULL | 0 | DEFAULT }
	, { index_id| NULL | 0 | -1 | DEFAULT }
	, { partition_number| NULL | 0 | DEFAULT }
	, { mode| NULL | DEFAULT } = (DEFAULT,LIMITED,SAMPLED,DETAILED ** DEFAULT=LIMITED)
)

1: LIMITED : Leaf Level

2: SAMPLED :Leaf Level & نمونه برداری از تعدادی از صفحات
--با توجه به اینکه نمونه برداری انجام می شود احتمال تقریبی بودن نتایج وجود دارد
If the number of leaf level pages is < 10000, read all the pages,
 otherwise read every 100th pages (i.e. a 1% sample)

3: DETAILED: نمایش تمامی سطوح برگ و غیر برگ
*/

-- !شماتیک ساختار درخت ایندکس بررسی شود
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- Leaf Level اطلاعات مربوط به
SELECT 
	index_type_desc, index_depth,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('ClusteredTable'),
	1,
	NULL,
	'LIMITED'
);
GO
--------------------------------------------------------------------

USE AdventureWorks;
GO

SP_HELPINDEX 'Sales.SalesOrderDetail';
GO

-- مشاهده تمام ایندکس‌های یک جدول
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('Sales.SalesOrderDetail'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- Sales.SalesOrderDetail مشاهده یک ایندکس خاص از جدول
SELECT 
	*
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('Sales.SalesOrderDetail'),
	2,
	NULL,
	'DETAILED'
);
GO

-- Sales.SalesOrderDetail مشاهده یک ایندکس خاص از جدول
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('Sales.SalesOrderDetail'),
	1,
	NULL,
	'DETAILED'
);
GO

/*
CLUSTERED INDEX
*/

USE Index_DB;
GO

DROP TABLE IF EXISTS ClusteredTable
GO

-- Heap ایجاد یک جدول از نوع
CREATE TABLE ClusteredTable
(
	ID INT,
	FirstName NCHAR(2000),
	LastName NCHAR(2000)
);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX ClusteredTable;
GO

-- درج تعدادی رکورد تستی
INSERT INTO ClusteredTable
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(1, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(1, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

/*
نکته مهم
ایجاد کنیم CLUSTERED INDEX اگر بر روی جدولی ایندکسی از نوع
آن‌گاه مقادیر کلید ایندکس می‌تواند تکراری باشد
.ولی به‌ازای هر مقدار تکراری به‌میزان 4 بایت فضای اضافی تخصیص داده می‌شود
*/
CREATE CLUSTERED INDEX IX_Clustered ON ClusteredTable(ID);
GO

SELECT * FROM ClusteredTable;
GO

INSERT INTO ClusteredTable
VALUES
	(1, N'مهدی', N'تقوی‌');
GO

SELECT * FROM ClusteredTable;
GO
--------------------------------------------------------------------
--------------------------------------------------------------------

/*
Primary Key
*/

--بررسی وجود جدول
DROP TABLE IF EXISTS Students;
GO

-- Heap ایجاد یک جدول از نوع
CREATE TABLE Students
(
	ID INT NOT NULL,
	FirstName NCHAR(2000),
	LastName NCHAR(2000)
);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX Students;
GO

--درج تعدادی رکورد تستی
INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

-- .فاقد نظم و ترتیب هستند Students رکوردهای موجود در جدول
SELECT * FROM Students;
GO

SP_SPACEUSED Students;
GO

-- PK آنالیز ایندکس قبل از اعمال 
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('Students'),
	NULL,
	NULL,
	'DETAILED'
);
GO

SP_HELPCONSTRAINT 'Students';
GO

-- Students بر روی جدول Priamry Key ایجاد
ALTER TABLE Students ADD CONSTRAINT PK_Students PRIMARY KEY (ID);
GO

-- Students بررسی وضعیت مرتب سازی رکوردهای جدول
SELECT * FROM Students;
GO

-- Heap افزایش فضای تخصیص یافته به جدول نسبت به حالت
SP_SPACEUSED Students;
GO

-- PK آنالیز ایندکس پس از اعمال 
SELECT 
	index_id, index_type_desc,
	index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('Students'),
	NULL,
	NULL,
	'DETAILED'
);
GO

-- عدم درج مقدار تکراری به‌ازای فیلد کلید
INSERT INTO Students
VALUES
	(3, N'فریبا', N'زمانی');
GO
--------------------------------------------------------------------

/*
در هنگام ساخت یک جدول Primary Key بررسی انواع حالت های مربوط به ایجاد

باشند!!! : نکته مهم Not Null باید Primary Key فیلد یا فیلدهای کاندید برای
*/

DROP TABLE IF EXISTS Persons;
GO
-- Primary Key ساخت جدول به‌همراه 
CREATE TABLE Persons 
(
    ID INT NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255),
    Age INT,
    PRIMARY KEY (ID)
);
GO

DROP TABLE IF EXISTS Persons;
GO
-- Primary Key ساخت جدول به‌همراه 
CREATE TABLE Persons 
(
    ID INT NOT NULL PRIMARY KEY,
    LastName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255),
    Age INT
);
GO

DROP TABLE IF EXISTS Persons;
GO
-- Primary Key ساخت جدول به‌همراه 
CREATE TABLE Persons 
(
    ID INT NOT NULL CONSTRAINT PK_ID PRIMARY KEY,
    LastName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255),
    Age INT
);
GO
--------------------------------------------------------------------

-- ترکیبی Primary Key ساخت جدول به همراه
DROP TABLE IF EXISTS Students;
GO
CREATE TABLE Students 
(
    ID INT NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255),
    CONSTRAINT PK_Students PRIMARY KEY (ID,LastName)
);
GO

INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

-- .خواهد بود PRIMARY KEY (ID,LastName) چینش فیزیکی بر اساس
SELECT * FROM Students;
GO

DROP TABLE IF EXISTS Students;
GO
CREATE TABLE Students 
(
    ID INT NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255),
    CONSTRAINT PK_Students PRIMARY KEY (LastName,ID)
);
GO

INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

-- .خواهد بود PRIMARY KEY (LastName,ID) چینش فیزیکی بر اساس
SELECT * FROM Students;
GO
--------------------------------------------------------------------

-- .به جدول هایی که از قبل ایجاد شده‌اند Primary Key اضافه کردن 
DROP TABLE IF EXISTS Persons;
GO

CREATE TABLE Persons 
(
    ID INT NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255),
    Age INT
);
GO

ALTER TABLE Persons ADD CONSTRAINT PK_Person PRIMARY KEY (ID,LastName);
GO
-- .این دستور معادل دستور بالا است
ALTER TABLE Persons ADD PRIMARY KEY (ID,LastName);
GO

-- از جدول Primary Key حذف
ALTER TABLE Persons DROP CONSTRAINT PK_Person;
GO
--------------------------------------------------------------------

/*
?ایجاد کرد Primary Key در چه صورت می‌توان برای جدولی که حاوی رکورد است
*/
DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
(
	ID INT NOT NULL ,
	FirstName CHAR(2000),
	LastName CHAR(2000)
);
INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(1, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

ALTER TABLE Students ADD CONSTRAINT PK_Students PRIMARY KEY (ID);
GO

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
(
	ID INT NOT NULL ,
	FirstName CHAR(2000),
	LastName CHAR(2000)
);
INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(2, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(7, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

ALTER TABLE Students ADD CONSTRAINT PK_Students PRIMARY KEY (ID);
GO
--------------------------------------------------------------------
--------------------------------------------------------------------

/*
UNIQUE CLUSTERED INDEX
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
(
	ID INT,
	FirstName NCHAR(2000),
	LastName NCHAR(2000)
);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX Students;
GO

-- درج تعدادی رکورد تستی
INSERT INTO Students
	VALUES	(1, N'حمید', N'سعادت‌نژاد'),
			(5, N'پریسا', N'یزدانیان'),
			(3, N'علی', N'تقوی'),
			(4, N'مجید', N'پاکروان'),
			(7, N'فرهاد', N'رضایی'),
			(10, N'زهرا', N'غفاری'),
			(8, N'مهدی', N'پوینده'),
			(9, N'سمانه', N'اکبری'),
			(2, N'بیژن', N'تولایی'),
			(6, N'فاطمه', N'شریفی');
GO

SELECT * FROM Students;
GO

CREATE UNIQUE CLUSTERED INDEX IX_U_Clustered ON Students(ID);
GO

-- بررسی ایندکس های جدول
SP_HELPINDEX Students;
GO

SELECT * FROM Students;
GO

SELECT
	O.name, I.type_desc, O.type_desc, O.create_date
FROM sys.indexes AS I
INNER JOIN sys.objects AS O
	ON  I.object_id = O.object_id
	WHERE O.type_desc = 'USER_TABLE';
GO

INSERT INTO Students
	VALUES	(NULL, N'سعید', N'صفایی‌');
GO

SELECT * FROM Students;
GO

INSERT INTO Students
	VALUES	(NULL, N'ندا', N'کریمی‌');
GO
--------------------------------------------------------------------
--------------------------------------------------------------------

/*
Unique Key

! مدیریت می‌شود NonClustered Index توسط Unique Key
*/

DROP TABLE IF EXISTS Students;
GO

CREATE TABLE Students
(
	ID INT UNIQUE,
	FirstName CHAR(2000),
	LastName CHAR(2000)
);
GO

--بررسی ایندکس های جدول
SP_HELPINDEX Students;
GO

SELECT
	O.name, I.type_desc, O.type_desc, O.create_date
FROM sys.indexes AS I
INNER JOIN sys.objects AS O
	ON  I.object_id = O.object_id
	WHERE O.type_desc = 'USER_TABLE';
GO

USE Index_DB;
GO

DROP TABLE IF EXISTS Employees;
GO

CREATE TABLE Employees
(
	ID CHAR(600) ,
	FirstName NCHAR(1800),
	LastName NCHAR(1800)
);
GO

-- Employees بر روی جدول UNIQUE CLUSTERED INDEX ایجاد
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON Employees(ID);
GO

-- درج تعدادی رکورد تستی
INSERT INTO Employees
VALUES
	(1, N'حمید', N'سعادت‌نژاد'),
	(5, N'پریسا', N'یزدانیان'),
	(3, N'علی', N'تقوی'),
	(4, N'مجید', N'پاکروان'),
	(2, N'فرهاد', N'رضایی'),
	(10, N'زهرا', N'غفاری'),
	(8, N'مهدی', N'پوینده'),
	(9, N'سمانه', N'اکبری'),
	(7, N'بیژن', N'تولایی'),
	(6, N'فاطمه', N'شریفی');
GO

-- مشاهده رکوردهای موجود در جدول
SELECT * FROM Employees;
GO

-- آنالیز ایندکس
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('Index_DB'),
	OBJECT_ID('Employees'),
	1,
	NULL,
	'DETAILED'
);
GO

-- IO , Execution Plan بررسی 
SET STATISTICS IO ON;
GO

SELECT * FROM Employees
	WHERE ID = '5';
GO

SELECT * FROM Employees
	WHERE ID = 5;
GO
--------------------------------------------------------------------

-- بررسی مثالی دیگر 
USE AdventureWorks;
GO

DROP TABLE IF EXISTS SalesOrderHeader2;
GO

SELECT * INTO SalesOrderHeader2 FROM Sales.SalesOrderHeader;
GO

-- SalesOrderHeader2 بر روی جدول UNIQUE CLUSTERED INDEX ایجاد
CREATE UNIQUE CLUSTERED INDEX IX_Clustered ON SalesOrderHeader2(SalesOrderID);
GO

-- بررسی حجم
SP_SPACEUSED SalesOrderHeader2;
GO

-- آنالیز ایندکس
SELECT 
	index_type_desc, index_depth, index_level,
	page_count, record_count
FROM sys.dm_db_index_physical_stats
(
	DB_ID('AdventureWorks'),
	OBJECT_ID('SalesOrderHeader2'),
	1,
	NULL,
	'DETAILED'
);
GO

-- IO , Execution Plan بررسی 
SET STATISTICS IO ON;
GO

-- Singleton Lookup
SELECT * FROM SalesOrderHeader2
	WHERE SalesOrderID = 52000;
GO

-- Index Seek
SELECT * FROM SalesOrderHeader2
	WHERE SalesOrderID BETWEEN 52000 AND  52002;
GO

SELECT * FROM SalesOrderHeader2
	WHERE SalesOrderID = 52000 OR SalesOrderID = 52001 OR  SalesOrderID = 52002;
GO

SELECT * FROM SalesOrderHeader2
	WHERE SalesOrderID IN(52000,52001,52002);
GO

-- Clustered Index Scan
SELECT * FROM SalesOrderHeader2	
	WHERE SalesPersonID = 282;
GO