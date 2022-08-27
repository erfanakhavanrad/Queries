use SampleDb
use NikamoozDB
/*
Session 9
*/

/*
JOIN
.شرکت‌هایی که بیش از 10 سفارش داشته‌اند
*/
SELECT
	C.CompanyName,
	COUNT(O.OrderID) AS Num
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CompanyName
	HAVING COUNT(O.OrderID) > 10;
GO

/*
WHERE در بخش Subquery نوشتن کوئری بالا با استفاده از

کوئری بیرونی SELECT به‌دلیل این‌که در بخش
قرار است از هر دو جدول فیلدی خوانده شود
.کوئری بیرونی نوشت WHERE را در بخش Subquery پس نمی‌توان
توجه داشته باشید که می‌خواهیم این کوئری صرفا
.نوشته شود Subquery با یک
*/

/*
SELECT در بخش Subquery استفاده از

:در این‌جا می‌توان با 2 استراتژی به‌ استقبال مساله رفت

1) Subquery ارسال بخشی از رکوردها به
2) Subquery ارسال تمامی رکوردها به
*/

/*
استراتژی 1

Outer Query: Orders
Subquery: Customers

.شرکت‌هایی که بیش از 10 سفارش داشته‌اند
*/
SELECT
	(SELECT C.CompanyName FROM dbo.Customers AS C
		WHERE C.CustomerID = O.CustomerID) AS CompanyName,
	COUNT(O.OrderID) AS Num
FROM dbo.Orders AS O
GROUP BY O.CustomerID
	HAVING COUNT(O.OrderID) > 10;
GO

/*
استراتژی 2

Outer Query: Customers
Subquery: Orders

.شرکت‌هایی که بیش از 10 سفارش داشته‌اند
*/
SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
		HAVING COUNT(O.OrderID) > 10)
FROM dbo.Customers AS C;
GO


-- از استراتژی 2 WHERE در بخش Subquery عدم استفاده از نتایج
SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
		HAVING COUNT(O.OrderID) > 10) AS Num
FROM dbo.Customers AS C
	WHERE Num IS NOT NULL;
GO

-- رفع مشکل استراتژی 2
-- Subquery ایراد، تکرار
SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C
	WHERE (SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
			WHERE O.CustomerID = C.CustomerID) > 10;
GO
--------------------------------------------------------------------

/*
Derived Table
*/

-- Derived Table رفع مشکل استراتژی 2 با استفاده از 
SELECT Tmp.CompanyName, Tmp.Num FROM
(SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
		HAVING COUNT(O.OrderID) > 10) AS Num
 FROM dbo.Customers AS C) AS Tmp
	WHERE Tmp.Num IS NOT NULL;
GO

-- Derived Table رفع مشکل استراتژی 2 با استفاده از 
SELECT Tmp.* FROM
(SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C) AS Tmp
	WHERE TMP.Num > 10;
GO
--------------------------------------------------------------------

/*
Table Expression بررسی الزامات سه‌گانه در تمامی انواع
*/

/*
1) ORDER BY
Derrive Table در ORDER BY عدم استفاده از
*/

SELECT * FROM 
	(SELECT 
		CustOmerID, CompanyName
	 FROM dbo.Customers
		WHERE State = N'تهران'
	 ORDER BY CustomerID) AS Tmp;  -- .زیرا ماهیت نتایج در مدل رابطه‌ای، عدم تضمین مرتب سازی است
GO

/*
2) Assign Name
.می‌بایست دارای نام باشند Derived Table تمامی فیلدهای
*/

SELECT * FROM
	(SELECT
		CustomerID, CompanyName + N'- تهران' --AS CompName
	 FROM dbo.Customers
		WHERE State = N'تهران') AS Tmp;
GO

/*
3) Unique Column Name
.می‌بایست دارای نام منحصر به‌فرد باشند Derived Table تمامی فیلدهای
*/

SELECT * FROM
	(SELECT
		C.CustomerID, O.CustomerID --AS O_CustomerID
	 FROM dbo.Orders AS O
	 JOIN dbo.Customers AS C
		ON C.CustomerID = O.CustomerID) AS Tmp;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی

کوئری‌ای بنویسید که مشخص کند کدام مشتری 
در هر فاکتور بیش از 5 مورد کالا سفارش داده است؟

CustomerID   Num
-----------  ---
   20         6
   65         25
   71         6

(3 rows affected)

JOIN / Subquery / Derived Table
*/

-- JOIN
SELECT
	DISTINCT o.CustomerID,
	COUNT(od.orderid) AS num
	-- MY solution COUNT(od.Qty) AS num
FROM dbo.Orders AS o
JOIN dbo.OrderDetails AS od
	ON o.OrderID = od.OrderID
	GROUP BY  o.CustomerID, o.OrderID
	HAVING COUNT(od.Qty) > 5;
GO

/*
Subquery استراتژی ارسال بخشی از رکوردها به

Outer Query: OrderDetails
Subquery: Orders
*/
SELECT
	 DISTINCT (SELECT O.CustomerID FROM dbo.Orders AS O
				WHERE O.OrderID = OD.OrderID) AS CustomerID,
	COUNT(OD.OrderID) AS Num
FROM dbo.OrderDetails AS OD
GROUP BY OD.OrderID
	HAVING COUNT(OD.OrderID) > 5;
GO


/*
Subquery استراتژی ارسال تمامی رکوردها به

Outer Query: Orders
Subquery: OrderDetails
*/
SELECT
	O.CustomerID,
	(SELECT COUNT(OD.OrderID) FROM dbo.OrderDetails AS OD
		WHERE OD.OrderID = O.OrderID
		HAVING COUNT(OD.OrderID) > 5) AS Num
FROM dbo.Orders AS O;
GO

-- Derived Table (الغریق یتشبث بالحشیش)
SELECT DISTINCT * FROM
(
	SELECT
	O.CustomerID,
	(SELECT COUNT(OD.OrderID) FROM dbo.OrderDetails AS OD
		WHERE OD.OrderID = O.OrderID
		HAVING COUNT(OD.OrderID) > 5) AS Num
	FROM dbo.Orders AS O
) AS Tmp
	WHERE Tmp.Num IS NOT NULL;
GO

-- Derived Table (هوشمندانه)
SELECT DISTINCT * FROM
(
	SELECT
	O.CustomerID,
	(SELECT COUNT(OD.OrderID) FROM dbo.OrderDetails AS OD
		WHERE OD.OrderID = O.OrderID) AS Num
	FROM dbo.Orders AS O
) AS Tmp
	WHERE Tmp.Num > 5;
GO

-- AdventureWorks2017 تاثیر کوئری‌هایی مشابه با کوئری‌های بالا در دیتابیس بزرگتری با عنوان
USE AdventureWorks2017;
GO

SELECT * FROM SALES.SalesOrderDetail; -- 121317 Records
SELECT * FROM SALES.SalesOrderHeader; -- 31465 Records
GO

-- Derived Table (الغریق یتشبث بالحشیش)
SELECT DISTINCT * FROM
(
	SELECT
	SOH.CustomerID,
	(SELECT COUNT(SOD.SalesOrderID) FROM Sales.SalesOrderDetail AS SOD
		WHERE SOH.SalesOrderID = SOD.SalesOrderID
		HAVING COUNT(SOD.SalesOrderID) > 5) AS Num
FROM Sales.SalesOrderHeader AS SOH) AS Tmp
	WHERE TMP.Num IS NOT NULL;
GO

-- Derived Table (هوشمندانه)
SELECT DISTINCT * FROM
(
	SELECT
	SOH.CustomerID,
	(SELECT COUNT(SOD.SalesOrderID) FROM Sales.SalesOrderDetail AS SOD
		WHERE SOH.SalesOrderID = SOD.SalesOrderID) AS Num
FROM Sales.SalesOrderHeader AS SOH) AS Tmp
	WHERE TMP.Num > 5;
GO

USE NikamoozDB;
GO

-- ???
SELECT
	O.CustomerID,
	COUNT(O.OrderID) AS Num
FROM dbo.Orders AS O
	WHERE EXISTS (SELECT 1 FROM dbo.OrderDetails AS OD
					WHERE OD.OrderID = O.OrderID
					HAVING COUNT(OD.OrderID) > 5)
GROUP BY O.CustomerID;
GO
--------------------------------------------------------------------

/*
نکات تکمیلی
*/

-- تعداد مشتریان به‌تفکیک هر سال
SELECT
	YEAR(O.OrderDate) AS OrderYear,
	COUNT(DISTINCT O.CustomerID) AS Num
FROM dbo.Orders AS O -- .در کوئری‌های پیچیده نگهداری از نسخه‌های مختلف از اسامی مستعار، موجب عدم خوانایی و حتی گاهی خطا می‌شود
GROUP BY YEAR(OrderDate);
GO

-- Derived Table کوئری بالا با استفاده از
SELECT
	Tmp.OrderYear,
	COUNT(DISTINCT Tmp.CustomerID) AS Num
FROM
	(SELECT
		YEAR(OrderDate) AS OrderYear,
		CustomerID 
	 FROM dbo.Orders) AS Tmp
GROUP BY Tmp.OrderYear; 
GO

-- تو در تو Derived Table
SELECT
	DT2.OrderYear,
	DT2.Cust_Num
FROM (SELECT
		DT1.OrderYear,
		COUNT(DISTINCT DT1.CustomerID) AS Cust_Num
	  FROM (SELECT
				YEAR(OrderDate) AS OrderYear,
				CustomerID
			FROM dbo.Orders) AS DT1
			GROUP BY OrderYear) AS DT2;
GO


/*
CTE Non-Recursive:

WITH <CTE_Name> [(<Column_List>)]
AS
(
	<Inner_Query_Defining_CTE> -- باید دارای الزامات سه گانه باشد
)
<Outer_Query_Against_CTE>;
*/

-- Derived Table فهرست کد و نام شرکت مشتریان تهرانی با استفاده از
SELECT
	TC.CompanyName
FROM (SELECT
		C.CustomerID, C.CompanyName
	  FROM dbo.Customers AS C
		WHERE C.City = N'تهران') AS TC;
GO

-- Derived Table عدم استفاده مجدد از
SELECT
	TC.CompanyName
FROM (SELECT
		C.CustomerID, C.CompanyName
	  FROM dbo.Customers AS C
		WHERE C.City = N'تهران') AS TC
JOIN TC AS TC2
	ON TC.CustomerID = TC2.CustomerID; -- غلط است
GO


-- Derived Table نمونه‌سازی مجدد با استفاده از
SELECT
	TC1.CompanyName
FROM (SELECT
		C.CustomerID, C.CompanyName
	  FROM dbo.Customers AS C
		WHERE C.City = N'تهران') AS TC1
JOIN (SELECT
		C.CustomerID, C.CompanyName
	  FROM dbo.Customers AS C
		WHERE C.City = N'تهران') AS TC2
	ON TC1.CustomerID = TC2.CustomerID;
GO

-- CTE فهرست کد و نام شرکت مشتریان تهرانی با استفاده از
WITH Tehran_Customers
AS
(
	SELECT
		C.CustomerID, C.CompanyName
	FROM dbo.Customers AS C
)
SELECT * FROM Tehran_Customers;
GO


-- در بخش کوئری بیرونی CTE استفاده مجدد از کوئری درونی
WITH Tehran_Customers
AS
(
	SELECT
		C.CustomerID, C.CompanyName
	FROM dbo.Customers AS C
)
SELECT * FROM Tehran_Customers AS TC1
JOIN Tehran_Customers AS TC2
	ON TC1.CustomerID = TC2.CustomerID;
GO


GO

-- CTE تعیین نام ستون‌های خروجی
WITH Tehran_Customers (Col1,Col2) 
AS
(
	SELECT
		CustomerID ,CompanyName
	FROM Customers AS C
		WHERE C.City = N'تهران'
)
SELECT
	T.Col1, T.Col2 -- !می‌توان استفاده کرد WITH فقط از نام‌های تعریف‌شده در جلو
FROM Tehran_Customers AS T;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی

در هر سال چه تعداد مشتری داشته‌ایم؟
!انجام شود CTE عملیات محاسبه تعداد مشتری و گروه‌بندی سال‌ها در کوئری بیرونی

OrderYear   Customers_Num
---------   -------------
  2014          67
  2015          86
  2016          81

(3 rows affected)

*/

WITH Cust_Num
AS
(
	SELECT
		YEAR(OrderDate) AS OrderYear,
		CustomerID
	FROM dbo.Orders
)
SELECT
	OrderYear,
	COUNT(DISTINCT CustomerID) AS Customers_Num
FROM Cust_Num
GROUP BY OrderYear;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی فرد‌افکن

فهرست تعداد مشتریان هر سال و سال قبل از آن و بررسی
.میزان افزایش یا کاهش تعداد مشتری نسبت به سال قبل

.انجام شود CTE محاسبه تعداد مشتریان در بخش کوئری درونی

OrderYear  Cust_Num  Previous_Cust_Num   Growth
---------  --------  ------------------  ------
  2014        67           0              67
  2015        86           67             19
  2016        81           86             -5

(3 rows affected)

. انجام دهید CTE و JOIN تمرین را به دو روش‌

*/

-- تعداد مشتریان به‌ازای هر سال
SELECT
	YEAR(O1.OrderDate) AS OrderYear,
	COUNT(DISTINCT O1.CustomerID) AS Cust_Num
FROM dbo.Orders AS O1
GROUP BY YEAR(O1.OrderDate);
GO

SELECT
	YEAR(O1.OrderDate) AS OrderYear,
	COUNT(DISTINCT O1.CustomerID) AS Cust_Num,
	YEAR(O2.OrderDate) AS OrderYear,
	COUNT(DISTINCT O2.CustomerID) AS Cust_Num
FROM dbo.Orders AS O1
JOIN dbo.Orders AS O2
	ON YEAR(O1.OrderDate) = YEAR(O2.OrderDate)
GROUP BY YEAR(O1.OrderDate), YEAR(O2.OrderDate);
GO

-- ON کوئری بالا با تغییر در بخش
SELECT
	YEAR(O1.OrderDate) AS OrderYear,
	COUNT(DISTINCT O1.CustomerID) AS Cust_Num,
	YEAR(O2.OrderDate) AS OrderYear,
	COUNT(DISTINCT O2.CustomerID) AS Cust_Num
FROM dbo.Orders AS O1
LEFT JOIN dbo.Orders AS O2
	ON YEAR(O1.OrderDate) = YEAR(O2.OrderDate) + 1
GROUP BY YEAR(O1.OrderDate), YEAR(O2.OrderDate);
GO

-- JOIN حل تمرین با استفاده از
SELECT
	YEAR(O1.OrderDate) AS OrderYear,
	COUNT(DISTINCT O1.CustomerID) AS Cust_Num,
	COUNT(DISTINCT O2.CustomerID) AS Previous_Cust_Num,
	COUNT(DISTINCT O1.CustomerID) - COUNT(DISTINCT O2.CustomerID) AS Growth
FROM dbo.Orders AS O1
LEFT JOIN dbo.Orders AS O2
	ON YEAR(O1.OrderDate) = YEAR(O2.OrderDate) + 1
GROUP BY YEAR(O1.OrderDate), YEAR(O2.OrderDate);
GO

-- CTE حل تمرین با استفاده از
WITH Customers_Per_Year
AS
(
	SELECT
		YEAR(O1.OrderDate) AS OrderYear,
		COUNT(DISTINCT O1.CustomerID) AS Cust_Num
	FROM dbo.Orders AS O1
	GROUP BY YEAR(O1.OrderDate)
)
SELECT
	C.OrderYear,
	C.Cust_Num AS Cust_Num,
	ISNULL(P.Cust_Num, 0) AS Previous_Cust_Num,
	C.Cust_Num - ISNULL(P.Cust_Num, 0) AS Growth
FROM Customers_Per_Year AS C
LEFT JOIN Customers_Per_Year AS P
	ON C.OrderYear = P.OrderYear + 1;
GO

-- Derived Table حل تمرین با استفاده از
SELECT
	Current_Year.OrderYear,
	Current_Year.Cust_Num AS Cust_Num,
	ISNULL(Previous_Year.Cust_Num, 0) AS Previous_Cust_Num,
	Current_Year.Cust_Num - ISNULL(Previous_Year.Cust_Num, 0) AS Growth
FROM (SELECT
		YEAR(OrderDate) AS OrderYear,
		COUNT(DISTINCT CustomerID) AS Cust_Num
	  FROM dbo.Orders
	  GROUP BY YEAR(OrderDate)) AS Current_Year -- Derived Table اولین
	  LEFT JOIN (SELECT 
					YEAR(OrderDate) AS OrderYear,
					COUNT(DISTINCT CustomerID) AS Cust_Num 
				 FROM dbo.Orders 
			     GROUP BY YEAR(OrderDate)) AS Previous_Year -- اول Derived Table تکرار مجدد
		ON Current_Year.OrderYear = Previous_Year.OrderYear + 1;
GO

-- Subquery حل تمرین با استفاده از
SELECT
	YEAR(Current_Year.OrderDate) AS OrderYear,
	COUNT(DISTINCT Current_Year.CustomerID) AS Cust_Num,
	ISNULL((SELECT COUNT(DISTINCT O.CustomerID) FROM dbo.Orders AS O
				WHERE YEAR(Current_Year.OrderDate) = YEAR(O.OrderDate) + 1
			GROUP BY YEAR(O.OrderDate)), 0) AS Previous_Cust_Num,
	COUNT(DISTINCT Current_Year.CustomerID) -
	ISNULL((SELECT COUNT(DISTINCT O.CustomerID) FROM dbo.Orders AS O
				WHERE YEAR(Current_Year.OrderDate) = YEAR(O.OrderDate) + 1
			GROUP BY YEAR(O.OrderDate)), 0) AS Growth
FROM dbo.Orders AS Current_Year
GROUP BY YEAR(Current_Year.OrderDate);
GO
--------------------------------------------------------------------

/*
تودرتو CTE

WITH <CTE_Name1> [(<column_list>)]
AS
(
	<inner_query_defining_CTE>
),
	<CTE_Name2> [(<column_list>)]
AS
(
	<inner_query_defining_CTE>
)
	<outer_query_against_CTE>;
*/

-- تودرتو CTE حل تمرین فردافکن با استفاده از
WITH Current_Year
AS
(
	SELECT
		YEAR(OrderDate) AS OrderYear,
		COUNT(DISTINCT CustomerID) AS Cust_Num
	FROM dbo.Orders AS O
	GROUP BY YEAR(OrderDate)
),
Previous_Year
AS
(
	SELECT
		YEAR(OrderDate) AS OrderYear,
		COUNT(DISTINCT CustomerID) AS Cust_Num
	FROM dbo.Orders AS O
	GROUP BY YEAR(OrderDate)
)
SELECT
	Current_Year.OrderYear,
	Current_Year.Cust_Num,
	ISNULL(Previous_Year.OrderYear,0) AS Previous_Cust_Num,
	Current_Year.Cust_Num - ISNULL(Previous_Year.Cust_Num,0) AS Growth
FROM Current_Year
LEFT JOIN Previous_Year
	ON Current_Year.OrderYear = Previous_Year.OrderYear + 1;
GO

/*
نکته مهم
به‌صورت تو در تو ،‌CTE پس از تعریف چندین
استفاده از آن‌‌ها در چندین دستور جداگانه
.امکان‌پذیر نیست CTE در کوئری بیرونی
.های غیر تو در تو هم برقرار است‌CTE این موضوع در مورد
*/

DROP TABLE IF EXISTS digits

CREATE TABLE digits
(
	Num TINYINT
);
GO

INSERT INTO dbo.digits
	VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);
GO


SELECT * FROM dbo.digits AS a
CROSS JOIN dbo.digits AS b
 