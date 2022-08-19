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

