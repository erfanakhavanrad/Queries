use SampleDb
use NikamoozDB
/*
Session 20
*/

--01 - SQL dbforge

USE NikamoozDB;
GO

-- JOIN
SELECT * FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID

--------------------------------------------------------------------

-- CTE
;WITH cte AS
(
	SELECT *
	FROM dbo.table_name

	UNION ALL

	SELECT t2.*
	FROM cte t1
	JOIN dbo.table_name t2 ON t1.parent_column_name = t2.column_name
)
SELECT * 
FROM cte
--OPTION (MAXRECURSION 0)


--------------------------------------------------------------------

-- Auto Generate Alias
SELECT * FROM Customers c

SELECT * FROM Sales.Orders AS O

--------------------------------------------------------------------

-- Custome Alias
SELECT * FROM Customers AS C_C

SELECT * FROM Customers AS C_C

SELECT * FROM Customers AS C_C
JOIN Customers AS C_C1
ON C_C.CustomerID = C_C1.CustomerID

--------------------------------------------------------------------

-- Column Picker (WF | ORDER BY , ...)
SELECT
	C_C.CustomerID,
	ROW_NUMBER() OVER(PARTITION BY C_C.ContactTitle, C_C.Region ORDER BY C_C.CompanyName, C_C.ContactName)
FROM Customers AS C_C

SELECT * FROM Sales.Customers AS C_C
ORDER BY C_C.ContactName
--------------------------------------------------------------------

-- Wild Card Expansion
SELECT c.CustomerID
	  ,c.CompanyName
	  ,c.ContactName
	  ,c.ContactTitle
	  ,c.City
	  ,c.Region
	  ,c.State FROM Customers c

--------------------------------------------------------------------

-- INSERT | UPDATE | EXEC Expansion
INSERT INTO Customers (CompanyName, ContactName, ContactTitle, City, Region, State)
	VALUES (N'', N'', N'', N'', N'', N'');

UPDATE CheckTable 
SET Code = ''
WHERE <Search Conditions>;

EXEC ConcatInfo @FirstName = N''
			   ,@LastName = N''
			   ,@FullName = N''
--------------------------------------------------------------------

-- CREATE | ALTER SP/FUNCTION/TRIGGER/VIEW   
IF OBJECT_ID('dbo.usp_procedure_name') IS NOT NULL
	SET NOEXEC ON
GO
CREATE PROCEDURE dbo.usp_procedure_name
AS RETURN;
GO
SET NOEXEC OFF
GO
ALTER PROCEDURE dbo.usp_procedure_name
(
	
)
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS BEGIN
	SET NOCOUNT ON;

	RETURN 0;
END
GO

ALTER PROCEDURE dbo.ConcatInfo
(
	@FirstName NVARCHAR(40),
	@LastName NVARCHAR(60),
	@FullName NVARCHAR(100) OUTPUT
)
AS
BEGIN
	SELECT @FullName = CONCAT(@FirstName, ' ', @LastName)
END

GO
--------------------------------------------------------------------

-- Highlight Matching Columns (SELECT | INSERT)
SELECT C_C.CustomerID
	  ,C_C.CompanyName
	  ,C_C.ContactName
	  ,C_C.ContactTitle
	  ,C_C.City
	  ,C_C.Region
	  ,C_C.State FROM Customers AS C_C

INSERT INTO Customers (CompanyName, ContactName, ContactTitle, City, Region, State)
	VALUES (N'', N'', N'', N'', N'', N'');

--------------------------------------------------------------------

-- Semicolon Insertion
SELECT
	C.CustomerID, C.City
FROM Customers AS C
GO

SELECT * FROM Sales.Orders AS O
GO
--------------------------------------------------------------------

-- Rename Alias (F2 ---> Tab | Enter)
SELECT
	C.CompanyName, C.City, C.Region, C.State,
	O.OrderDate,
	P.ProductName
FROM Customers AS C
JOIN Orders AS O
	ON C.CustomerID = O.CustomerID
JOIN OrderDetails AS OD
	ON O.OrderID = OD.OrderID
JOIN Products AS P
	ON OD.ProductID = P.ProductID;
GO

DECLARE @Var1 INT;
SET @Var1 = 100;

WHILE @Var1 < 1000
	BEGIN
		---
		---
		---
		SET @Var1 += 1;
	END;
GO
--------------------------------------------------------------------

-- Format Selection | Format Document (Option)
SELECT
	OD.OrderID
   ,OD.ProductID
   ,OD.UnitPrice
   ,OD.Qty
   ,OD.Discount
FROM Sales.OrderDetails AS OD;
GO
SELECT
	C.CustomerID
   ,C.CompanyName
   ,C.ContactName
   ,C.ContactTitle
   ,C.City
   ,C.Region
   ,C.State
FROM Customers AS C;
GO

-- NOFORMAT
SELECT C.CustomerID, C.ContactName, C.Region FROM Customers AS C;
-- ENDFORMAT
--------------------------------------------------------------------

/*
SQL Formatter
فرمت یک فایل حاوی اسکریپت
*/
--------------------------------------------------------------------

-- SQL Complete/Snippets Manager (SelCount)
SELECT COUNT(*) FROM Customers AS C_C;

SELECT COUNT(1) FROM Customers AS C_C;

--------------------------------------------------------------------

-- Execute Current Statement | Execute To Cursor
SELECT * FROM Customers AS c;
GO

SELECT * FROM Sales.Orders AS o;
GO

SELECT * FROM Sales.OrderDetails AS od;
GO
--------------------------------------------------------------------

-- GO To Definition
SELECT O.OrderID
	  ,O.CustomerID
	  ,O.EmployeeID
	  ,O.OrderDate
	  ,O.ShipperID
	  ,O.Freight FROM Orders O;
GO
--------------------------------------------------------------------

-- Execution History
SELECT * FROM Customers AS C;
GO

SELECT * FROM Orders AS O;
GO
--------------------------------------------------------------------

/*
Document Outline
Session ایجاد نمودار درختی از اسکریپت‌های یک
*/
--------------------------------------------------------------------

-- Row Count Information
SELECT * FROM Customers AS C;
GO
--------------------------------------------------------------------

-- Show Data Viewer
USE AdventureworksDW2016CTP3;
GO
SELECT * FROM DimProduct AS dp;
GO
--------------------------------------------------------------------

-- Tab Color
-- Close All Unmodifies
-- Restore Last Closed Tab



--02 - ApexSQL Refactor

USE NikamoozDB;
GO

/*
Qualify object names
درج اسکیمای آبجکت
*/

SELECT *
FROM dbo.Orders;
GO

SELECT O.OrderID, 
       O.EmployeeID, 
       O.CustomerID, 
       O.OrderDate
FROM dbo.Orders AS O;
GO
--------------------------------------------------------------------

/*
Wildcard expansion
تبدیل * به نام ستون‌های آبجکت
*/

SELECT Orders.OrderID, 
       Orders.CustomerID, 
       Orders.EmployeeID, 
       Orders.OrderDate, 
       Orders.ShipperID, 
       Orders.Freight
FROM Orders;
GO

SELECT O.OrderID, 
       O.CustomerID, 
       O.EmployeeID, 
       O.OrderDate, 
       O.ShipperID, 
       O.Freight
FROM dbo.Orders AS O;
GO
--------------------------------------------------------------------

/*
Unused variables and parameters
تشخیص متغیرها و پارمترهای استفاده‌نشده
*/

CREATE PROC Test_Procedure
    @C_ID INT,
    @E_ID INT,
    @OD DATE
AS
    BEGIN
	   SELECT * FROM dbo.Orders
		  WHERE CustomerID = @C_ID
			 AND OrderDate > @OD
    END
GO

DECLARE @Var1 INT;
DECLARE @Var INT = 1;
GO
--------------------------------------------------------------------

/*
Change Parameters
تغییر نام و نوع‌داده پارامتر
حذف و یا اضافه کردن پارامتر
*/

DROP FUNCTION IF EXISTS dbo.Top_Orders;
GO

CREATE FUNCTION dbo.Top_Orders(@CustID AS INT, @n AS TINYINT)
RETURNS TABLE
AS
RETURN
	SELECT
		TOP (@n) OrderID, CustomerID, OrderDate
	FROM dbo.Orders
		WHERE CustomerID = @CustID
	ORDER BY OrderDate DESC, OrderID DESC;
GO
--------------------------------------------------------------------

/*
Format SQL
تنظیمات مربوط به الگوی اسکریپت‌نویسی
.این قابلیت برای فایل حاوی اسکریپت و یا یک آبجکت هم امکان‌پذیر است
*/
SELECT OrderID, 
       OrderDate
FROM dbo.Orders
WHERE OrderID BETWEEN 1 AND 100;
GO



--03 - ApexSQL Complete

USE NikamoozDB;
GO

/*
auto-complete
نمایش آبجکت‌ها و اجزای آن در هنگام کوئری‌نویسی

!حتما قبل از استفاده از این قابلیت فعال شده باشد
ApexSQL\ApexSQL Complete\Enable auto-complete
*/
SELECT * FROM dbo.Customers c	
-- Hint & Option
--------------------------------------------------------------------

/*
auto-replacements
جایگزینی کلمات در کوئری‌ها

!حتما قبل از استفاده از این قابلیت فعال شده باشد
ApexSQL\ApexSQL Complete\Enable auto-replacements

برای استفاده از این قابلیت می‌بایست ابتدا در قسمت
کلمات مورد‌نظر و جایگزین را ایجاد کرد Manage auto-replacements

.این قابلیت با کلیک بر روی آبجکت‌ها نیز امکان‌پذیر است
(Asign auto-replacements)
*/

-- od = OrderDetails
-- OD = OrderDetails
SELECT * FROM dbo.Odetails o
SELECT * FROM dbo.Odetails o
--------------------------------------------------------------------

/*
Executed queries
مدیریت کوئری‌های اجرا‌شده، جستجو در محتوای آن‌ها و قابلیت استفاده مجدد از آن‌ها

.تمامی کوئری‌های اجرا‌شده لاگ می‌شوند
*/

--------------------------------------------------------------------

/*
Test Mode
Session پیاده‌سازی شرایط تستی در یک
*/

--------------------------------------------------------------------

/*
Tab Navigation
WorkSpace ها و ایجاد Session مدیریت
*/


--04 - Rename Objects

USE master;
GO

DROP DATABASE IF EXISTS Test;
GO

CREATE DATABASE	Test;
GO

USE Test;
GO

DROP TABLE IF EXISTS dbo.Lesson_STD;
DROP TABLE IF EXISTS dbo.Lesson;
DROP TABLE IF EXISTS dbo.STD;
GO

-- ایجاد جدول دانشجو
CREATE TABLE dbo.STD
(
    ID VARCHAR(10) PRIMARY KEY,
    Family NVARCHAR(100),
    City NVARCHAR(50)
);
GO

-- جدول درس
CREATE TABLE dbo.Lesson
(
    Code INT PRIMARY KEY,
    Title NVARCHAR(50)
);
GO

-- جدول درس-دانشجو
CREATE TABLE dbo.Lesson_STD
(
    Row_ID INT IDENTITY,
    ID VARCHAR(10) REFERENCES STD(ID),
    Code INT REFERENCES Lesson(Code),
    Date_Reg DATE DEFAULT GETDATE(),
);
GO

-- درج رکورد در جدول دانشجو
INSERT INTO dbo.STD (ID,Family,City)
    VALUES	('96-01',N'احمدی', N'تهران'),
			('96-02',N'سعادت', N'اصفهان'),
			('96-03',N'پرتوی', N'شیراز');
GO

-- درج رکورد در جدول درس
INSERT INTO dbo.Lesson (Code,Title)
    VALUES	(1,N'فیزیک'),(2,N'هندسه'),(3,N'زبان'),
			(4,N'شیمی'),(5,N'ادبیات');
GO

-- درج رکورد در جدول درس-دانشجو
INSERT INTO dbo.Lesson_STD (ID,Code)
    VALUES	('96-01',1),('96-01',2),('96-01',5),
			('96-02',2),('96-02',4),
			('96-03',3);
GO

CREATE VIEW dbo.Students_List
AS
    SELECT
		ID,Family,City
	FROM dbo.STD;
GO

CREATE PROC Students_Lessons
    @ID VARCHAR(10)
AS
    BEGIN
	   SELECT
			S.ID,S.Family,S.City
	   FROM dbo.STD AS S
			WHERE EXISTS (SELECT 1 FROM dbo.Lesson_STD AS LS
							WHERE S.ID = LS.id) AND S.ID = @ID;
    END
GO

 --Test_SQL Format
 SELECT OD.OrderID, OD.ProductID,OD.UnitPrice,
OD.Qty,OD.Discount FROM Sales.
OrderDetails 
AS OD; GO SELECT C.CustomerID,C.CompanyName,C.ContactName,C.ContactTitle,C.City,C.Region,C.State
FROM Customers AS C; GO SELECT OD.OrderID, OD.ProductID,OD.UnitPrice, OD.Qty,OD.Discount FROM Sales.OrderDetails 
AS OD; GO SELECT C.CustomerID,C.CompanyName,C.ContactName,C.ContactTitle,C.City,C.Region,C.State
FROM 
Customers 
AS C;
GO SELECT OD.OrderID, OD.ProductID,OD.UnitPrice,
OD.Qty,OD.Discount FROM 
Sales.
OrderDetails 
AS OD; GO SELECT C.CustomerID,
C.CompanyName,C.ContactName,C.ContactTitle,C.City,C.Region,C.State
FROM Customers AS C; GO SELECT OD.OrderID, OD.ProductID,OD.UnitPrice, OD.Qty,OD.Discount FROM Sales.OrderDetails 
AS OD; GO SELECT C.CustomerID,C.CompanyName,C.ContactName,C.ContactTitle,C.City,C.Region,C.State
FROM 
Customers AS C;
GO
SELECT E.EmployeeID,E.LastName,E.FirstName,E.Title,E.TitleofCourtesy,E.Birthdate,E.Hiredate,E.City,E.Region,E.State,E.mgrid
,O.OrderID,O.CustomerID,O.EmployeeID,O.OrderDate,O.ShipperID,O.Freight FROM Employees AS E JOIN Orders AS O ON E.EmployeeID = O.EmployeeID;
GO

 SELECT E.EmployeeID
,E.Las
tName
,E.FirstN
ame,E.Title,E.TitleofC
ourtesy
,E.Birthdate,E.Hiredate
,E.City
,E.Region
	  ,E.State
	  ,E.mgrid
	  ,O.OrderID,O.Cu
	  stomerID
,O.EmployeeID
,O.OrderDate
,O.ShipperID
	  ,O.Freight 
	  FROM Employ
	  ees AS E JOIN Orders AS O ON E.EmployeeID = O.EmployeeID;GO SELECT E.EmployeeID
,E.Las
tName
,E.FirstN
ame,E.Title,E.TitleofC
ourtesy
,E.Birthdate,E.Hiredate
,E.City
,E.Region
	  ,E.State
	  ,E.mgrid
	  ,O.OrderID,O.Cu
	  stomerID
,O.EmployeeID
,O.OrderDate
,O.ShipperID
	  ,O.Freight 
	  FROM Employees AS E JOIN Orders AS O ON E.EmployeeID = O.EmployeeID;GO SELECT E.EmployeeID
,E.Las
tName
,E.FirstN
ame,E.Title,E.TitleofC
ourtesy
,E.Birthdate,E.Hiredate
,E.City
,E.Region
	  ,E.State
	  ,E.mgrid
	  ,O.OrderID,O.Cu
	  stomerID
,O.EmployeeID
,O.OrderDate
,O.ShipperID
	  ,O.Freight 
	  FROM Employees AS E JOIN Orders AS O ON E.EmployeeID = O.EmployeeID;GO 