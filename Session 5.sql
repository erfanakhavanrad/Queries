use NikamoozDB
/*
Session 5
*/

DROP TABLE IF EXISTS grouptable
GO

CREATE TABLE groupTable 
(
Score INT
);
GO

INSERT INTO groupTable
	VALUES (2), (3), (4), (10);
GO

SELECT
	COUNT(score) AS Num,
	SUM(score) AS Total,
	MAX(score) AS MaxVal,
	MIN(score) AS MinVal,
	AVg(score * 1.0) AS Average
FROM dbo.groupTable;
GO

INSERT INTO groupTable VALUES (null);
GO

SELECT
score,
	COUNT (score) AS score
FROM dbo.groupTable
	GROUP BY score

SELECT
	*,
	COUNT (*) AS [score with star]
FROM dbo.groupTable
	GROUP BY score



SELECT
	COUNT (score) AS score
FROM dbo.groupTable

SELECT
	COUNT (*) AS [score with star]
FROM dbo.groupTable


SELECT 
EmployeeID, CustomerID
FROM dbo.Orders
	ORDER BY customerID
GO

SELECT 
	DISTINCT EmployeeID, CustomerID
FROM dbo.Orders
	ORDER BY customerID
GO


SELECT 
	DISTINCT EmployeeID, CustomerID
FROM dbo.Orders
GO

SELECT 
	 EmployeeID, CustomerID
FROM dbo.Orders
	GROUP BY EmployeeID, CustomerID
GO

SELECT 
	 EmployeeID, CustomerID
FROM dbo.Orders
	GROUP BY EmployeeID --,CustomerID
GO

SELECT 
	  EmployeeID
FROM dbo.Orders
	GROUP BY EmployeeID ,CustomerID
GO


SELECT 
	  EmployeeID
FROM dbo.Orders
	GROUP BY EmployeeID ,CustomerID
	ORDER BY OrderID
GO

SELECT 
	  EmployeeID
FROM dbo.Orders
	GROUP BY EmployeeID ,CustomerID, OrderID
	ORDER BY OrderID
GO

SELECT
DISTINCT CustomerID, OrderID
FROM dbo.Orders
ORDER BY CustomerID;
GO

-- تعداد سفارش هر مشتری
-- Group By columns: CustomerID
-- Aggregate columns: OrderId
SELECT
	CustomerID,
	COUNT(OrderID) AS Number 
FROM dbo.Orders
	GROUP BY CustomerID;
GO

-- تعداد سفارش هر مشتری و جدیدترین سفارش
-- Group By columns: CustomerID
-- Aggregate columns: OrderId / OrderDate
SELECT
	CustomerID,
	COUNT(OrderID) AS Number,
	MAX (OrderDate) AS NewestOrder
FROM dbo.Orders
	GROUP BY CustomerID;
GO

-- از هر استان شهر چه تعداد مشتری داریم؟
-- Group By columns: State / City
-- Aggregate columns: CustomerID

SELECT
	state, city,
	COUNT(CustomerID) AS CustomerCount
FROM dbo.Customers
	GROUP BY state,city;
GO

CREATE TABLE #T1 (Code INT);
GO

INSERT #T1 VALUES (1), (2),(3), (NULL),(NULL)

INSERT INTO #T1 VALUES (4), (5),(6), (NULL),(NULL)

SELECT Code FROM #T1 GROUP BY Code



/*تمرین کلاسی
سفارشات هر کارمند به تفکیک هر سال که شامل تعداد کل سفارش و مجموع کرایه‌های ثبت شده

EmployeeID   OrderYear   Num     Rate	    
----------   ----------  ----  -------- 
  1            2014       26    1871.04  
  1            2015       55    4584.47  
  1            2016       42    2381.13  
  ...			  		  		  		    
  9            2014       5     532.84   
  9            2015       19    1046.09  
  9            2016       19    1747.33  

*/
--(Freight)
--27 records as input

-- Group By columns: EmployeeID / 
-- Aggregate columns:

SELECT
EmployeeID,
YEAR(OrderDate) AS OrderYear,
	COUNT(OrderID) AS AllOrders,
	SUM(Freight) AS Rate
FROM dbo.Orders
	GROUP BY EmployeeID,
YEAR(OrderDate)
GO


 -- Count of all employee orders except the ones from employee number 9

 SELECT
	o.EmployeeID,
	COUNT(o.OrderID) AS Num
 FROM dbo.Orders AS o
WHERE o.EmployeeID <> 9
 GROUP BY o.EmployeeID;
 GO

 /*

 HERE

 */

 -- 5 customers with most orders 

 SELECT TOP (5) With TIES
	o.CustomerID,
	COUNT(o.OrderID) AS ordersNum
 FROM dbo.Orders AS o
  GROUP BY o.CustomerID
  order by ordersNum DESC
GO
	

-- A field can be used in WHERE but be absent in SELECT
SELECT
	EmployeeID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
	WHERE CustomerID < 50
GROUP BY EmployeeID;
Go

-- A field can be used in HAVING but be absent in SELECT

SELECT
	EmployeeID,
	CustomerID
FROM dbo.Orders
GROUP BY EmployeeID, CustomerID
	HAVING COUNT(OrderID) > 5;
GO

-- A field can have 2 roles simultaneously

SELECT
	c.City,
	COUNT(c.City) AS Num
FROM dbo.Customers AS c
GROUP BY c.City;
GO

SELECT
	COUNT(City) AS CityName
FROM dbo.Customers
	WHERE City IN (N'تهران', N'اصفهان')
GO


SELECT
	customerID,
	COUNT(City) AS CityName
FROM dbo.Customers
	WHERE City IN (N'تهران', N'اصفهان')
GROUP BY customerID
GO


SELECT
	c.CustomerID
FROM dbo.Customers AS c
GROUP BY c.CustomerID
	HAVING COUNT(c.State) > 0;
GO
SELECT * FROM customers
ORDER BY STATE

 -- Show the fileds filtered in WHERE

SELECT
	EmployeeID,
	COUNT(OrderID) AS Num
 FROM dbo.orders
	WHERE EmployeeID BETWEEN 1 AND 3
GROUP BY ALL EmployeeID
ORDER BY EmployeeID;
GO


SELECT
	EmployeeID,
	COUNT(OrderID) AS Num
 FROM dbo.orders
	WHERE EmployeeID BETWEEN 1 AND 3
GROUP BY ALL EmployeeID
	HAVING COUNT(OrderID) > 100
ORDER BY EmployeeID;
GO

