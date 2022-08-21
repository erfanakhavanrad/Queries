use SampleDb
use NikamoozDB
/*
Session 8
*/

-- INTERSECT
SELECT state, Region, City FROM dbo.Employees
INTERSECT
SELECT state, Region, City FROM dbo.Customers
GO

/*
شبیه سازی اشتراک با استفاده از جوین
*/
SELECT
	DISTINCT e.State, e.Region, e.City
FROM dbo.Employees AS e
JOIN dbo.Customers AS c
	ON e.State  = c.State
	AND e.Region = c.Region
	AND e.City = c.City;
GO

SELECT
	e.State, e.Region, e.City
FROM dbo.Employees AS e
JOIN dbo.Customers AS c
	ON e.State  = c.State
	AND e.Region = c.Region
	AND e.City = c.City
GROUP BY e.State, e.Region, e.City
GO

-- Except
SELECT state, Region, City FROM dbo.Employees
EXCEPT
SELECT state, Region, City FROM dbo.Customers
GO

SELECT state, Region, City FROM dbo.Customers
EXCEPT
SELECT state, Region, City FROM dbo.Employees
GO

-- Set Operators Priority
/* 1-Intersect 2- UNION/EXCEPT */

SELECT state, Region, City FROM dbo.Suppliers
EXCEPT 
SELECT state, Region, City FROM dbo.Employees
INTERSECT
SELECT state, Region, City FROM dbo.Customers;
GO



/*
Exersice 01
.فهرست شرکت‌هایی که بیش از 10 سفارش درخواست داشته‌اند
*/

/*
JOIN
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CompanyName, C.CustomerID
	HAVING COUNT(O.OrderID) > 10;
GO


/*
Subquery (WHERE)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE (SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
			WHERE O.CustomerID = C.CustomerID) > 10;
GO


/*
Subquery (WHERE)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE C.CustomerID = (SELECT O.CustomerID FROM dbo.Orders AS O
							WHERE O.CustomerID = C.CustomerID
						  GROUP BY O.CustomerID
							HAVING COUNT(O.OrderID) > 10);
GO


/*
Subquery (EXISTS)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					HAVING COUNT(O.OrderID) > 10);
GO


/*
Subquery (IN)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE C.CustomerID IN (SELECT O.CustomerID FROM dbo.Orders AS O
						   GROUP BY O.CustomerID
							HAVING COUNT(O.OrderID) > 10);
GO


/*
Subquery (SELECT)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName,
	(SELECT O.CustomerID FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID
	 GROUP BY O.CustomerID
		HAVING COUNT(O.OrderID) > 10) AS CustomerID
FROM dbo.Customers AS C;
GO


/*
Subquery (SELECT)

Outer Query: Orders
Subquery: Customers
*/
SELECT
	(SELECT C.CompanyName FROM dbo.Customers AS C
		WHERE C.CustomerID = O.CustomerID) AS CompanyName,
	O.CustomerID
FROM dbo.Orders AS O
GROUP BY O.CustomerID
	HAVING COUNT(O.OrderID) > 10;
GO
--------------------------------------------------------------------

/*
Exersice 02
.تعداد سفارش شرکت‌هایی که در استان زنجان واقع شده‌اند
*/

/*
JOIN
*/
SELECT
	C.CompanyName,
	COUNT(O.OrderID) AS Num
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
	WHERE C.State = N'زنجان'
GROUP BY C.CompanyName;
GO


/*
Subquery (SELECT)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C
	WHERE C.State = N'زنجان';
GO


-- ???
SELECT
	C.CompanyName,
	(SELECT COUNT(*) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C
	WHERE C.State = N'زنجان';
GO

-- ???
SELECT
	C.CompanyName, 
	(SELECT COUNT(OrderID) FROM dbo.Orders AS O 
		WHERE O.CustomerID = C.CustomerID
		AND C.State = N'زنجان') AS Num
FROM dbo.Customers AS C;
GO


/*
Subquery (SELECT)

Outer Query: Orders
Subquery: Customers
*/
SELECT
	(SELECT C.CompanyName FROM dbo.Customers AS C
		WHERE C.State = N'زنجان'
		AND C.CustomerID = O.CustomerID) AS CompanyName,
	COUNT(O.OrderID) AS Num
FROM dbo.Orders AS O
GROUP BY O.CustomerID;
GO
--------------------------------------------------------------------

/*
Exersice 03
.محصولاتی که قیمت واحد آن‌ها از میانگین قیمت واحد تمامی محصولات بیشتر و یا با آن برابر باشد
*/

-- میانگین قیمت واحد تمامی محصولات
SELECT AVG(UnitPrice) FROM dbo.Products;
GO

-- ???
SELECT
	ProductID, UnitPrice
FROM dbo.Products
GROUP BY ProductID
	HAVING UnitPrice >= AVG(UnitPrice);
GO

-- ???
SELECT
	ProductID, UnitPrice
FROM dbo.Products
GROUP BY ProductID, UnitPrice
	HAVING UnitPrice >= AVG(UnitPrice);
GO

-- Subquery (WHERE)
SELECT
	ProductID, UnitPrice
FROM dbo.Products AS P
	WHERE P.UnitPrice >= (SELECT AVG(UnitPrice) FROM dbo.Products);
GO


-- Subquery (IN)
SELECT
	ProductID, UnitPrice
FROM dbo.Products AS P
	WHERE P.ProductID IN (SELECT ProductID FROM dbo.Products AS P
							WHERE P.UnitPrice >= (SELECT AVG(UnitPrice) FROM dbo.Products));
GO


-- Subquery (EXISTS)
SELECT
	ProductID, UnitPrice
FROM dbo.Products AS P
	WHERE EXISTS (SELECT 1 FROM dbo.Products AS P1
					WHERE P1.UnitPrice >= (SELECT AVG(UnitPrice) FROM dbo.Products)
					AND P1.ProductID = P.ProductID);
GO

--------------------------------------------------------------------

/*
Exersice 04
.مشخصات کارمندی که تا به امروز کمترین تعداد ثبتِ سفارش را داشته است
*/

-- تعداد سفارشات ثبت‌شده توسط هر کارمند
SELECT
	EmployeeID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY EmployeeID;
GO

-- .کارمندانی که کمترین ثبت‌سفارش داشته‌اند
SELECT
	TOP (1) WITH TIES EmployeeID,
	COUNT(OrderID) AS Num
FROM dbo.Orders
GROUP BY EmployeeID
ORDER BY Num;
GO

-- JOIN
SELECT
	TOP (1) WITH TIES E.EmployeeID,
	E.FirstName,
	E.LastName
FROM dbo.Orders AS O
JOIN dbo.Employees AS E
	ON E.EmployeeID = O.EmployeeID
GROUP BY E.EmployeeID, E.FirstName, E.LastName
ORDER BY COUNT(O.OrderID);
GO


/*
Subquery (IN)

Outer Query: Employees
Subquery: Orders
*/
SELECT
	E.EmployeeID , E.FirstName, E.LastName
FROM dbo.Employees AS E
	WHERE E.EmployeeID IN (SELECT TOP (1) WITH TIES O.EmployeeID FROM dbo.Orders AS O
						   GROUP BY O.EmployeeID
						   ORDER BY COUNT(O.OrderID));
GO


/*
Subquery (WHERE)

Outer Query: Employees
Subquery: Orders

روش خطرناک
*/
SELECT
	EmployeeID, FirstName, LastName
FROM dbo.Employees
	WHERE EmployeeID = (SELECT
							TOP (1) WITH TIES EmployeeID 
						FROM dbo.Orders
						GROUP BY EmployeeID
						ORDER BY COUNT(OrderID));
GO


/*
Subquery (SELECT)

Outer Query: Orders
Subquery: Employees
*/
SELECT
	TOP (1) WITH TIES O.EmployeeID,
	(SELECT E.FirstName FROM dbo.Employees AS E
		WHERE E.EmployeeID = O.EmployeeID) AS FirstName,
	(SELECT E.LastName FROM dbo.Employees AS E
		WHERE E.EmployeeID = O.EmployeeID) AS LastName
FROM dbo.Orders AS O
GROUP BY O.EmployeeID
ORDER BY COUNT(O.OrderID);
GO


/*
Subquery (SELECT)

Outer Query: Employees
Subquery: Orders
*/
SELECT
	TOP (1) WITH TIES E.EmployeeID, E.FirstName, E.LastName,
	(SELECT COUNT(OrderID) FROM dbo.Orders AS O
		WHERE E.EmployeeID = O.EmployeeID) AS Num 
FROM dbo.Employees AS E
ORDER BY Num;
GO

SELECT
	TOP (1) WITH TIES E.EmployeeID, E.FirstName, E.LastName
FROM dbo.Employees AS E
ORDER BY (SELECT COUNT(OrderID) FROM dbo.Orders AS O
			WHERE E.EmployeeID = O.EmployeeID);
GO



/*
Exersice 01
مشخصات شرکت‌هایی که حداقل در یکی از ماه‌های سال 2015 سفارش داشته‌اند
.اما در سال 2016 هنوز درخواست سفارشی نداشته‌اند
*/

/*
EXISTS

.همه مشتریانی که در سال 2015 ثبت‌سفارش داشته‌اند
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2015);
GO

/*
EXISTS

.همه مشتریانی که در سال 2016 ثبت‌سفارش داشته‌اند
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2016);
GO

/*
Set Operator های تنبل و استفاده از Developer رفتار
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2015)

EXCEPT

SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2016);
GO

/*
Subquery (EXISTS)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2015)
	AND NOT EXISTS(SELECT 1 FROM dbo.Orders AS O
					WHERE O.CustomerID = C.CustomerID
					AND YEAR(O.OrderDate) = 2016);
GO


/*
Subquery (IN)

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.CompanyName, C.CustomerID
FROM dbo.Customers AS C
	WHERE C.CustomerID IN (SELECT O.CustomerID FROM dbo.Orders AS O
							WHERE YEAR(O.OrderDate) = 2015)
	AND C.CustomerID NOT IN (SELECT O.CustomerID FROM dbo.Orders AS O
								WHERE YEAR(O.OrderDate) = 2016);
GO
--------------------------------------------------------------------
/*
Exersice 02

.هستند A نمایش رکوردهایی که فقط در جدول

ID
--
1
3
4

(3 row(s) affected)

*/

DROP TABLE IF EXISTS A,B;
GO

CREATE TABLE A
(
	ID TINYINT
);
GO

CREATE TABLE B
(
	ID TINYINT
);
GO

INSERT INTO A
	VALUES (1),(2),(3),(4);
GO

INSERT INTO B
	VALUES (2),(NULL);
GO 


-- JOIN
SELECT
	A.ID
FROM A
JOIN B
	ON A.ID <> B.ID;
GO
	

-- Subquery (EXISTS)
SELECT
	A.ID
FROM A
	WHERE EXISTS (SELECT 1 FROM B
					WHERE B.ID <> A.ID);
GO

-- Subquery (NOT EXISTS)
SELECT
	A.ID
FROM A
	WHERE NOT EXISTS (SELECT 1 FROM B
						WHERE B.ID = A.ID);
GO

-- Subquery (NOT IN) Without Checking
SELECT
	A.ID
FROM A
	WHERE A.ID NOT IN (SELECT ID FROM B);
GO

-- Subquery (NOT IN) With Checking
SELECT
	A.ID
FROM A
	WHERE A.ID NOT IN (SELECT ID FROM B
						WHERE B.ID IS NOT NULL);
GO

-- Subquery (NOT IN) With Checking
SELECT
	A.ID
FROM A
	WHERE A.ID NOT IN (SELECT ISNULL(ID, '') FROM B);
GO

-- Subquery (NOT IN - Correlated)
SELECT
	A.ID
FROM A
	WHERE A.ID NOT IN (SELECT ID FROM B
						WHERE B.ID = A.ID);
GO


/*
Exersice 03
*/

SELECT
	DISTINCT C.CustomerID
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID
	WHERE O.OrderDate >= '20160505'
	AND OD.UnitPrice > 20;
GO

SELECT
	C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
				  JOIN dbo.OrderDetails AS OD
					ON OD.OrderID = O.OrderID
					WHERE  O.CustomerID = C.CustomerID
					AND OD.UnitPrice > 20
					AND O.OrderDate >= '20160505');
GO

/*
:تفسیر کوئری بالا

تمامی مشتریانی که از تاریخ 20160505 به‌بعد در فاکتور
.درخواستی‌شان کالاهایی با قیمت بیش از 20 را سفارش داده‌اند

*/

-- ???
SELECT
	C.CustomerID
FROM dbo.Customers AS C
	WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O
				  JOIN dbo.OrderDetails AS OD
					ON OD.OrderID = O.OrderID
					--WHERE  O.CustomerID = C.CustomerID
					AND OD.UnitPrice > 20
					AND O.OrderDate >= '20160505');
GO
--------------------------------------------------------------------

/*
Exersice 04

.فهرست شهرها و تعداد مشتریان شهرهایی که از مشتریان شهر سمنان بیشتر هستند

Num   City
---   ------
اصفهان     7
تهران    14
شیراز     6

(3 rows affected)

*/

-- تعداد مشتریان از شهر سمنان
SELECT
	City,
	COUNT(City) AS Num
FROM dbo.Customers
	WHERE City = N'سمنان'
GROUP BY City;
GO

-- تعداد مشتران از تمامی شهرها به‌جز سمنان
SELECT
	City,
	COUNT(City) AS Num
FROM dbo.Customers
	WHERE City <> N'سمنان'
GROUP BY City
ORDER BY Num DESC;
GO

-- Subquery (HAVING)
SELECT
	City,
	COUNT(City) AS Num
FROM dbo.Customers
GROUP BY City
	HAVING COUNT(City) > (SELECT COUNT(City) AS Num FROM dbo.Customers
							WHERE City = N'سمنان');
GO
--------------------------------------------------------------------

/*
Exersice 05

EmployeeID
-----------
    1
    6

(2 row(s) affected)

*/

-- .کارمندانی که با مشتری شماره 1 ثبت سفارش داشته‌اند
SELECT EmployeeID FROM dbo.Orders 
	WHERE CustomerID = 1
ORDER BY EmployeeID;
GO

-- .کارمندانی که با مشتری شماره 2 ثبت سفارش داشته‌اند
SELECT EmployeeID FROM dbo.Orders 
	WHERE CustomerID = 2
ORDER BY EmployeeID;
GO

/*
Set Operator های تنبل و استفاده از Developer رفتار
*/

SELECT EmployeeID FROM dbo.Orders 
	WHERE CustomerID = 1

EXCEPT

SELECT EmployeeID FROM dbo.Orders 
	WHERE CustomerID = 2;
GO

-- Subquery(IN)
SELECT
	 DISTINCT EmployeeID 
FROM dbo.Orders
	WHERE EmployeeID NOT IN (SELECT EmployeeID FROM dbo.Orders 
								WHERE CustomerID = 2)
	AND CustomerID = 1;
GO

-- Subquery(EXISTS)
SELECT
	DISTINCT EmployeeID 
FROM dbo.Orders AS O1
	WHERE NOT EXISTS(SELECT EmployeeID FROM dbo.Orders AS O2 
						WHERE O2.EmployeeID = O1.EmployeeID 
						AND O2.CustomerID = 2)
	AND CustomerID = 1;
GO

-- EXISTS (رویال برگر با قارچ و پنیر)
SELECT 
	EmployeeID 
FROM dbo.Employees AS O1
	WHERE NOT EXISTS(SELECT EmployeeID FROM dbo.Orders AS O2 
						WHERE O1.EmployeeID = O2.EmployeeID 
						AND CustomerID = 2)
	AND EXISTS(SELECT EmployeeID FROM dbo.Orders AS O2 
				WHERE O1.EmployeeID = O2.EmployeeID 
				AND CustomerID = 1);
GO