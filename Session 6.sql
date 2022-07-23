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


SELECT
	FirstName,
	LastName 
FROM Employees



