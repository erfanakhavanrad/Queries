use SampleDb
use NikamoozDB
/*
Session 16
*/

/* Collation */

INSERT INTO dbo.Collate_Tbl
	VALUES	(1,N'ج',N'ج'),
			(2,N'پ',N'پ'),
			(3,N'ژ',N'ژ'),
			(4,N'ح',N'ح'),
			(5,N'ي',N'ي'), -- عربی
			(6,N'ی',N'ی'), -- فارسی
			(7,N'ك',N'ك'), -- عربی
			(8,N'ک',N'ک'), -- فارسی
			(9,N'گ',N'گ'),
			(10,N'ب',N'ب'),			
			(11,N'چ',N'چ'),
			(12,N'ف',N'ف');
GO

SELECT * FROM dbo.Collate_Tbl;
GO
--------------------------------------------------------------------

-- در مرتب‌سازی Collation تاثیر
SELECT * FROM dbo.Collate_Tbl
ORDER BY Col1; -- Collation: SQL_Latin1_General_CP1256_CI_AS
GO

-- در مرتب‌سازی Collation تاثیر
SELECT * FROM dbo.Collate_Tbl
ORDER BY Col2; -- Collation:  -- Collation: Persian_100_CI_AI
GO
--------------------------------------------------------------------

-- در جستجو‌ Collation عدم تاثیر
SELECT * FROM dbo.Collate_Tbl
	WHERE Col1 = N'ی';
GO

SELECT * FROM dbo.Collate_Tbl
	WHERE Col1 = N'ي';
GO
--------------------------------------------------------------------

/*
مراحل تبدیل ي و ك عربی به فارسی

1) Persian فیلدها و تبدیل آن به Collation تغییر
2) جایگزینی ي و ك عربی با فارسی در جداول مختلف

NCHAR(1610)	ي عربی
NCHAR(1740)	ی فارسی
NCHAR(1603) ك عربی
NCHAR(1705) ک فارسی

*/

-- 1) Persian فیلدها و تبدیل آن به Collation تغییر
-- هاي دیتابیس و جداول‌ Collation يافتن تداخل میان 
DECLARE @DefaultDBCollation NVARCHAR(1000);  
SET @DefaultDBCollation = CAST(DATABASEPROPERTYEX(DB_NAME(), 'Collation') AS NVARCHAR(1000));
SELECT 
	sys.tables.name AS TableName,
	sys.columns.name AS ColumnName,
	sys.columns.is_nullable, sys.columns.collation_name,
	@DefaultDBCollation AS DefaultDBCollation
FROM sys.columns
INNER JOIN sys.tables
	ON sys.columns.object_id = sys.tables.object_id
	WHERE sys.columns.collation_name <> @DefaultDBCollation
	AND COLUMNPROPERTY(OBJECT_ID(sys.tables.name),  sys.columns.name, 'IsComputed') = 0;
GO

-- 2) جایگزینی ي و ك عربی با فارسی در جداول مختلف
DECLARE @Table NVARCHAR(MAX), @Col NVARCHAR(MAX);
DECLARE Table_Cursor CURSOR   
FOR  
    --پيدا كردن تمام فيلدهاي متني تمام جداول ديتابيس جاري  
    SELECT
		a.name,-- table  
        b.name-- col  
    FROM   sysobjects a,  
           syscolumns b 
    WHERE  a.id = b.id
           AND a.xtype = 'u'-- User table
           AND (  
                   b.xtype = 99 -- ntext
                   OR b.xtype = 35 -- text
                   OR b.xtype = 231 -- nvarchar
                   OR b.xtype = 167 -- varchar
                   OR b.xtype = 175 -- char
                   OR b.xtype = 239 -- nchar
               ) 
OPEN Table_Cursor FETCH NEXT FROM  Table_Cursor INTO @Table,@Col  
WHILE (@@FETCH_STATUS = 0)  
	BEGIN  
		EXEC (  
				'UPDATE [' + @Table + '] SET [' + @Col +  
				']= REPLACE(REPLACE(CAST([' + @Col +  
				'] AS NVARCHAR(MAX)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705))' 
				/*
				 !جایگذاری در خط بالا برای تبدیل ی و ک عربی به فارسی
				'] AS NVARCHAR(MAX)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705))'

				 !جایگذاری در خط بالا برای تبدیل ی و ک فارسی به عربی
				'] AS NVARCHAR(MAX)) , NCHAR(1740), NCHAR(1610)),NCHAR(1705),NCHAR(1603)) ' 
				*/
			)  
     
		FETCH NEXT FROM Table_Cursor INTO @Table,@Col  
	END CLOSE Table_Cursor DEALLOCATE Table_Cursor;
GO

SELECT * FROM dbo.Collate_Tbl;
GO

/* Computed Column */

SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS dbo.Compute_Tbl;
GO

CREATE TABLE dbo.Compute_Tbl
(
	ID INT IDENTITY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	FullName AS (FirstName + ' - ' + LastName), -- Computed Column
	FatherName NVARCHAR(50)
);
GO

INSERT INTO dbo.Compute_Tbl
	VALUES (N'حمید', N'سجادی', N'علی'),
			(N'ترانه', N'رضایی', N'رضا'),
			(N'پوریا', N'سرمدی', N'محمد'),	
			(N'رضا', N'محمدی', N'بهزاد'),
			(N'پروانه', N'صداقت', N'سعید');
GO 500

SELECT * FROM dbo.Compute_Tbl;
GO

DROP TABLE IF EXISTS dbo.Compute_Persisted_Tbl;
GO

CREATE TABLE dbo.Compute_Persisted_Tbl
(
	ID INT IDENTITY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	FullName AS (FirstName + ' - ' + LastName) PERSISTED, -- Computed Column
	FatherName NVARCHAR(50)
);
GO

INSERT INTO dbo.Compute_Persisted_Tbl
	VALUES	(N'حمید', N'سجادی', N'علی'),
			(N'ترانه', N'رضایی', N'رضا'),
			(N'پوریا', N'سرمدی', N'محمد'),	
			(N'رضا', N'محمدی', N'بهزاد'),
			(N'پروانه', N'صداقت', N'سعید');
GO 1000

SELECT * FROM dbo.Compute_Persisted_Tbl;
GO

-- بررسی فضای تخصیص یافته به جداول
SP_SPACEUSED Compute_Tbl;
GO
SP_SPACEUSED Compute_Persisted_Tbl;
GO
--------------------------------------------------------------------

/*
Computed Column بر روی UPDATE و INSERT عدم انجام عملیات‌های
*/
INSERT INTO dbo.Compute_Persisted_Tbl(FirstName,LastName,FullName,FatherName)
	VALUES	(N'مهدی', N'کبیری', N'مهدی - کبیری', N'علی');
GO

INSERT INTO dbo.Compute_Tbl(FirstName,LastName,FullName,FatherName)
	VALUES	(N'مهدی', N'کبیری', N'مهدی - کبیری', N'علی');
GO

UPDATE dbo.Compute_Tbl
	SET FullName = 'My Value';
GO

UPDATE dbo.Compute_Persisted_Tbl
	SET FullName = 'My Value';
GO
--------------------------------------------------------------------

-- .ایرادی ندارد
DELETE dbo.Compute_Persisted_Tbl
	WHERE FullName = N'حمید - سجادی';
GO

-- .ایرادی ندارد
DELETE dbo.Compute_Tbl
	WHERE FullName = N'حمید - سجادی';
GO

-- .ایرادی ندارد
UPDATE dbo.Compute_Tbl
	SET FirstName = N'امین'
	WHERE FirstName = N'حمید';
GO

-- .ایرادی ندارد
UPDATE dbo.Compute_Persisted_Tbl
	SET FirstName = N'امین'
	WHERE FirstName = N'حمید';
GO

SELECT * FROM dbo.Compute_Tbl;
GO

SELECT * FROM dbo.Compute_Persisted_Tbl;
GO

/* Sparse Columns */

DROP TABLE IF EXISTS Sparse_Tbl;
GO

CREATE TABLE dbo.Sparse_Tbl 
(
	C1 INT SPARSE,
	C2 INT SPARSE,
	C3 CHAR(100) SPARSE,
	C4 VARCHAR(100) SPARSE
)
GO
 
INSERT INTO dbo.Sparse_Tbl (C1,C2,C3,C4)
	VALUES	(NULL,NULL,NULL,NULL),
			(1,2,'A','A');
GO

SELECT * FROM dbo.Sparse_Tbl;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS Student_Info1,Student_Info2_Sparse;
GO

-- Sparse Columns ایجاد جدول فاقد 
CREATE TABLE Student_Info1
(
	ID INT IDENTITY,
	F_NAME NVARCHAR(50),
	L_NAME NVARCHAR(50),
	D1 CHAR(100),
	D2 CHAR(100),
	D3 CHAR(100),
	D4 CHAR(100),
	D5 CHAR(100),
	D6 CHAR(100),
	D7 CHAR(100),
	D8 CHAR(100),
	D9 CHAR(100),
	D10 CHAR(100)
)
GO

-- Sparse Columns ایجاد جدول دارای 
CREATE TABLE Student_Info2_Sparse
(
	ID INT IDENTITY,
	F_NAME NVARCHAR(50),
	L_NAME NVARCHAR(50),
	D1 CHAR(100) SPARSE,
	D2 CHAR(100) SPARSE,
	D3 CHAR(100) SPARSE,
	D4 CHAR(100) SPARSE,
	D5 CHAR(100) SPARSE,
	D6 CHAR(100) SPARSE,
	D7 CHAR(100) SPARSE,
	D8 CHAR(100) SPARSE,
	D9 CHAR(100) SPARSE,
	D10 CHAR(100) SPARSE
)
GO

-- Sparse Columns درج رکورد در جدول فاقد 
INSERT INTO Student_Info1 (F_NAME,L_NAME,D2,D3,D4)
	VALUES	('A','A','D12E5','21E1','Q10A'),
			('B','B','1T2U5','41O1','R1D0'),
			('C','C','1U2O5','7P11','W0F5');
GO 1000

-- Sparse Columns درج رکورد در جدول دارای 
INSERT INTO Student_Info2_Sparse (F_NAME,L_NAME,D2,D3,D4)
	VALUES	('A','A','D12E5','21E1','Q10A'),
			('B','B','1T2U5','41O1','R1D0'),
			('C','C','1U2O5','7P11','W0F5');
GO 1000


UPDATE Student_Info1 SET 
	D5='XXXX',D6='XXXX',D7='XXXX',
	D8='XXXX',D9='XXXX',D10='XXXX'
	WHERE ID % 45 = 1
GO

UPDATE Student_Info2_Sparse
	SET D5='XXXX', D6='XXXX', D7='XXXX',
		D8='XXXX', D9='XXXX', D10='XXXX'
	WHERE ID % 45 = 1;
GO

SELECT * FROM Student_Info1;
SELECT * FROM Student_Info2_Sparse;
GO

-- مشاهده حجم تخصیص داده شده به جداول
SP_SPACEUSED Student_Info1
GO
SP_SPACEUSED Student_Info2_Sparse
GO

-- برآورد میانگین اندازه هر رکورد
SELECT
	[avg_record_size_in_bytes]
FROM sys.dm_db_index_physical_stats (DB_ID('NikamoozDB'), OBJECT_ID ('Student_Info1'), NULL, NULL, 'DETAILED');
GO

SELECT
	[avg_record_size_in_bytes]
FROM sys.dm_db_index_physical_stats (DB_ID('NikamoozDB'), OBJECT_ID ('Student_Info2_Sparse'), NULL, NULL, 'DETAILED');
GO

/* Identity */

DROP TABLE IF EXISTS dbo.Ident_Tbl;
GO

CREATE TABLE dbo.Ident_Tbl
(
	ID INT IDENTITY,
	Family NVARCHAR(100)
);
GO

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'سعادت'),(N'علوی'),(N'مقدم'),(N'پویا');
GO

SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('dbo.Ident_Tbl') AS [IDENT_CURRENT];
GO

-- دیگر و اجرای کوئری زیر Session درج رکورد در
SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('dbo.Ident_Tbl') AS [IDENT_CURRENT];
GO

DROP TABLE IF EXISTS dbo.History_Ident_Tbl;
GO

CREATE TABLE dbo.History_Ident_Tbl
(
	Serial INT IDENTITY,
	ID INT,
	Family NVARCHAR(100),
	Act_Type VARCHAR(20),
	Act_Date DATE
);
GO

DROP TRIGGER IF EXISTS dbo.Trg_History_Ident_Tbl;
GO

CREATE TRIGGER dbo.Trg_History_Ident_Tbl ON dbo.Ident_Tbl
AFTER UPDATE
AS
	-- مقدار قبل از به‌روزرسانی
	INSERT INTO dbo.History_Ident_Tbl(ID,Family,Act_Type,Act_Date)
		SELECT
			ID, Family, 'Old_Value', GETDATE()
		FROM deleted
	-- مقدار پس از به‌روزرسانی
	INSERT INTO dbo.History_Ident_Tbl(ID,Family,Act_Type,Act_Date)
		SELECT
			ID, Family, 'New_Value', GETDATE()
		FROM inserted;
GO

SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('dbo.Ident_Tbl') AS [IDENT_CURRENT];
GO

UPDATE dbo.Ident_Tbl
	SET Family = N'سعادت'
	WHERE Family = N'سعادت نژاد';
GO

SELECT * FROM dbo.Ident_Tbl;
GO

SELECT
	@@IDENTITY AS [@@IDENTITY],
	SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
	IDENT_CURRENT('dbo.Ident_Tbl') AS [IDENT_CURRENT];
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Ident_Tbl;
GO

CREATE TABLE dbo.Ident_Tbl
(
	ID INT IDENTITY,
	Family NVARCHAR(100),
	Score TINYINT
);
GO

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'سعادت',100),(N'علوی',200),(N'مقدم',150),(N'پویا',80);
GO

SELECT * FROM dbo.Ident_Tbl;
GO

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'محمدی',45),(N'عباسوند',33),(N'کرامتی',88),(N'محسنیان',400);
GO

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'محمدی',45),(N'عباسوند',33),(N'کرامتی',88),(N'محسنیان',40);
GO

SELECT * FROM dbo.Ident_Tbl;
GO

/*
DBCC CHECKIDENT
 (
    table_name  
        [, { NORESEED | { RESEED [, new_reseed_value ] } } ]  
)
*/

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'نعمتی',450);
GO

DBCC CHECKIDENT ( 'dbo.Ident_Tbl', NORESEED );
GO


DBCC CHECKIDENT ( 'dbo.Ident_Tbl', RESEED, 12 );
GO

/*
DECLARE @Reseed_Val INT = IDENT_CURRENT('dbo.Ident_Tbl');
DBCC CHECKIDENT ( 'dbo.Ident_Tbl', RESEED, @Reseed_Val );
GO
*/

INSERT INTO dbo.Ident_Tbl
	VALUES	(N'نعمتی',100);
GO

SELECT * FROM dbo.Ident_Tbl;
GO



/* SEQUENCE */

/*

CREATE SEQUENCE [schema_name . ] Sequence_Name
    [ AS [ built_in_integer_type | user-defined_integer_type ] ] -- Sequence نوع داده مربوط به
    [ START WITH <constant> ] -- مقدار شروع
    [ INCREMENT BY <constant> ] -- گام افزایش
    [ { MINVALUE [ <constant> ] } | { NO MINVALUE } ] -- حداقل مقدار
    [ { MAXVALUE [ <constant> ] } | { NO MAXVALUE } ] -- حداکثر مقدار
    [ CYCLE | { NO CYCLE } ] -- دارای سیکل باشد و یا خیر
    [ { CACHE [ <constant> ] } | { NO CACHE } ] -- Cache تعداد آیتم‌های موجود در

*/

DROP SEQUENCE IF EXISTS dbo.SequenceTest1;
GO

-- SEQUENCE ایجاد 
CREATE SEQUENCE dbo.SequenceTest1 AS INT
	START WITH 10
	INCREMENT BY 1
	MINVALUE 10
	MAXVALUE 30
	CYCLE
	CACHE;
GO

-- SEQUENCE واکشی مقدار از
SELECT NEXT VALUE FOR dbo.SequenceTest1 AS Sequence_Val

-- SEQUENCE واکشی چندین مقدار دیگر از
SELECT NEXT VALUE FOR dbo.SequenceTest1 AS Sequence_Val
GO 10

--------------------------------------------------------------------

-- هنگام کار با جداول SEQUENCE نحوه استفاده از 
DROP TABLE IF EXISTS Test_Tbl1,Test_Tbl2;
GO

CREATE TABLE Test_Tbl1
(
	ID INT,
	Family VARCHAR(50)  COLLATE PERSIAN_100_CI_AI
);
Go

CREATE TABLE Test_Tbl2
(
	ID INT,
	Family VARCHAR(50) COLLATE PERSIAN_100_CI_AI
);
Go

-- SEQUENCE درج رکورد در جدول به همراه استفاده از 
INSERT Test_Tbl1
	VALUES	(NEXT VALUE FOR dbo.SequenceTest1, N'سعیدی'),
			(NEXT VALUE FOR dbo.SequenceTest1, N'پویا'),
			(NEXT VALUE FOR dbo.SequenceTest1, N'محمدی');
GO

INSERT Test_Tbl2
	VALUES	(NEXT VALUE FOR dbo.SequenceTest1, N'احمدی'),
			(NEXT VALUE FOR dbo.SequenceTest1, N'کریمی');
GO

SELECT * FROM Test_Tbl1;
SELECT * FROM Test_Tbl2;
GO
--------------------------------------------------------------------

-- SEQUENCE نمایش اطلاعاتی درباره 
SELECT * FROM SYS.sequences;
GO
--------------------------------------------------------------------

DROP SEQUENCE IF EXISTS dbo.SequenceTest2;
GO

CREATE SEQUENCE dbo.SequenceTest2
    AS DECIMAL(3,0)
    START WITH 125
    INCREMENT BY 25
    MINVALUE 100
    MAXVALUE 200
    CYCLE
    CACHE 3;
GO

-- SEQUENCE واکشی چند مقدار از
SELECT NEXT VALUE FOR dbo.SequenceTest2 AS Seq_Value;
GO

-- SequenceTest2 مشاهده اطلاعاتی درباره
SELECT 
	cache_size, current_value 
FROM sys.sequences
	WHERE name = 'SequenceTest2';
GO

-- SequenceTest2 ویرایش 
ALTER SEQUENCE dbo.SequenceTest2
    RESTART WITH 100  --به این قسمت توجه شود
    INCREMENT BY 10
    MINVALUE 100
    MAXVALUE 200
    NO CYCLE
    CACHE 3;
GO

-- SequenceTest2 واکشی چند مقدار از
SELECT NEXT VALUE FOR dbo.SequenceTest2 AS Seq_Value;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.ProcessEvents;
GO

DROP SEQUENCE IF EXISTS dbo.SequenceTest3;
GO

CREATE SEQUENCE dbo.SequenceTest3
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE dbo.ProcessEvents
(
    EventID INT PRIMARY KEY 
		DEFAULT (NEXT VALUE FOR dbo.SequenceTest3), -- به عنوان مقدار پیش فرض Sequence استفاده از
    EventTime DATETIME NOT NULL DEFAULT (GETDATE()),
    EventCode NVARCHAR(5) NOT NULL,
    Comments NVARCHAR(300) NULL
);
GO

INSERT INTO dbo.ProcessEvents (EventCode,Comments)
	VALUES (100,'EVent1'),
		   (200,'EVent2');
GO

SELECT * FROM dbo.ProcessEvents;
GO

INSERT INTO dbo.ProcessEvents (EventID,EventCode,Comments)
	VALUES (3,300,'No Sequence')
GO

SELECT * FROM ProcessEvents
GO

INSERT INTO dbo.ProcessEvents (EventCode,Comments)
	VALUES (400,'EVent3'),
		   (500,'EVent4');
GO

SELECT * FROM ProcessEvents
GO

-- اجرای مجدد
INSERT INTO dbo.ProcessEvents (EventCode,Comments)
	VALUES (400,'EVent3'),
		   (500,'EVent4');
GO

SELECT * FROM ProcessEvents
GO



/* STRING FUNCTIONS */


/*
ASCII ( character_expression )

به‌ازای اولین کاراکتر ASCII ارائه مقدار معادل

ASCII : American Standard Code for Information Interchange

https://ascii.cl/
*/

SELECT
	ASCII('A') AS A,
	ASCII('B') AS B,   
	ASCII('a') AS a,
	ASCII('b') AS b,  
	ASCII(1) AS [1],
	ASCII(2) AS [2];
GO 

SELECT ASCII('Ali') AS Ascii_Code;
GO

SELECT ASCII('ن') AS Ascii_Code;
GO

SELECT ASCII(N'ن') AS Ascii_Code;
GO
--------------------------------------------------------------------



/*
CHAR ( integer_expression )

به کاراکتر ASCII تبدیل کد
*/

SELECT
	CHAR(65) AS [65],
	CHAR(66) AS [66],   
	CHAR(97) AS [97],
	CHAR(98) AS [98],   
	CHAR(49) AS [49],
	CHAR(50) AS [50];
GO

SELECT CHAR(63);
GO
--------------------------------------------------------------------



/*
UNICODE ( 'ncharacter_expression' )

به‌ازای اولین کاراکتر Unicode ارائه مقدار معادل
*/

SELECT
	UNICODE(N'ي') AS [ي],
	UNICODE(N'ی') AS [ی],
	UNICODE(N'ك') AS [ك],
	UNICODE(N'ک') AS [ک];
GO

SELECT UNICODE('ي'); -- N'ي'
GO
--------------------------------------------------------------------


/*
NCHAR ( integer_expression )

به کاراکتر Unicode تبدیل کد
*/
SELECT
	NCHAR(1610) AS [1610],
	NCHAR(1740) AS [1740],
	NCHAR(1603) AS [1603],
	NCHAR(1705) AS [1705];
GO

SELECT NCHAR(77);
SELECT CHAR(77);
GO
--------------------------------------------------------------------



/*
REVERSE ( string_expression ) 

معکوس کردن کاراکترهای یک رشته
*/

SELECT
	FirstName, REVERSE(FirstName) AS Reverse_Val
FROM dbo.Employees;
GO

SELECT REVERSE(1234) AS Reversed ;  
GO




/* STRING_SPLIT ( string , separator ) */


DECLARE @tags NVARCHAR(400) = 'clothing,road,,touring,bike';
SELECT VALUE FROM STRING_SPLIT(@tags, ',');
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Test_Split;
GO

CREATE TABLE dbo.Test_Split
(
	ProductId INT IDENTITY,
	Title VARCHAR(100),
	Tags VARCHAR(1000)
);
GO

INSERT INTO dbo.Test_Split
	VALUES	('Full-Finger Gloves','clothing,road,touring,bike'),
			('LL Headset','bike,mountain'),
			('HL Mountain Frame','bike,mountain');
GO

SELECT ProductId, Title, VALUE  
FROM dbo.Test_Split  
CROSS APPLY STRING_SPLIT(Tags, ',');
GO

SELECT
	VALUE AS Tag,
	COUNT(*) AS [Number of Articles]  
FROM dbo.Test_Split
CROSS APPLY STRING_SPLIT(Tags, ',') 
GROUP BY VALUE  
	HAVING COUNT(*) > 1;
GO

SELECT ProductId, Title, Tags  
FROM dbo.Test_Split    
	WHERE 'mountain' IN (SELECT VALUE FROM STRING_SPLIT(Tags, ','));
GO



/*
STRING_AGG ( expression, separator [ <order_clause> ] )
<order_clause> ::=   
    WITHIN GROUP ( ORDER BY <order_by_expression_list> [ ASC | DESC ] ) 
*/

DROP TABLE IF EXISTS dbo.City,dbo.States;
GO

CREATE TABLE dbo.States
(
	StateID INT IDENTITY PRIMARY KEY,
	StateName NVARCHAR(50)
);
GO

INSERT INTO dbo.States
    VALUES (N'تهران'),(N'اصفهان'),(N'خراسان رضوی');
GO

CREATE TABLE dbo.City
(
	StateID INT FOREIGN KEY REFERENCES dbo.States(StateID),
	CityName NVARCHAR(100)
);
GO

INSERT INTO dbo.City 
    VALUES (1,N'تهران'),(1,N'پردیس'),(1,N'شهریار'),(1,N'ورامین'),
	       (2,N'اصفهان'),(2,N'کاشان'),
		   (3,N'مشهد'),(3,N'نیشابور'),(3,N'سبزوار');
GO

-- JOIN لیست شهرهای هر استان با روش
SELECT
	S.StateId,
	S.StateName,
	STRING_AGG (C.CityName, ',') AS City 
FROM dbo.States AS S       
INNER JOIN dbo.City AS C 
	ON S.StateId = C.StateId 
GROUP BY S.StateId, S.StateName;
GO

-- Subquery لیست شهرهای هر استان با روش
SELECT
	S.StateId,
	S.StateName,
	(SELECT STRING_AGG (C.CityName, ',') FROM dbo.City AS C
		WHERE S.StateId = C.StateId ) AS City 
FROM dbo.States AS S       
GROUP BY S.StateId, S.StateName;
GO

-- مرتب‌سازی بر اساس لیست شهرهای هر استان   
SELECT
	S.StateId,
	S.StateName,
	STRING_AGG (C.CityName, ',') WITHIN GROUP (ORDER BY C.CityName) AS City 
FROM dbo.States AS S       
INNER JOIN dbo.City AS C 
	ON S.StateId = C.StateId 
GROUP BY S.StateId, S.StateName;
GO



/*
CONCAT_WS ( separator, argument1, argument1 [, argumentN]… )
separator: any char,string, digit
min At least two argument ( null or string or digit ...)
*/

DECLARE @Str1 CHAR(1) = 'a', @Str2 CHAR(1) = 'b';
SELECT CONCAT_WS (',', @Str1, @Str2);
GO
--------------------------------------------------------------------

/*
NULL با مقادیر CONCAT_WS و CONCAT مقایسه رفتار توابع
*/
-- NULL نادیده گرفتن مقادیر
SELECT CONCAT_WS('**', 'String1', 2, NULL, NULL, 'String3', 'String4');
GO

-- NULL عدم نادیده گرفتن مقادیر
SELECT CONCAT('String1', '**', 2, '**', NULL, '**',
			   NULL, '**', 'String3', '**', 'String4', '**');
GO
--------------------------------------------------------------------

SELECT 
	CONCAT_WS( ' , ', database_id, recovery_model_desc,containment_desc) AS Result
FROM sys.databases;
GO

-- CONCAT_WS with STRING_AGG (CSV Format)
SELECT 
	STRING_AGG(CONCAT_WS( ',', database_id, recovery_model_desc, containment_desc), CHAR(13)) AS DatabaseInfo
FROM sys.databases;
GO


/*
TRIM ( [ characters FROM ] string )  
*/

SELECT TRIM('  test    ') AS Result;
SELECT LTRIM(RTRIM('  test    ')) AS Result;
GO
--------------------------------------------------------------------

-- حذف الگوی خاص از ابتدای رشته
SELECT	   TRIM( '#' FROM  '#test') AS Result;
SELECT LEN(TRIM( '#' FROM  '#test')) AS Result;
GO

SELECT	   TRIM( '# ' FROM  '  #test') AS Result;
SELECT LEN(TRIM( '# ' FROM  '  #test')) AS Result;
GO

SELECT	   TRIM( '# ' FROM  '#  test') AS Result;
SELECT LEN(TRIM( '# ' FROM  '#  test')) AS Result;
GO

--------------------------------------------------------------------

-- حذف الگوی خاص از انتهای رشته
SELECT	   TRIM( '.' FROM  'test.') AS Result;
SELECT LEN(TRIM( '.' FROM  'test.')) AS Result;
GO

SELECT	   TRIM( '. ' FROM  'test  .') AS Result;
SELECT LEN(TRIM( '. ' FROM  'test  .')) AS Result;
GO

SELECT	   TRIM( '. ' FROM  'test.  ') AS Result;
SELECT LEN(TRIM( '. ' FROM  'test.  ')) AS Result;
GO
--------------------------------------------------------------------

-- حذف الگو
SELECT	   TRIM( '.,# ' FROM  '  #test  .') AS Result;
SELECT LEN(TRIM( '.,# ' FROM  '  #test  .')) AS Result;
GO

SELECT	   TRIM( '!,. ' FROM  '!  test  .') AS Result;
SELECT LEN(TRIM( '!,. ' FROM  '!  test  .')) AS Result;
GO

SELECT TRIM( '!,.,a,# ' FROM  'atest  !#') AS Result;
SELECT LEN(TRIM( '!,.,a,# ' FROM  'atest  !#')) AS Result;
GO

SELECT TRIM( 'X ' FROM  'X  test  X') AS Result;
SELECT LEN(TRIM( 'X ' FROM  'X  test  X')) AS Result;
GO

DECLARE @Var VARCHAR(10) = 'xyz';
SELECT TRIM( SUBSTRING(@Var,1,2) FROM  'XytestXz') AS Result;
SELECT TRIM( SUBSTRING(@Var,1,2) FROM  'XytestXyz') AS Result;
GO

SELECT CHAR(88);
SELECT TRIM( CHAR(88) FROM  'XytestXy') AS Result;
GO
--------------------------------------------------------------------

-- مثال کاربردی
DROP TABLE IF EXISTS Digit_Trim;
GO

CREATE TABLE Digit_Trim
(
	Num VARCHAR(20)
);
GO

INSERT INTO Digit_Trim
    VALUES ('_one'),('_two'),('three_ok'),('four_ok');
GO

/*
:انتظار داریم پس از اجرای کوئری زیر، خروجی به این ‌صورت باشد

four-ok
one
three-ok
two
*/
SELECT Num FROM Digit_Trim 
ORDER BY Num;
GO

-- TRIM حل مشکل کوئری بالا با استفاده از تابع
SELECT
    TRIM( '_' FROM  Num) AS Result
FROM dbo.Digit_Trim 
ORDER BY Result;
GO


/*
TRANSLATE ( inputString, characters, translations)
*/

DECLARE @Str VARCHAR(MAX) = '2*[3+4]/{7-2}';
SELECT TRANSLATE(@Str, '[]{}', '()()');
GO

-- REPLACE نوشتن کوئری بالا با استفاده از تابع
DECLARE @Str VARCHAR(MAX) = '2*[3+4]/{7-2}';
SELECT REPLACE(REPLACE(REPLACE(REPLACE(@Str,'[','('), ']', ')'), '{', '('), '}', ')');
GO

DECLARE @Str VARCHAR(MAX)='2*[3+4]/{7-2}';
--SELECT TRANSLATE(@Str, '[]{', '()()'); -- عدم تطابق تعداد کاراکترها جهت جایگزینی
--SELECT TRANSLATE(@Str, '[]{}', '-'); -- عدم تطابق تعداد کاراکترها جهت جایگزینی
SELECT TRANSLATE(@Str, '[]{}', 'AAAA');
GO
