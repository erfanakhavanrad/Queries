use NikamoozDB
/*

Session 1

*/

--SELECT OrderID, CustomerID, EmployeeID, OrderDate
--FROM dbo.orders;
--Go

---- SELECT using Allias
--SELECT o.OrderID, o.CustomerID
--FROM dbo.Orders AS O


--DROP TABLE IF EXISTS [Order Details]
--Go

--CREATE TABLE dbo.[Order Details]
--(
--ID INT
--);
--GO

--SELECT * FROM [order details]


SELECT SCHEMA_NAME()
Go

SELECT * FROM sys.schemas
Go

DROP SCHEMA IF EXISTS myschema

CREATE SCHEMA MySchema
Go

SELECT SCHEMA_NAME() GO

SELECT * FROM sys.schemas

DROP TABLE IF EXISTS myschema.tbl1

CREATE TABLE myschema.tbl1
(
ID INT
);
GO

CREATE TABLE dbo.tbl1
(
ID INT
);
GO
SELECT * FROM INFORMATION_SCHEMA.TABLES

DROP TABLE IF EXISTS dbo.tbl1


INSERT INTO myschema.tbl1
VALUES (1), (2), (3), (4)


CREATE TABLE tbl1 (
ID INT
);
GO


INSERT INTO tbl1 VALUES (88), (55), (22), (11), (66)



SELECT * FROM myschema.tbl1
SELECT * FROM tbl1

DROP TABLE IF EXISTS myschema.tbl1, tbl1

-- 91 customers
SELECT * FROM customers

-- 830 orders
SELECT * FROM ORDERS

-- 9 employees
SELECT * FROM employees

SELECT o.OrderID, o.CustomerID, o.OrderDate
FROM dbo.orders AS o
	WHERE o.customerid = 71
Go

SELECT o.OrderID, o.CustomerID, o.OrderDate
FROM dbo.orders AS o
WHERE o.orderid IN (10248,10253,10320);
Go

SELECT o.OrderID, o.CustomerID, o.OrderDate
FROM dbo.orders AS o
WHERE o.orderid NOT IN (10248,10253,10320);
Go

SELECT o.OrderID, o.EmployeeID
From dbo.orders AS o
WHERE o.EmployeeID BETWEEN 3 AND 7;
Go


SELECT o.OrderID, o.EmployeeID
From dbo.orders AS o
WHERE o.EmployeeID IN (3,4,5,6,7);
Go

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE N'ا%'
GO

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName NOT LIKE N'ا%'
GO

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE N'[^ا]%'
GO


SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE N'%[ی]'
GO

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE N'%ی'
GO

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE  N'[ا ب پ]%'
GO

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE  N'[ا-پ]%'
GO

/*
SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.LastName LIKE  N'[ی-پ]%'
GO
*/

SELECT e.FirstName, e.LastName
FROM dbo.Employees AS e
WHERE e.FirstName LIKE N'س__'
GO

SELECT o.OrderID, o.EmployeeID, o.OrderDate
FROM dbo.orders AS o
WHERE o.OrderDate >= '20160430'
GO

SELECT 
o.OrderID, o.CustomerID, o.EmployeeID, o.OrderDate
FROM dbo.orders AS o
	WHERE
	(o.CustomerID = 1
	AND o.EmployeeID BETWEEN 1 AND 5)
		OR
	(o.CustomerID = 85
	AND o.EmployeeID BETWEEN 2 AND 6)
	Go


SELECT 1;
Go

SELECT 15/3;
GO

SELECT N'KOOFT';
GO


SELECT 
[OrderID], [CustomerID], [EmployeeID], [OrderDate], [ShipperID], [Freight]
FROM dbo.Orders
Go

SELECT
	o.EmployeeID, YEAR(o.OrderDate) AS OrderYear
FROM dbo.Orders AS o
GO


SELECT
	o.EmployeeID, OrderYear =YEAR(o.OrderDate) 
FROM dbo.Orders AS o
GO