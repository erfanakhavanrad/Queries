use SampleDb
use NikamoozDB
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

/*
لیستی شامل فهرست  شهرهایی که بیش از 50 سفارش ثبت کرده اند
*/
SELECT 
	COUNT(o.OrderID) AS Num,
	c.City
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
GROUP BY c.City
	HAVING COUNT(o.OrderID) > 50;
GO


/*
از کدام شهر کمترین سفارش را داشته ایم؟*/
SELECT 
	TOP (1) WITH TIES COUNT(o.OrderID) AS Num,
	c.City
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
	ON o.CustomerID = c.CustomerID
GROUP BY c.City
ORDER BY Num
GO



/*
سه محصولی که بیشترین فروش را داشته اند.
*/
select * from dbo.OrderDetails

-- Wrong
SELECT
TOP (3) WITH TIES SUM(o.Qty) AS quantity,
p.ProductName
FROM dbo.Products AS p
INNER JOIN dbo.OrderDetails AS o
	ON p.ProductID = o.ProductID
GROUP BY  p.ProductID, p.ProductName
ORDER BY quantity DESC;
GO

-- Correct
SELECT
TOP (3) WITH TIES SUM(o.Qty) AS quantity,
p.ProductName
FROM dbo.Products AS p
INNER JOIN dbo.OrderDetails AS o
	ON p.ProductID = o.ProductID
GROUP BY  p.ProductName
ORDER BY quantity DESC;
GO


-- Composite Join
DROP TABLE IF EXISTS composite1, composite2

CREATE TABLE Composite1 
(
	ID1 INT,
	ID2 INT,
	Family NVARCHAR(50)
);
GO


CREATE TABLE Composite2
(
	ID1 INT,
	ID2 INT,
	Serial INT IDENTITY,
	CheckedDate CHAR(10) DEFAULT GETDATE()
);
GO

INSERT INTO Composite1
VALUES
	(1,10, N'Ahmadi'), (1,20, N'Saadat'),
	(2,10, N'Paydar'), (2,20, N'Rezaei');
GO

INSERT INTO Composite2 (ID1, ID2)
VALUES
	(1,10), (1,10), (1,20), (1,20),
	(2,10), (1,10), (1,10), (2,10);
GO

SELECT * FROM Composite1
SELECT * FROM Composite2

SELECT
	c1.Family, c2.Serial
FROM Composite1 AS c1
JOIN Composite2 AS c2
	ON C1.ID1 = C2.ID1
	AND C1.ID2 = C2.ID2;
GO

SELECT
	c1.Family, c2.Serial
FROM Composite1 AS c1
JOIN Composite2 AS c2
	ON C1.ID1 = C2.ID1
GO


--Equi Join
SELECT
	e1.EmployeeID, e1.FirstName, e1.LastName,
	e2.EmployeeID, e2.FirstName, e2.LastName
 FROM Employees AS e1
 JOIN Employees AS e2
	ON e1.EmployeeID = e2.EmployeeID;
GO

--Non-Equi Join
SELECT
	e1.EmployeeID, e1.FirstName, e1.LastName,
	e2.EmployeeID, e2.FirstName, e2.LastName
 FROM Employees AS e1
 JOIN Employees AS e2
	ON e1.EmployeeID < e2.EmployeeID
ORDER BY e1.EmployeeID;
GO

/* Cross join with inner join removed

تمام ترکیبات دوتایی از نام و نام خانوادگی کارمندان به جز حالت تشابه میان یک کارمند با خودش

*/
SELECT
	e1.EmployeeID, e1.FirstName, e1.LastName,
	e2.EmployeeID, e2.FirstName, e2.LastName
 FROM Employees AS e1
 JOIN Employees AS e2
	ON e1.EmployeeID <> e2.EmployeeID
ORDER BY e1.EmployeeID;
GO

-- Mutli Join
/*
سفارش هر مشتری به عنوان شرکتش، کد سفارش، کد محصول و تعداد سفارش
*/

SELECT
	c.CustomerID, c.CompanyName,
	o.OrderID, 
	od.ProductID, od.Qty
FROM Customers AS c
JOIN Orders AS o
	on c.CustomerID = o.CustomerID
JOIN OrderDetails AS od
	on o.OrderID = od.OrderID;
GO


/*

تمامی سفارشات درخواست شده به همراه مجموع تمامی کالاهای هر سفارش که مربوط به شرکت هایی باشند که در استان تهران هستند.

*/
