USE NikamoozDB
/*
	Session 4
*/


/*
.مشاهده فهرست کارمندانی که با مشتری 71 ثبت سفارش داشته‌اند
.طبیعی است که یک کارمند برای یک مشتری چندین ثبت سفارش را انجام داده باشد
*/
SELECT 
	EmployeeID
FROM dbo.Orders
	WHERE CustomerID = 71;
GO

/*
DISTINCT
عدم درنظر گرفتن مقادیر تکراری
*/
SELECT 
	DISTINCT EmployeeID
FROM dbo.Orders
	WHERE CustomerID = 71;
GO

/*
مشاهده فهرست کارمندانی که با مشتری 71
.ثبت سفارش داشته‌اند به‌همراه سال ثبت سفارش
تکرار رکوردها
*/ 
SELECT 
	EmployeeID, YEAR(OrderDate) AS OrderYear
FROM dbo.Orders
	WHERE CustomerID = 71
ORDER BY EmployeeID;
GO

-- بر روی بیش از یک ستون DISTINCT عملیات
SELECT 
	DISTINCT EmployeeID, YEAR(OrderDate) AS OrderYear
FROM dbo.Orders
	WHERE CustomerID = 71
ORDER BY EmployeeID;
GO

-- ORDER BY و DISTINCT چالش
SELECT 
	DISTINCT State
FROM dbo.Employees;
GO

SELECT 
	  DISTINCT State, EmployeeID
FROM dbo.Employees
ORDER BY EmployeeID;
GO

-- ???
SELECT 
	  DISTINCT State
FROM dbo.Employees
ORDER BY EmployeeID;
GO


-- فهرست تمامی‌سفارشات، مرتب‌شده بر اساس جدید‌ترین تاریخ
SELECT
	OrderID, OrderDate
FROM dbo.Orders
ORDER BY OrderDate DESC;
GO

-- مشاهده جدیدترین 5 سفارش ثبت‌شده
SELECT
	TOP (5) OrderID, OrderDate
FROM dbo.Orders
ORDER BY OrderDate DESC;
GO

-- مشاهده قدیمی‌ترین 5 سفارش ثبت‌شده
SELECT
	TOP (5) OrderID, OrderDate
FROM dbo.Orders
ORDER BY OrderDate;
GO

-- انتخاب پنج درصد از جدیدترین سفارش‌های ثبت‌شده
SELECT
	TOP (5) PERCENT OrderID, OrderDate
FROM dbo.Orders
ORDER BY OrderDate DESC;
GO

-- ORDER BY بدون استفاده از TOP فیلتر
SELECT
	TOP (5) OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders;
GO

--  انتخاب جدیدترین پنج سفارش ثبت‌شده با درنظر گرفتن سایر مقادیر برابر
SELECT
	TOP (5) WITH TIES OrderID, OrderDate
FROM dbo.Orders
ORDER BY OrderDate DESC;
GO

/*
OFFSET [integer_constant | offset_row_count_expression] ROWS|ROW 
FETCH NEXT|FIRST [integer_constant | offset_row_count_expression] ROWS|ROW ONLY
*/

-- نمایش 10 سفارش ثبت‌شده اخیر
SELECT 
	TOP (10) OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders
ORDER BY OrderDate DESC;
GO

-- OFFSET FETCH شبیه‌سازی کوئری بالا با استفاده از 
SELECT 
	OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders
ORDER BY OrderDate DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;
GO

/*
جدیدترین 5 سفارش پس از 10 سفارش اخیر
یعنی سفارش‌های 11 تا 15
*/
SELECT 
	OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders
ORDER BY OrderDate DESC
OFFSET 10 ROWS
FETCH NEXT 5 ROWS ONLY;
GO

/*
FETCH بدون OFFSET
نادیده گرفتن 10 سفارش ابتدایی از لیست رکوردها بر اساس نوع مرتب‌سازی و نمایش سایر رکوردها
*/
SELECT 
	OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders
ORDER BY OrderDate DESC, OrderID DESC
OFFSET 10 ROWS;
GO

-- !!!قابل اجرا نیست OFFSET بدون FETCH
SELECT 
	OrderID, OrderDate, CustomerID, EmployeeID
FROM dbo.Orders
ORDER BY OrderDate DESC, OrderID DESC
FETCH NEXT 5 ROWS ONLY;
GO

/*
:نکته مهم
OFFSET FETCH در PERCENT و WITH TIES عدم پشتیبانی از  
*/
--------------------------------------------------------------------

/* Logical Order
-- SELECT ترتیب اجرای منطقی بخش‌های مخالف دستور

1- FROM
2- WHERE
3- GROUP BY
4- HAVING
5- SELECT
	5-1 Expressions
	5-2 DISTINCT
6- ORDER BY
7- TOP / OFFSET-FETCH

*/

-- Accept TRUE
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers -- 91 Record
	WHERE Region = N'جنوب';
GO 

SELECT  -- 91 Record - 1 Record  = 90 Record
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE Region <> N'جنوب';
GO

-- !درست نیست NULL = NULL عبارت
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE Region = NULL;
GO

-- UNKNOWN بر روی مقادیر NOT عدم تاثیر
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE NOT (Region) = NULL;
GO

-- .است NULL آن‌ها برابر با Region فهرست مشتریانی که مقدار فیلد
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE Region IS NULL;
GO

-- .نیست NULL آن‌ها برابر با Region فهرست مشتریانی که مقدار فیلد
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE Region IS NOT NULL;
GO

---???
-- .آن‌ها صرفا جنوب نیست Region فهرست مشتریانی که مقدار فیلد
SELECT 
	CustomerID, State, Region, City
FROM dbo.Customers
	WHERE Region <> N'جنوب'
	OR Region IS NULL;
GO
--------------------------------------------------------------------

/*
 ISNULL تابع
-- با یک مقدار مشخص NULL جایگزین کردن مقدار
ISNULL ( Check_Expression , Replacement_Value )
*/

DECLARE @str1 VARCHAR(100) = NULL;
SELECT  ISNULL(@str1,'NULL Value');
GO
--------------------------------------------------------------------

-- Reject False
DROP TABLE IF EXISTS ChkConstraint;
GO

CREATE TABLE ChkConstraint
(
	ID        INT NOT NULL IDENTITY,
	Family    NVARCHAR(100),
	Score	  INT CONSTRAINT CHK_Positive1 CHECK(Score >= 0)
);
GO

-- TRUE پذیرش مقدار
INSERT INTO dbo.ChkConstraint(Family, Score)  
	VALUES (N'سعیدی',100);
GO

-- NULL پذیرش مقدار
INSERT INTO dbo.ChkConstraint(Family)  
	VALUES (N'پرتوی');
GO

-- FALSE عدم پذیرش مقدار
INSERT INTO dbo.ChkConstraint(Family, Score)  
	VALUES (N'احمدی',-10);
GO

SELECT * FROM dbo.ChkConstraint;
GO
--------------------------------------------------------------------

-- All-at-Once عملیات
SELECT
	OrderID,
	YEAR(OrderDate) AS OrderYear,
	OrderYear + 1 AS NextYear
FROM dbo.Orders;
GO

SELECT
	OrderID,
	YEAR(OrderDate) AS OrderYear,
	YEAR(OrderDate) + 1 AS NextYear
FROM dbo.Orders;
GO


-- لیست تمامی محصولات
SELECT
	ProductID, ProductName, CategoryID
FROM dbo.Products;
GO

-- Simple CASE
SELECT 
	ProductID, ProductName, CategoryID,
	CASE CategoryID
		WHEN 1 THEN N'نوشیدنی'
		WHEN 2 THEN N'ادویه‌جات'
		WHEN 3 THEN N'مرباجات'
		WHEN 4 THEN N'محصولات لبنی'
		WHEN 5 THEN N'حبوبات'
		WHEN 6 THEN N'گوشت و مرغ'
		WHEN 7 THEN N'ارگانیک'
		WHEN 8 THEN N'دریایی'
		ELSE N'متفرقه'
	END AS CategoryName
FROM dbo.Products
ORDER BY CategoryName;
GO
--------------------------------------------------------------------

-- محصولات براساس قیمت پایه
SELECT
	ProductID, UnitPrice
FROM dbo.OrderDetails;
GO

-- Searched CASE
SELECT ProductID, UnitPrice,
	CASE
		WHEN UnitPrice < 50 THEN N'کمتر از 50'
		WHEN UnitPrice BETWEEN 50 AND 100 THEN N'بین 50 تا 100'
		WHEN UnitPrice > 100 THEN N'بیشتر از 100'
	ELSE N'نامشخص'
	END AS UnitPriceCategory
FROM dbo.OrderDetails
ORDER BY UnitPrice;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
.نوشته شده است Simple CASE کوئری زیر به‌صورت
.بازنویسی کنید Searched CASE اکنون آن را به‌صورت
*/

SELECT 
	EmployeeID, FirstName, TitleofCourtesy,
	CASE TitleofCourtesy
		WHEN 'Ms.'  THEN 'Female'
		WHEN 'Mrs.' THEN 'Female'
		WHEN 'Mr.'  THEN 'Male'
		ELSE 'Unknown'
	END AS Gender
FROM dbo.Employees;
GO

SELECT 
	EmployeeID, FirstName, TitleofCourtesy,
	CASE
		WHEN TitleofCourtesy IN ('Ms.','Mrs.') THEN 'Female'
		WHEN TitleofCourtesy = 'Mr.' THEN 'Male'
	ELSE 'Unknown'
	END AS Gender
FROM dbo.Employees;
GO

SELECT 
	EmployeeID, FirstName, TitleofCourtesy,
	CASE
		WHEN TitleofCourtesy ='Ms.' OR TitleofCourtesy ='Mrs.' THEN 'Female'
		WHEN TitleofCourtesy = 'Mr.' THEN 'Male'
	ELSE 'Unknown'
	END AS Gender
FROM dbo.Employees;
GO
--------------------------------------------------------------------

--- ???
-- .خواهند شد NULL باشد آن‌گاه سایر مقادیر که در شرط صدق نکنند در خروجی ELSE فاقد CASE اگر
SELECT
	City,
	CASE City
		WHEN N'تهران' THEN N'پایتخت' 
	END AS N'نوع شهر'
FROM dbo.Customers;
GO
--------------------------------------------------------------------

/*
و مرتب‌سازی رکوردها NULL
*/

-- .در ابتدای فهرست مرتب می‌شوند NULL در مرتب‌سازی صعودی، مقادیر
SELECT 
	CustomerID, Region
FROM dbo.Customers 
ORDER BY Region;
GO

-- .در انتهای فهرست مرتب می‌شوند NULL در مرتب‌سازی نزولی، مقادیر
SELECT 
	CustomerID, Region
FROM dbo.Customers 
ORDER BY Region DESC;
GO

-- CASE رفع مشکل مرتب‌سازی با استفاده از 
SELECT
	CustomerID, Region
FROM dbo.Customers
ORDER BY 
	CASE WHEN Region IS NULL THEN 1 ELSE 0 END, Region;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی
.کوئری زیر را به‌گونه‌ای بازنویسی کنید که خروجی آن به‌صورت زیر باشد
در انتها بیاید NULL انجام شود اما مقادیر Region در واقع مرتب‌سازی صعودی و براساس فیلد
.به‌صورت نزولی باشد CustomerID مرتب‌سازی فیلد Region ضمنا در صورت وجود مقادیر تکراری در فیلد

CustomerID    Region
----------- ---------
   67         جنوب
   88         شمال
   82         شمال
   75         شمال
   48         شمال
   35         شمال
   31         شمال
   10         شمال
   65         غرب
   47         غرب
   ...
   91         NULL
   90         NULL
   87         NULL
   ...
   3          NULL
   2          NULL
   1          NULL

(91 rows affected)
*/

SELECT 
	CustomerID, Region
FROM dbo.Customers
ORDER BY Region;
GO

SELECT
	CustomerID, Region
FROM dbo.Customers
ORDER BY 
	CASE WHEN Region IS NULL THEN 1 ELSE 0 END, Region, CustomerID DESC;
GO

/*
LEN/DATALENGTH Function

LEN ( string_expression )
DATALENGTH ( expression )

طول رشته و تعداد بایت‌های تخصیص داده‌شده به رشته 
*/

-- های یونیکدی Data Type تفاوت عملکرد با
SELECT LEN(N'سلام');
SELECT DATALENGTH(N'سلام');

SELECT LEN('A');
SELECT DATALENGTH('A');
GO

SELECT DATALENGTH(N'A');
GO

-- پس از رشته Blank مقادیر
SELECT LEN(N'My String   ');
SELECT DATALENGTH(N'My String   ');
GO
--------------------------------------------------------------------

/*
LOWER/UPPER Functions

LOWER ( character_expression )
UPPER ( character_expression )

کوچک و بزرگ کردن کاراکترهای یک رشته
*/

SELECT UPPER('my sTRing');
SELECT LOWER('my sTRing');
GO
--------------------------------------------------------------------

/*
RTRIM/LTRIM Functions

RTRIM ( character_expression )
LTRIM ( character_expression )

حذف فضای خالی از ابتدا یا انتهای رشته
*/

SELECT RTRIM(' str '), LEN(RTRIM(' str '));
SELECT LTRIM(' str '), LEN(LTRIM(' str '));
SELECT RTRIM(LTRIM(' str ')), LEN(RTRIM(LTRIM(' str ')));
GO
--------------------------------------------------------------------

/*
LEFT/RIGHT Function

LEFT ( character_expression , integer_expression ) 
RIGHT ( character_expression , integer_expression ) 

استخراج بخشی از یک رشته از سمت راست یا چپ آن رشته
*/

SELECT LEFT(N'علی رضا', 3);
SELECT RIGHT(N'علی رضا', 3);
SELECT LEFT('ABCD', 3);
SELECT LEFT(N'ABCD', 3);
SELECT RIGHT(N'ABCD', 3);
GO

-- SubString

SELECT REPLACE('my-string    is- simple!','-', '');
GO


-- محاسبه تعداد کاراکترهای الف در فیلد شهر جدول مشتریان
SELECT
	City,
	LEN(City) - LEN(REPLACE(City, N'ا','')) AS Num
FROM dbo.Customers


-- محاسبه تعداد کاراکترهای غیر الف در فیلد شهر جدول مشتریان
SELECT
	City,
	LEN(REPLACE(City, N'ا','')) AS Num
FROM dbo.Customers

-- Repeat stirng
SELECT REPLICATE('ABC ', 3);
GO

SELECT STUFF('6362141106033443', 5, 8,'********')

SELECT LEN('6362141106033443')

DECLARE @MyStr varchar (30)
SET @MyStr = 'SQL Server Management Studio'
SELECT STUFF(@MyStr, 1, LEN(@MyStr), 'SSMS');
GO