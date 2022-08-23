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
-- SUBQUERY
SELECT
	o.OrderID
FROM dbo.Orders AS o
WHERE o.OrderID = (SELECT od.OrderID FROM dbo.OrderDetails AS od
		WHERE od.Qty > 5
		AND od.OrderID = o.OrderID)

-- Derived Table

-- Part 1.2 14Min