use SampleDb

/*
Session 6
*/


-- CROSS JOIN
SELECT 
	CustomerID,
	EmployeeID
FROM dbo.Customers
CROSS JOIN dbo.Employees;
GO

SELECT
c.CustomerID, o.EmployeeID
FROM dbo.Customers AS c
CROSS JOIN dbo.Orders AS o;
GO

SELECT * FROM Customers
SELECT * FROM Orders

SELECT
	CustomerID, EmployeeID
FROM dbo.Customers
CROSS JOIN dbo.Employees
	WHERE CustomerID > 90;
GO

-- SELF JOIN

SELECT * from Employees

-- Issues with self join
-- Self pairs:	 Tim Brown	Tim Brown
-- Mirrored pairs:	 Tim Brown Adele Kreg	Adele Kreg	Tim Brown
SELECT
	e1.FirstName,
	e1.LastName,
	e2.FirstName,
	e2.LastName 
FROM Employees AS e1
CROSS JOIN Employees AS e2;
GO

-- Inner Join

SELECT
	e.FirstName, e.LastName,
	o.OrderID
FROM dbo.Employees AS e
INNER JOIN dbo.Orders AS o
	ON o.EmployeeID  = e.EmployeeID;
GO

SELECT * FROM dbo.Orders
SELECT * FROM dbo.Employees

SELECT
	e.FirstName, e.LastName,
	o.OrderID
FROM dbo.Employees AS e
INNER JOIN dbo.Orders AS o
	ON o.EmployeeID  = e.EmployeeID
	WHERE e.LastName NOT LIKE N'[ا]%'
ORDER BY e.LastName;
GO


SELECT
	e.FirstName, e.LastName,
	o.OrderID
FROM dbo.Employees AS e
INNER JOIN dbo.Orders AS o
	ON o.EmployeeID  = e.EmployeeID
	WHERE e.LastName LIKE N'[ب-ی]%'
ORDER BY e.LastName;
GO


SELECT
	e.FirstName, e.LastName,
	o.OrderID
FROM dbo.Employees AS e
INNER JOIN dbo.Orders AS o
	ON o.EmployeeID  = e.EmployeeID
	WHERE e.LastName LIKE N'[^ا]%'
ORDER BY e.LastName;
GO

SELECT 
	COUNT(o.OrderID) AS Num,
	c.City
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
GROUP BY c.City
	HAVING COUNT(o.OrderID) > 50;
GO


SELECT 
	TOP (1) WITH TIES COUNT(o.OrderID) AS Num,
	c.City
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY Num
GO
