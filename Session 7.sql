﻿use SampleDb
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
