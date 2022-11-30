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
