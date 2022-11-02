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
