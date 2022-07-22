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

-- All customer with more than 20 orders

 SELECT * From dbo.Orders
 SELECT * From dbo.Customers

 SELECT
	CustomerID,
	COUNT(OrderID) AS Num
 FROm dbo.Orders
 GROUP BY CustomerID
	HAVING COUNT(OrderID) > 20;
GO

-- More than 70 orders and orders not by employee 8

SELECT 
OrderID
FROM dbo.Orders
	WHERE EmployeeID <> 9
GROUP BY OrderID
	HAVING COUNT(orderID) > 70;

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


/*
Roll up (A, B, C)
(A, B, C)
(A, B)
(A)
()
*/

SELECT
	CustomerID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CustomerID;
GO

SELECT
	CustomerID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CustomerID WITH  ROLLUP;
GO

-- Best practice for above query (Write rollup after GROUP BY)

SELECT
	CustomerID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY ROLLUP (CustomerID);
GO


-- Shoiwng customers and their order count and total sum for groups

--TIP: In GROUP BY queries all columnss in select should be in the GROUP BY section except aggregate functions.
SELECT
	EmployeeID,
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) OrderMonth,
	COUNT(OrderID) AS Num
FROM dbo.Orders
	WHERE EmployeeID IN (1,2)
GROUP BY ROLLUP (EmployeeID,YEAR(OrderDate),MONTH(OrderDate));
GO

SELECT
	CustomerID,
	COUNT(OrderID) AS Num,
	GROUPING (CustomerID) AS GroupingCustomerID
FROM dbo.Orders
GROUP BY ROLLUP (CustomerID);
GO

SELECT
	EmployeeID,
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	COUNT(OrderID) AS Num,
	GROUPING (EmployeeID) AS GROUPING_EMPLOYEEID,
	GROUPING (YEAR(OrderDate)) AS GROUPING_YEAR,
	GROUPING (MONTH(OrderDate)) AS GROUPING_MONTH
FROM dbo.Orders
GROUP BY ROLLUP (EmployeeID,YEAR(OrderDate),MONTH(OrderDate))

/*
Cube is 2 to the power of N
CUBE (A, B, C)
(A, B, C)
(A, B)
(A, C)
(B, C)
(A)
(B)
(C)
()
*/


SELECT
CustomerID,
COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CustomerID WITH CUBE;
GO


SELECT
CustomerID,
COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY CUBE (CustomerID);
GO

SELECT
	EmployeeID,
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) OrderMonth,
	COUNT(OrderID) AS Num
FROM dbo.Orders
	WHERE EmployeeID IN (1,2)
GROUP BY CUBE (EmployeeID,YEAR(OrderDate),MONTH(OrderDate))
ORDER BY EmployeeID;
Go


SELECT
	CustomerID,
	COUNT(OrderID) AS Num,
	GROUPING (CustomerID) AS GroupingCustomerID
FROM dbo.Orders
GROUP BY CUBE (CustomerID);
GO

SELECT
	EmployeeID,
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	COUNT(OrderID) AS Num,
	GROUPING (EmployeeID) AS GROUPING_EMPLOYEEID,
	GROUPING (YEAR(OrderDate)) AS GROUPING_YEAR,
	GROUPING (MONTH(OrderDate)) AS GROUPING_MONTH
FROM dbo.Orders
GROUP BY CUBE (EmployeeID,YEAR(OrderDate),MONTH(OrderDate))


-- GROUPING SET
-- TIP: All SELECT fields should  be in GROUPING SETS in some way, except AGGREGATE COLUMNS.
SELECT
	EmployeeID, 
	CustomerID,
	YEAR(OrderDate) AS OrderYear,
	COUNT(OrderID) AS Num
FROM dbo.Orders
	WHERE CustomerID = 1 OR CustomerID = 2
GROUP BY GROUPING SETS 
	(
		(EmployeeID, CustomerID),
		(EmployeeID, YEAR(OrderDate)),
		(CustomerID, YEAR(OrderDate)),
		()
	);
GO

SELECT
	EmployeeID, 
	CustomerID,
	YEAR(OrderDate) AS OrderYear,
	COUNT(OrderID) AS Num
FROM dbo.Orders
	WHERE CustomerID = 1 OR CustomerID = 2
GROUP BY GROUPING SETS 
	(
		(EmployeeID, CustomerID),
		(EmployeeID, YEAR(OrderDate)),
		(CustomerID, YEAR(OrderDate)),
		()
	)
ORDER BY 
	CASE
		WHEN YEAR(OrderDate) IS NULL THEN 1
		WHEN EmployeeID IS NULL THEN 2
		WHEN CustomerID IS NULL THEN 3
	END;
GO

/*
 GROUPING_ID
 Begins with
 2^0 from right which means 1
 2^1 = 2
 2^2 = 4
 it means the equal field isn't counted.
In	CASE GROUPING_ID(EmployeeID,CustomerID, YEAR(OrderDate)) 
  2^0 = 1 is  YEAR(OrderDate) which means  YEAR(OrderDate) isn't calculated so you can use the name 'customer and employee'
  2^1 = 2 is  CustomerID which means  CustomerID isn't calculated so you can use the name 'employee and orderDate'
  2^2 = 4 is  EmployeeID which means  EmployeeID isn't calculated so you can use the name 'customer and orderDate'

 */
SELECT
	EmployeeID, 
	CustomerID,
	YEAR(OrderDate) AS OrderYear,
	GROUPING_ID(EmployeeID,CustomerID, YEAR(OrderDate)) AS GROUPING_ID_FIELD 
FROM dbo.Orders
	WHERE CustomerID = 1 OR CustomerID = 2
GROUP BY GROUPING SETS 
	(
		(EmployeeID, CustomerID),
		(EmployeeID, YEAR(OrderDate)),
		(CustomerID, YEAR(OrderDate)))
GO


SELECT
	EmployeeID, 
	CustomerID,
	YEAR(OrderDate) AS OrderYear,
	COUNT(orderid)AS Num,
	CASE GROUPING_ID(EmployeeID,CustomerID, YEAR(OrderDate)) 
		WHEN 4 THEN N'Customer and year'
		WHEN 2 THEN N'Employee and year'
		WHEN 1 THEN N'Employee and customer'
	END AS N'Grouping base on'
FROM dbo.Orders
	WHERE CustomerID = 1 OR CustomerID = 2
GROUP BY GROUPING SETS 
	(
		(EmployeeID, CustomerID),
		(EmployeeID, YEAR(OrderDate)),
		(CustomerID, YEAR(OrderDate)));
GO
