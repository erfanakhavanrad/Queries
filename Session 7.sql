use SampleDb
use NikamoozDB
/*
Session 7
*/

-- Independent subquery in WHERE
/*
جدیدترین سفارش ثبت شده با استفاده از فیلتر TOP
*/
SELECT
	TOP 1 WITH TIES o.EmployeeID,
	o.CustomerID,
	o.OrderID,
	MAX(o.OrderDate) AS newOrders
FROM dbo.Orders AS o
GROUP BY o.EmployeeID,
	o.CustomerID,
	o.OrderID,
	o.OrderDate
ORDER BY o.OrderID DESC

/*
جدیدترین سفارش ثبت شده با استفاده از فیلتر OFFSET
*/
SELECT
	o.EmployeeID,
	o.CustomerID,
	o.OrderID,
	MAX(o.OrderDate) AS newOrders
FROM dbo.Orders AS o
GROUP BY o.EmployeeID,
	o.CustomerID,
	o.OrderID,
	o.OrderDate
ORDER BY o.OrderID DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
GO

-- جدیدترین سفارش ثبت شده با استفاده از متغییر
DECLARE @MaxID AS INT = (SELECT MAX(OrderID) FROM dbo.Orders)
SELECT
	o.EmployeeID,
	o.CustomerID,
	o.OrderID
FROM dbo.Orders AS o
	WHERE o.OrderID =  @MaxID;
GO

-- جدیدترین سفارش ثبت شده با استفاده از ساب کوئری مستقل
SELECT
	o.EmployeeID,
	o.CustomerID,
	o.OrderID
FROM dbo.Orders AS o
	WHERE o.OrderID =  (SELECT MAX(OrderID) FROM dbo.Orders);
GO

-- Independent subquery in SELECT
/*
	تعداد سفارش مشتریانی که سفارش داشته اند
*/
SELECT 
	CustomerID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CustomerID;
GO

/*
تعداد سفارش هر مشتری به همراه کل تعداد سفارش موجود
*/
SELECT 
	CustomerID,
	COUNT(OrderID) AS Num,
	830 AS AllOrders
FROM dbo.Orders
GROUP BY CustomerID;
GO


/*
WRONG!
تعداد سفارش هر مشتری به همراه کل تعداد سفارش موجود
*/
DECLARE @Num INT =  (SELECT COUNT(OrderID) FROM dbo.Orders)
SELECT 
	CustomerID,
	COUNT(OrderID) AS Num,
	@Num AS Total
FROM dbo.Orders
GROUP BY CustomerID;
GO

SELECT 
	CustomerID,
	COUNT(OrderID) AS Num,
(SELECT COUNT(OrderID) FROM dbo.Orders) AS Total
FROM dbo.Orders
GROUP BY CustomerID
GO
/*
تمرین کلاسی: علاوه بر تعداد سفارش ثبت شده توسط هر کا رمند، 
جدیدترین و قدیمیترین سفارش ثبت شده در میان تمامی سفارشات از تمامی کارمندان را نشان دهد
*/
-- نتیجه میان تمامی کارمندان
SELECT
	o.EmployeeID,
	COUNT(o.EmployeeID) AS OrderNumByEmployee,
	(SELECT MAX(OrderDate) FROM dbo.Orders) AS Latest,
	(SELECT MIN(OrderDate) FROM dbo.Orders) AS Oldest
FROM dbo.Orders As o
GROUP BY o.EmployeeID;
GO
-- نتیجه میان هر کارمند به صورت جدا
SELECT
	EmployeeID,
	COUNT(OrderID) AS NUM,
	MAX(OrderDate) AS MaxOrders,
	MIN(OrderDate) AS MinOrders
FROM dbo.Orders
GROUP BY EmployeeID;
GO
-- Self-Contained Single-valued subquery
/*
کارمندانی که نام خانوداگی انها با پ شروع میشود
*/
SELECT * FROM dbo.Employees
	WHERE lastname LIKE N'پ%';
GO


/*
تمامی سفارشات ثبت شده توسط کارمندانی که نام خانوداگی انها با پ شروع میشود
با استفاده از JOIN
*/
SELECT 
	e.EmployeeID, o.OrderID
FROM dbo.Employees AS e
JOIN dbo.orders AS o
	ON e.EmployeeID = o.EmployeeID
	WHERE lastname LIKE N'پ%';
GO

/*
تمامی سفارشات ثبت شده توسط کارمندانی که نام خانوداگی انها با پ شروع میشود
با استفاده از Subquery
*/
SELECT
	o.EmployeeID, o.OrderID
FROM dbo.Orders AS o
	WHERE o.EmployeeID =(SELECT EmployeeID FROM dbo.Employees WHERE lastname LIKE N'پ%');
GO


-- Self-Contained Multi-valued subquery
/*
کارمندانی که نام خانوداگی انها ب ت آغاز میشود.
*/
SELECT
	*
FROM dbo.Employees
	WHERE lastname LIKE N'ت%';
GO
/*
تمامی سفارشات ثبت شده توسط کارمندانی که نام خانوداگی انها با ت شروع میشود
با استفاده از Subquery
*/
SELECT
	o.EmployeeID, o.OrderID
FROM dbo.Orders AS o
	WHERE o.EmployeeID IN (SELECT EmployeeID FROM dbo.Employees WHERE lastname LIKE N'ت%');
GO

/*
نمایش تمامی مشتریان تهران و اصفهان
*/
SELECT
	CustomerID, City
FROM dbo.Customers
	WHERE City IN (N'تهران',N'اصفهان'); 
GO

/*
لیست مشتریانی که سفارش ثبت نکرده اند.
With JOIN
*/
SELECT
	c.*
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
	WHERE o.OrderID IS NULL;
GO
/*
شرط توی لفت جوین الکیه چون در اخر به خاطر جوین همه چیز رو میاره
*/
SELECT
	c.*
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
	AND o.OrderID IS NULL;
GO

/*
لیست مشتریانی که سفارش ثبت نکرده اند.
With Self-Contained Multi-Valued Subquery
*/

SELECT 
	*	
FROM dbo.customers
	WHERE CustomerID NOT IN (SELECT CustomerID FROM dbo.Orders);
GO
-- In this case, DISTINCT doesn't effect performance.
SELECT 
	*	
FROM dbo.customers
	WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM dbo.Orders);
GO

/*
مشاهده مشخصات تمامی شرکت هایی که فقط در تایخ
 2016-05-05 درخواست سفارش نداشته اند 
*/
SELECT
	c.CustomerID,
	c.CompanyName
FROM dbo.Customers AS c
	WHERE c.CustomerID NOT IN(SELECT customerID FROM dbo.Orders WHERE OrderDate  = '2016-05-05');
GO

SELECT
	c.CustomerID,
	c.CompanyName
FROM dbo.Customers AS c
	WHERE c.CustomerID NOT IN(SELECT customerID FROM dbo.Orders WHERE OrderDate  <> '2016-05-05');
GO

SELECT
	c.CustomerID,
	c.CompanyName
FROM dbo.Customers AS c
	WHERE c.CustomerID NOT IN (SELECT DISTINCT customerID FROM dbo.Orders WHERE OrderDate  <> '2016-05-05');
GO

SELECT
	c.CustomerID,
	c.CompanyName
FROM dbo.Customers AS c
	WHERE c.CustomerID  IN (SELECT DISTINCT customerID FROM dbo.Orders WHERE OrderDate  <> '2016-05-05');
GO

/*
رفتار
NULL
با گزاره
IN

نمایش تمامی مشتریانی که در منطقه مرکز واقع شده اند
*/
SELECT 
	*
FROM dbo.Customers 
	WHERE Region = N'مرکز';
GO

/*
	Show all customers where their Region is null
*/
-- WRONG
SELECT * FROM dbo.Customers WHERE Region IN (NULL)


-- RIGHT
SELECT * FROM dbo.Customers WHERE Region IS NULL


/*
رفتار
NULL
با گزاره
NOT IN

نمایش تمام مشتریانی که مقدار فیلد
REGION
آنها برابر با نال یا مرکز نباشد
*/
-- WRONG
SELECT	
	*
FROM dbo.Customers
	WHERE Region NOT IN (N'مرکز', NULL)
ORDER BY Region DESC;
GO

SELECT	
	*
FROM dbo.Customers
	WHERE Region <>N'مرکز'
	AND Region IS NOT NULL
ORDER BY Region DESC;
GO

/*
نمایش تمامی مشتریانی که مقدار فیلد ریجن آنها برابر با مرکز یا غرب نباشد
*/
SELECT
	*
FROM dbo.Customers
	WHERE Region NOT IN (N'غرب',N'مرکز')
ORDER BY Region;
GO

/*
مشخصات شرکت هایی که کد سفارشات انها فرد یا اصلا درخواست سفارش نداشته اند
*/
SELECT
	CustomerID, CompanyName
FROM dbo.Customers
	WHERE CustomerID IN (SELECT CustomerID from dbo.Orders WHERE OrderID % 2 = 0)
GO

-- CORRELATED SUBQUERIES
/*
نمایش جدیدترین کد سفارش هر مشتری
*/
SELECT
	CustomerID,
	MAX(OrderID) AS newestOrder
FROM dbo.Orders
GROUP BY CustomerID;
GO

/*
عدم امکان نوشتن کوئری قبلی باز استفاده از انواع
Self contained valued
*/
SELECT 
	CustomerID,
	(SELECT MAX(OrderID) FROM dbo.Orders) 
FROM dbo.Orders

SELECT 
	CustomerID,
	OrderID 
FROM dbo.Orders
	WHERE OrderID = (SELECT MAX (OrderID) FROM dbo.Orders);
GO

/*
نمایش جدیدترین کد سفارش هر مشتری با
Correlated subquery
*/
SELECT
	DISTINCT o1.CustomerID,
	(SELECT MAX (o2.OrderID) FROM dbo.Orders AS o2
		WHERE o2.CustomerID = o1.CustomerID) AS [new Order]
FROM dbo.Orders AS o1;
GO

SELECT
	o1.CustomerID,
	(SELECT MAX (o2.OrderID) FROM dbo.Orders AS o2
		WHERE o2.CustomerID = o1.CustomerID) AS [new Order]
FROM dbo.Orders AS o1
GROUP BY o1.CustomerID
GO

SELECT
	c.CustomerID,
	(SELECT MAX(OrderID) FROM dbo.Orders AS o
		WHERE o.CustomerID = c.CustomerID) AS newOrder
FROM dbo.Customers AS c;
GO

--------------------------------------------------------------------

/*
Query1
WHERE در بخش Correlated Subquery نمایش جدیدترین کدسفارش هر مشتری با استفاده از
*/
SELECT
	O1.CustomerID, O1.OrderID
FROM dbo.Orders AS O1
	WHERE O1.OrderID = (SELECT MAX(O2.OrderID) FROM dbo.Orders AS O2
							WHERE O2.CustomerID = O1.CustomerID);
GO

/*
Query2
Correlated Subquery روشی ساده‌تر برای نمایش جدیدترین سفارش هر مشتری بدون استفاده از
*/
SELECT
	CustomerID, 
	MAX(OrderID) AS NewOrder
FROM dbo.Orders
GROUP BY CustomerID;
GO

/*
بدون درنظر گرفتن ایندکس جداول Query2 و Query1 مقایسه میان کوئری‌های
*/
--Query1
SELECT
	O1.CustomerID, O1.OrderID
FROM dbo.Orders AS O1
	WHERE O1.OrderID = (SELECT MAX(O2.OrderID) FROM dbo.Orders AS O2
							WHERE O1.CustomerID = O2.CustomerID);
GO

--Query2
SELECT
	CustomerID, 
	MAX(OrderID) AS NewOrder
FROM dbo.Orders
GROUP BY CustomerID;
GO

/*
با درنظر گرفتن ایندکس جداول Query2 و Query1 مقایسه میان کوئری‌های
*/
-- Query1
SELECT
	O1.CustomerID,
	O1.OrderID
FROM Sales.Orders AS O1
	WHERE O1.OrderID = (SELECT MAX(O2.OrderID) FROM Sales.Orders AS O2
							WHERE O2.CustomerID = O1.CustomerID);
GO

-- Query2
SELECT
	CustomerID, 
	MAX(OrderID) AS NewOrder
FROM Sales.Orders
GROUP BY CustomerID;
GO
--------------------------------------------------------------------

/*
Performance علاقه‌مندان
*/

USE AdventureWorks2017;
GO

SELECT * FROM Sales.SalesOrderHeader;
GO

SELECT
	SalesPersonID,
	MAX(OrderDate) AS NewOrder
FROM Sales.SalesOrderHeader
	WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID;
GO

SELECT
	SalesPersonID,
	OrderDate
FROM Sales.SalesOrderHeader AS SOH1
	WHERE SOH1.SalesOrderID = (SELECT MAX(SOH2.SalesOrderID) FROM Sales.SalesOrderHeader AS SOH2 
									WHERE SOH1.SalesPersonID = SOH2.SalesPersonID);
GO
--------------------------------------------------------------------

USE NikamoozDB;
GO

/*
تمرین کلاسی شماره 4

.نمایش تعداد سفارش همه شرکت‌ها حتی آن‌هایی که سفارش نداشته‌اند 

CustomerID   CompanyName    Num
----------   ------------   ---
   1         شرکت IR- AA    6
   2         شرکت IR- AB    4
   3         شرکت IR- AC    7
   ...	  			   
   89        شرکت IR- DK    14
   90        شرکت IR- DL    7
   91        شرکت IR- DM    7

(91 rows affected)

*/

-- JOIN
SELECT
	C.CustomerID, C.CompanyName,
	COUNT(O.OrderID) AS Num
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.CompanyName;
GO

-- Correlated Subquery
SELECT
	C.CustomerID,
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی شماره 5

.نمایش تاریخ جدیدترین سفارش هر شرکت حتی فاقد سفارش‌ها‌

CustomerID   CompanyName            NewOrder
----------   ------------    -----------------------
   1         شرکت IR- AA     2016-04-09 00:00:00.000
   2         شرکت IR- AB     2016-03-04 00:00:00.000
   3         شرکت IR- AC     2016-01-28 00:00:00.000
   ...		 			    
   89        شرکت IR- DK     2016-05-01 00:00:00.000
   90        شرکت IR- DL     2016-04-07 00:00:00.000
   91        شرکت IR- DM     2016-04-23 00:00:00.000

(91 rows affected)

*/

--  JOIN
SELECT
	C.CustomerID,
	C.CompanyName,
	MAX(O.OrderDate) AS NewOrder
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.CompanyName;
GO

-- SELECT در بخش Correlated Subquery با استفاده از
SELECT
	C.CustomerID,
	C.CompanyName,
	(SELECT MAX(O.OrderDate) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS NewOrder
FROM dbo.Customers AS C;
GO

-- WHERE در بخش Correlated Subquery با استفاده از
SELECT
	C.CustomerID,
	C.CompanyName,
	O1.OrderDate
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O1
	ON C.CustomerID = O1.CustomerID
	WHERE O1.OrderDate = (SELECT MAX(O2.OrderDate) FROM dbo.Orders AS O2
							WHERE O2.CustomerID = O1.CustomerID)
	OR O1.OrderDate IS NULL
GROUP BY C.CustomerID, C.CompanyName, O1.OrderDate;
GO

SELECT * FROM dbo.Orders
	WHERE EXISTS (SELECT * FROM dbo.Customers WHERE city = N'تهران');
GO


SELECT * FROM dbo.Orders
	WHERE EXISTS (SELECT 1 FROM dbo.Customers WHERE city = N'تهران');
GO