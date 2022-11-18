use SampleDb
use NikamoozDB
/*
Session 15
*/

-- Plan Cache
-- Plan Cache مربوط به Cache پاک کردن
DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.Employees
	WHERE EmployeeID = 1;
GO

SELECT * FROM dbo.Employees
	WHERE EmployeeID = 2;
GO

-- شده است Cache آن‌ها Plan لیست کوئری‌هایی که
SELECT * FROM sys.dm_exec_cached_plans;
GO

-- به همراه متن کوئری Plan Cache مشاهده کوئری‌های موجود در
SELECT
	P.bucketid,P.usecounts,P.size_in_bytes,P.objtype,T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T;
GO
--------------------------------------------------------------------

/*
SP چندین مرتبه فراخوانی
*/

-- Plan Cache مربوط به Cache پاک کردن
DBCC FREEPROCCACHE;
GO

EXEC GetEmployeeByID 1;
GO

EXEC GetEmployeeByID 4;
GO

EXEC GetEmployeeByID 9;
GO

--  به‌همراه متن کوئری Plan Cache مشاهده کوئری‌های موجود در
SELECT
	P.bucketid,P.usecounts,P.size_in_bytes,T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T
	WHERE T.text LIKE '%Employees%';
GO
--------------------------------------------------------------------

/*
sp_executesql اجرای کوئری با استفاده از
*/

DBCC FREEPROCCACHE;
GO


EXEC sp_executesql N'SELECT * FROM dbo.Orders WHERE CustomerID = @Customerid',
	N'@Customerid INT', @Customerid=79;
GO

EXEC sp_executesql N'SELECT * FROM dbo.Orders WHERE CustomerID = @Customerid',
	N'@Customerid INT', @Customerid=3;
GO

EXEC sp_executesql N'SELECT * FROM dbo.Orders WHERE CustomerID = @Customerid',
	N'@Customerid INT', @Customerid=28;
GO

SELECT
	P.bucketid,P.usecounts,P.size_in_bytes,T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T
	WHERE T.text LIKE '%Orders%';
GO
--------------------------------------------------------------------

/*
کوئری Ad-hoc اجرای چندین
*/

-- Plan Cache مربوط به Cache پاک کردن
DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.Employees
	WHERE EmployeeID = 1;
GO

SELECT * FROM dbo.Employees
	WHERE EmployeeID= 1;
GO

SELECT * FROM dbo.Employees
	WHERE EmployeeID= 1; -- کد کارمند
GO

-- اجرایی Plan به همراه متن کوئری و Plan Cache مشاهده کوئری‌های موجود در
SELECT
	P.bucketid,P.usecounts,P.size_in_bytes,T.text
FROM sys.dm_exec_cached_plans AS P
CROSS APPLY sys.dm_exec_sql_text(P.plan_handle) AS T;
GO

/*
OUTPUT مروری بر
*/

DROP TABLE IF EXISTS dbo.Persons;
GO

CREATE TABLE dbo.Persons
(
	Code INT,
	FirstName NVARCHAR (50),
	LastName NVARCHAR (50)
)

-- INSERT
INSERT INTO dbo.Persons (Code, FirstName)
	OUTPUT inserted.*
VALUES (1, N'Tom');
GO


INSERT INTO dbo.Persons (Code, FirstName, LastName)
	OUTPUT inserted.*
VALUES (300, N'Hopem', N'Green');
GO

-- UPDATE
UPDATE dbo.Persons
	SET LastName = N'Iconic'
	OUTPUT
		deleted.Code AS [Old_Code],
		deleted.FirstName AS [Old_FirstName],
		deleted.LastName AS [Old_LastName],
		inserted.Code AS [New_Code],
		inserted.FirstName AS [New_FirstName],
		inserted.LastName AS [New_LastName]
	WHERE Code = 1;
GO

-- DELETE
DELETE FROM dbo.Persons
	OUTPUT deleted.*
WHERE code = 1;
GO

-- نمایش رکوردهای جدول
SELECT * FROM dbo.Persons;
GO


--------------------------------------------------------------------

/*
CREATE TRIGGER [ schema_name . ]trigger_name   
ON { table | view }   
{ AFTER | INSTEAD OF }   
{ [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }   
AS { sql_statement  [ ; ] [ ,...n ] }  
*/

DROP TABLE IF EXISTS dbo.Persons;
GO

CREATE TABLE dbo.Persons
(
		Code INT,
	FirstName NVARCHAR (50),
	LastName NVARCHAR (50)
)

DROP TRIGGER IF EXISTS InsertTrg_Persons;
GO

/*
dbo.Persons بر روی جدول AFTER ایجاد یک تریگر از نوع
*/
CREATE TRIGGER InsertTrg_Persons ON dbo.Persons
AFTER INSERT
AS
	SELECT * FROM dbo.Persons
GO

-- مشاهده اطلاعاتی درباره تریگرها
SP_HELPTRIGGER 'dbo.Persons';
SELECT * FROM SYS.triggers;
GO

-- تریگر Source مشاهده
SP_HELPTEXT 'InsertTrg_Persons';
GO

INSERT INTO dbo.Persons
	VALUES (1,N'مهدی',N'احمدی'),
		   (2,N'امید',N'سعادتی');
GO

SELECT * FROM dbo.Persons;
GO

-- تغییر تریگر
ALTER TRIGGER InsertTrg_Persons ON dbo.Persons
AFTER INSERT, UPDATE, DELETE
AS
	ROLLBACK TRANSACTION
GO

INSERT INTO dbo.Persons
	VALUES (1, N'Partoye',N'Saeid')


DELETE FROM dbo.Persons;
GO

UPDATE dbo.Persons
	SET Code = 100
		WHERE Code = 1;
GO

SELECT * FROM dbo.Persons;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
.ایجاد کنید Customers ابتدا یک نمونه کپی از جدول

تریگری ایجاد کنید dbo.Customers2 اکنون بر روی جدول
.که از حذف مشتریانی که بیش از 10 سفارش داشته‌اند جلوگیری کند
*/

DROP TABLE IF EXISTS dbo.Customers2;
GO

SELECT * INTO dbo.customers2 FROM dbo.Customers;
GO

SELECT *FROM dbo.customers2;


CREATE TRIGGER dbo.Customers_Trg ON dbo.Customers2
AFTER DELETE
AS
    DECLARE @C_ID INT
    SELECT @C_ID = CustomerID FROM deleted -- تشخیص مشتری
    IF (SELECT COUNT(OrderID) FROM dbo.Orders WHERE CustomerID = @C_ID) > 10
	   BEGIN
		  PRINT N'!امکان حذف این مشتری وجود ندارد'
		  ROLLBACK TRAN --لغو عمليات
	    END
GO

SELECT
    CustomerID, COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CustomerID;
GO

DELETE dbo.Customers2
    WHERE  CustomerID = 4;
GO

DELETE dbo.Customers2
    WHERE  CustomerID = 1;
GO

SELECT * FROM dbo.Customers2
ORDER BY CustomerID;
GO
--------------------------------------------------------------------

/*
.یکی از کاربردهای تریگر ذخیره سوابق تغییرات رکوردها است
*/

DROP TABLE IF EXISTS dbo.Persons, dbo.History_Persons;
GO

CREATE TABLE dbo.Persons
(
	Code INT,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50)
)
GO

CREATE TABLE dbo.History_Persons
(
	Code INT,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Action_Type VARCHAR(10),
	Action_Date DATE
)
GO

DROP TRIGGER IF EXISTS Trg_Persons_Insert, Trg_Persons_Update, Trg_Persons_Delete;
GO

/*
Insert ایجاد تریگر برای حالت
*/
CREATE TRIGGER Trg_Persons_Insert ON dbo.Persons
AFTER INSERT 
AS
	INSERT INTO dbo.History_Persons(Code, FirstName, LastName, Action_Type, Action_Date)
	SELECT
		Code, FirstName, LastName, 'INSERT', GETDATE()
	FROM inserted
GO

/*
Update ایجاد تریگر برای حالت
*/
CREATE TRIGGER Trg_Persons_Update ON dbo.Persons
AFTER UPDATE 
AS
	-- مقدار قبل از به‌روزرسانی
	INSERT INTO dbo.History_Persons (Code, FirstName, LastName, Action_Type, Action_Date)
	SELECT
			Code, FirstName, LastName, 'OldValue', GETDATE()
	FROM deleted

	-- مقدار پس از به‌روزرسانی
		INSERT INTO dbo.History_Persons (Code, FirstName, LastName, Action_Type, Action_Date)
	SELECT
			Code, FirstName, LastName, 'NewValue', GETDATE()
	FROM inserted

GO


/*
Delete ایجاد تریگر برای حالت
*/
CREATE TRIGGER Trg_Persons_Delete ON dbo.Persons
AFTER DELETE
AS
	INSERT INTO dbo.History_Persons (Code, FirstName, LastName, Action_Type, Action_Date)
	SELECT
			Code, FirstName, LastName, 'DELETE', GETDATE()
	FROM deleted
GO


-- dbo.Persons درج رکورد در جدول
INSERT INTO dbo.Persons
	VALUES (1,N'مهدی',N'احمدی'),
	       (2,N'امید',N'سعادتی'),
		   (3,N'سپیده',N'کریمی');
GO

-- مشاهده رکوردهای جدول اصلی و جدول سوابق آن
SELECT * FROM dbo.Persons;
SELECT * FROM History_Persons;
GO

-- dbo.Persons به‌روزرسانی رکورد در جدول
UPDATE dbo.Persons
	SET Code = 100
		WHERE Code = 1;
GO

-- مشاهده رکوردهای جدول اصلی و جدول سوابق آن
SELECT * FROM dbo.Persons;
SELECT * FROM History_Persons;
GO

-- dbo.Persons حذف رکورد از جدول
DELETE FROM dbo.Persons
	WHERE Code = 100;
GO

-- مشاهده رکوردهای جدول اصلی و جدول سوابق آن
SELECT * FROM dbo.Persons;
SELECT * FROM History_Persons;
GO
--------------------------------------------------------------------

/*
CONTEXT_INFO
*/
SELECT
	session_id, host_name,
	program_name, context_info
FROM sys.dm_exec_sessions
	WHERE session_id >= 51;
GO


-- SQL Server 2016 تا قبل از Session_Context روش قدیمی برای تنظیم
DECLARE @Ctx VARBINARY(128);
SELECT @Ctx = CAST(N'User01, Tehran' AS VARBINARY(128));
SET CONTEXT_INFO @Ctx;
GO

SELECT CONTEXT_INFO();
GO

-- Session_Context مشاهده محتوای
SELECT CAST(CONTEXT_INFO() AS NVARCHAR(127));
GO


-- به‌بعد SQL Server 2016 از Session_Context روش جدید برای تنظیم
DECLARE @ID INT = 123456;
DECLARE @FullName NVARCHAR(128) = N'Ali Behboudi';
EXEC sys.sp_set_session_context @key  = N'ID', @Value = @ID;
EXEC sys.sp_set_session_context @key  = N'FullName', @Value = @FullName;
Go

SELECT SESSION_CONTEXT(N'ID'), SESSION_CONTEXT(N'FullName');
GO
--------------------------------------------------------------------

/*
Persons می‌خواهیم در جدول سوابق مربوط به جدول
کاربری Bussines User فیلدی را اضافه کنیم که نام
.را که باعث حذف رکوردها می‌شود، ثبت کند
*/

ALTER TABLE dbo.History_Persons
	ADD Users NVARCHAR(100);
GO

SELECT * FROM History_Persons
GO

DECLARE @FullName NVARCHAR(128) = N'علی بهبودی';
EXEC sys.sp_set_session_context @key  = N'ID', @Value = @FullName;
GO

-- ایجاد تغییر در تریگر حذف رکوردها
ALTER TRIGGER Trg_Persons_Delete ON dbo.Persons
AFTER DELETE
AS
	INSERT INTO dbo.History_Persons(Code,FirstName, LastName, Action_Type, Action_Date, Users)
		SELECT
			Code,FirstName, LastName, 'DELETE',
			GETDATE(), CAST(SESSION_CONTEXT(N'FullName') AS NVARCHAR(100))
		FROM deleted;
GO

DELETE FROM dbo.Persons
	WHERE Code = 2;
Go

SELECT * FROM dbo.Persons
SELECT * FROM dbo.History_Persons
GO

/*
INSTEAD OF TRIGGER
*/
/*
رکوردهایی درج شوند که سن هر کاربر کمتر از 50 سال باشد Valid_Persons می‌خواهیم در جدول
.درج شود InValid_Persons در صورتی‌که سن کاربر بیش از 50 سال بود این رکورد در جدول
*/

DROP TABLE IF EXISTS dbo.Valid_Persons, dbo.InValid_Persons;
GO

CREATE TABLE dbo.Valid_Persons
(
	Code INT,
	LastName NVARCHAR(150),
	Age TINYINT
)

CREATE TABLE dbo.InValid_Persons
(
	Code INT,
	LastName NVARCHAR(150),
	Age TINYINT
)

DROP TRIGGER IF EXISTS Valid_InsertTrigger;
GO

CREATE TRIGGER Valid_InsertTrigger ON dbo.Valid_Persons
INSTEAD OF INSERT
AS
	DECLARE @AGE TINYINT;
	SELECT @AGE = AGE FROM INSERTED;
	IF @AGE < 50
	INSERT INTO dbo.Valid_Persons
	SELECT * FROM inserted;
	ELSE 
	INSERT INTO dbo.InValid_Persons
	SELECT * FROM inserted;
GO

INSERT dbo.Valid_Persons (Code,LastName,Age)
	VALUES	(1,N'احمد',58);
GO

INSERT dbo.Valid_Persons (Code,LastName,Age)
	VALUES	(2,N'سهیل',20);
GO

SELECT * FROM dbo.Valid_Persons;
SELECT * FROM dbo.InValid_Persons;
GO

/*
PIVOT Table
*/
DROP TABLE IF EXISTS dbo.Pvt_Table;
GO

CREATE TABLE dbo.Pvt_Table
(
	EmployeeID INT NOT NULL,
	CustomerID VARCHAR(5) NOT NULL,
	Qty INT NOT NULL
);
GO


INSERT INTO dbo.Pvt_Table(EmployeeID, CustomerID, Qty)
	VALUES	(3,'A',10),
			(2,'A',20),
			(1,'B',20),
			(2,'A',40),
			(1,'C',30),
			(2,'B',10),
			(3,'A',10),
			(1,'C',20),
			(2,'B',50),
			(3,'C',20),
			(3,'D',30);
GO

SELECT * FROM dbo.Pvt_Table

SELECT 
	EmployeeID, CustomerID,
	SUM(Qty) AS Sum_Qty
FROM dbo.Pvt_Table
GROUP BY EmployeeID, CustomerID
ORDER BY EmployeeID;
GO



/*
:نتایج زیر را داشته باشیم Pvt_Table می‌خواهیم با توجه به رکوردهای موجود در جدول

 EmployeeID		A       B       C       D
------------ ------- ------- ------- -------
	1          NULL    20      50      NULL
	2          60      60      NULL    NULL
	3          20      NULL    20      30
*/

/*
-----------------------------------------------------------------------
	روش اول استاندارد: CASE با استفاده از PIVOT Table پیاده‌سازی
-----------------------------------------------------------------------
*/
SELECT
	EmployeeID,
	SUM(CASE WHEN CustomerID =  'A' THEN Qty END) AS A,
	SUM(CASE WHEN CustomerID =  'B' THEN Qty END) AS B,
	SUM(CASE WHEN CustomerID =  'C' THEN Qty END) AS C,
	SUM(CASE WHEN CustomerID =  'D' THEN Qty END) AS D
FROM dbo.Pvt_Table
GROUP BY EmployeeID;
GO


--------------------------------------------------------------------

/*
-----------------------------------------------------------------------
	روش دوم استاندارد: Subquery با استفاده از PIVOT Table پیاده‌سازی
-----------------------------------------------------------------------
*/
-- A صرفا برای کارمند 1 با مشتری
SELECT
	EmployeeID,
	(SELECT SUM(Qty) FROM dbo.Pvt_Table AS P2
		WHERE P2.EmployeeID = P1.EmployeeID
		AND P2.CustomerID = 'A') AS A
FROM dbo.Pvt_Table AS P1
GROUP BY EmployeeID;
GO

-- هر کارمند با هر مشتری
SELECT
	P1.EmployeeID,
	(SELECT SUM(Qty) FROM dbo.Pvt_Table AS P2
		WHERE P2.EmployeeID = P1.EmployeeID
		AND	P2.CustomerID = 'A') AS A,
	(SELECT SUM(Qty) FROM dbo.Pvt_Table AS P2
		WHERE P2.EmployeeID = P1.EmployeeID
		AND	P2.CustomerID = 'B') AS B,
	(SELECT SUM(Qty) FROM dbo.Pvt_Table AS P2
		WHERE P2.EmployeeID = P1.EmployeeID
		AND	P2.CustomerID = 'C') AS C,
	(SELECT SUM(Qty) FROM dbo.Pvt_Table AS P2
		WHERE P2.EmployeeID = P1.EmployeeID
		AND	P2.CustomerID = 'D') AS D
FROM dbo.Pvt_Table AS P1
GROUP BY P1.EmployeeID;
GO
--------------------------------------------------------------------

/*
--------------------------------------------------------------------
						Native روش

SELECT ...
FROM <source_table | table_expression>
	PIVOT
		(	<agg_func>(<aggregation_element>)	FOR <spreading_element>
			IN (<list_of_target_columns>)
		) AS <result_table_alias>;

--------------------------------------------------------------------
*/

-- Native روش
SELECT 
	PT.*
FROM dbo.Pvt_Table
	PIVOT(SUM (Qty) FOR customerID IN (A, B, C, D)) AS PT;
GO

-- Pvt_Table افزودن یک ستون به جدول
ALTER TABLE dbo.Pvt_Table
ADD ID INT IDENTITY;
GO

-- ???
SELECT
	*
FROM dbo.Pvt_Table
	PIVOT(SUM(Qty)	FOR CustomerID IN(A,B,C,D)) AS PT;
GO

-- اصلاح کوئری بالا
SELECT
	PT.*
FROM (SELECT EmployeeID, CustomerID, Qty FROM dbo.Pvt_Table) AS Tmp
	PIVOT(SUM(Qty)	FOR CustomerID IN(A,B,C,D)) AS PT;
GO


SELECT * FROM dbo.Pvt_Table;
GO
/*
:اگر بخواهیم نتایج به‌صورت زیر باشد داریم

 CustomerID		1       2       3
------------ ------- ------- -------
	A          NULL    60      20
	B          20      60      NULL
	C          50      NULL    20
	D          NULL    NULL    30
*/
SELECT PT.*
FROM (SELECT EmployeeID, CustomerID, Qty FROM dbo.Pvt_Table) AS Tmp
	PIVOT(SUM(Qty)	FOR EmployeeID IN([1],[2],[3],[4])) AS PT;
GO
--------------------------------------------------------------------

-- Dynamic PIVOT Table

-- ?به‌ازای هر استان از هر شهر چه تعداد کارمند داریم
DECLARE @City NVARCHAR(MAX), @Sql NVARCHAR(MAX)
SET @City = '';
	SELECT @City = @City + City + ','
FROM dbo.Employees
GROUP BY city
PRINT @CITY
SET @City = LEFT(@City, LEN(@City) - 1)
PRINT @CITY
SET @SQL = '
SELECT 
	*
FROM 
	(SELECT 
		state, city
	FROM dbo.employees) AS Tmp
	PIVOT (COUNT(City) FOR City IN ('+@City+')) AS PT';
PRINT @SQL
EXEC SP_executesql @SQL;
GO


-- ?به‌ازای هر منطقه از هر شهر چه تعداد مشتری داریم
DECLARE @City NVARCHAR(MAX), @Sql NVARCHAR(MAX);
SET @City ='';
SELECT
	@City = @City + City + ','
FROM dbo.Customers
GROUP BY City;
SET @City = LEFT(@City,LEN(@City) - 1);
SET @Sql = 'SELECT * FROM(SELECT
							Region, City 
						  FROM dbo.Customers) AS Tmp
							PIVOT(COUNT(City)	FOR City IN(' + @City + ')) AS PT';
EXEC sp_executesql @Sql;
GO

-- اصلاح کوئری بالا
DECLARE @City NVARCHAR(MAX), @Sql NVARCHAR(MAX);
SET @City ='[';
SELECT
	@City = @City + City + ']' + ',' + '['
FROM dbo.Customers
GROUP BY City;
SET @City = LEFT(@City,LEN(@City) - 2);
SET @Sql = 'SELECT * FROM(SELECT
							Region, City 
						  FROM dbo.Customers) AS Tmp
							PIVOT(COUNT(City)	FOR City IN(' + @City + ')) AS PT'
EXEC sp_executesql @Sql;
GO


/*
UNPIVOT Table
*/
DROP TABLE IF EXISTS dbo.UnPvt_Table;
GO


CREATE TABLE dbo.UnPvt_Table
(
  EmployeeID INT PRIMARY KEY,
  A VARCHAR(5) NULL,
  B VARCHAR(5) NULL,
  C VARCHAR(5) NULL,
  D VARCHAR(5) NULL
);
GO

INSERT INTO dbo.UnPvt_Table(EmployeeID, A, B, C, D)
  SELECT
	EmployeeID, A, B, C, D
  FROM (SELECT
			EmployeeID, CustomerID, Qty
        FROM dbo.Pvt_Table) AS Tmp
    PIVOT(SUM(qty) FOR CustomerID IN(A, B, C, D)) AS TP;
GO

SELECT * FROM dbo.UnPvt_Table;
GO

/*
-----------------------------------------------------------------------
	به روش استاندارد UNPIVOT Table پیاده‌سازی
-----------------------------------------------------------------------
*/

--Step 1: Generate Copies
SELECT * FROM dbo.UnPvt_Table
CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS TVC (Cust_ID);
GO

-- Step 2: Extracting Elements
SELECT
	EmployeeID, Cust_ID,
	CASE Cust_ID
		WHEN 'A' THEN A
		WHEN 'B' THEN B
		WHEN 'C' THEN C
		WHEN 'D' THEN D    
	END AS Qty
FROM dbo.UnPvt_Table
CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS TVC (Cust_ID);
GO

-- Step 3: Eliminating Irrelevant Intersection (NULLs)
SELECT *
FROM (SELECT
		EmployeeID, Cust_ID,
        CASE Cust_ID
          WHEN 'A' THEN A
          WHEN 'B' THEN B
          WHEN 'C' THEN C
          WHEN 'D' THEN D    
        END AS Qty
      FROM dbo.UnPvt_Table
        CROSS JOIN (VALUES('A'),('B'),('C'),('D')) AS TVC (Cust_ID)) AS Tmp
WHERE Qty IS NOT NULL;
GO

/*
-----------------------------------------------------------------------
	Native به روش UNPIVOT Table پیاده‌سازی

SELECT ...
FROM <source_table_or_table_expression>
	UNPIVOT(	<target_col_to_hold_source_col_values>	FOR <target_col_to_hold_source_col_names> 
				IN(<list_of_source_columns>)
		   ) AS <result_table_alias>;

-----------------------------------------------------------------------
*/

SELECT
	EmployeeID, CustomerID, Qty
FROM dbo.UnPvt_Table
	UNPIVOT(Qty FOR CustomerID IN(A, B, C, D)) AS UPT;
GO