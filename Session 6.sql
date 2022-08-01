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

SELECT
	c.CustomerID, c.CompanyName,
	o.OrderID, 
	SUM(od.Qty) AS quantity
FROM Customers AS c
JOIN Orders AS o
	on c.CustomerID = o.CustomerID
JOIN OrderDetails AS od
	on o.OrderID = od.OrderID
	WHERE c.State = N'تهران'
GROUP BY 	c.CustomerID, c.CompanyName,
	o.OrderID
GO

/*

تعداد سفارشات به همراه مجموع کل محصولات سفارش شده شرکت هایی که در تهران هستند

*/

SELECT
	c.CustomerID, c.CompanyName,
	SUM(od.Qty) AS quantity,
	COUNT (DISTINCT o.OrderID) AS numOrders
FROM Customers AS c
JOIN Orders AS o
	on c.CustomerID = o.CustomerID
JOIN OrderDetails AS od
	on o.OrderID = od.OrderID
	WHERE c.State = N'تهران'
GROUP BY c.CustomerID, c.CompanyName
GO

-- Outer Join
 /*
 تمامی مشتریانی که ثبت سفارش داشته اند
 */
 SELECT
	c.CustomerID, c.CompanyName, o.OrderID
 FROM Customers AS c
 JOIN Orders AS o
	ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID;
GO



  /*
 تمامی مشتریانی حتی ان هایی که  که ثبت سفارش نداشته اند
 */
SELECT
	c.CustomerID, c.CompanyName, o.OrderID
FROM Customers AS c
LEFT JOIN Orders AS o
	ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID;
GO



  /*
 تمامی مشتریانی  که  که ثبت سفارش نداشته اند
 */
SELECT
	c.CustomerID, c.CompanyName, o.OrderID
FROM Customers AS c
LEFT JOIN Orders AS o
	ON c.CustomerID = o.CustomerID
WHERE OrderID IS NULL
ORDER BY c.CustomerID;
GO

-- Forcing orders
--USE AdventureWorks

--SELECT * FROM Person.Person AS p
--JOIN Person.PersonPhone AS pp
--	ON p.BusinessEntityID = pp.BusinessEntityID
--JOIN Sales.SalesPerson AS sp
--	ON sp.BusinessEntityID = p.BusinessEntityID;
--GO

--SELECT * FROM Person.Person AS p
--JOIN Person.PersonPhone AS pp
--	ON p.BusinessEntityID = pp.BusinessEntityID
--JOIN Sales.SalesPerson AS sp
--	ON sp.BusinessEntityID = p.BusinessEntityID
--OPTION (FORCE ORDER);
--GO
-- Conclusion: don't force orders

/*

سفارش به همراه جزییات آن از تمام مشتریان حتی آن هایی که سفارش نداشته اند

*/



SELECT
	c.CustomerID, c.CompanyName,
	o.OrderID,
	od.ProductID, od.Qty
FROM customers AS c
LEFT JOIN Orders As o
	ON c.CustomerID = o.CustomerID
JOIN OrderDetails AS od
	ON od.OrderID = o.OrderID;
GO

SELECT
	c.CustomerID, c.CompanyName,
	o.OrderID,
	od.ProductID, od.Qty
FROM customers AS c
LEFT JOIN Orders As o
	ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails AS od
	ON od.OrderID = o.OrderID;
GO



/*
تمرین کلاسی شماره 7
.نمایش سفارش به‌همراه جزئیات آن از تمامی مشتریان حتی آن‌هایی که سفارش نداشته‌اند 

CustomerID   CompanyName   OrderID  ProductID   Qty  
----------   ------------  -------  ---------  ----- 
   1         شرکت IR- AA   10643      28        15   
   1         شرکت IR- AA   10643      39        21   
   ...		 			  		      		      
   22        شرکت IR- AV   NULL       NULL      NULL 
   ...		 			  		      		      
   57        شرکت IR- CE   NULL       NULL      NULL 
   ...		 			  		      		      
   91        شرکت IR- DM   10374      31        30   
   91        شرکت IR- DM   10374      58        15  

(2157 rows affected)

*/
SELECT
	C.CustomerID, C.CompanyName,
	O.OrderID,
	OD.ProductID, OD.Qty
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
LEFT JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID;
GO
--------------------------------------------------------------------

/*
در بهینه‌سازی کوئری Query Optimizer اجرایی و رفتار Plan بررسی
*/


-- .نمایش جزئیات سفارش مشتریانی که سفارش داشته‌اند
SELECT
	C.CustomerID,
	O.OrderID,
	OD.ProductID, OD.Qty
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID
ORDER BY C.CustomerID;
GO

SELECT
	C.CustomerID,
	O.OrderID,
	OD.ProductID,
	OD.Qty
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID
ORDER BY C.CustomerID;
GO
--------------------------------------------------------------------

-- نمایش جزئیات سفارش تمامی مشتریان حتی آن‌هایی که سفارش هم نداشته‌اند به 3 روش
SELECT 
	C.CustomerID,
	O.OrderID,
	OD.ProductID,
	OD.Qty
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
LEFT JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID;
GO

SELECT
	C.CustomerID,
	O.OrderID,
	OD.ProductID,
	OD.Qty
FROM dbo.Orders AS O
JOIN dbo.OrderDetails AS OD
	ON O.OrderID = OD.OrderID
RIGHT JOIN dbo.Customers AS C
		ON O.CustomerID = C.CustomerID;
GO

SELECT
	C.CustomerID,
	O.OrderID,
	OD.ProductID,
	OD.Qty
FROM dbo.Customers AS C
LEFT JOIN
	(dbo.Orders AS O
	 JOIN dbo.OrderDetails AS OD
		ON O.OrderID = OD.OrderID)
	ON C.CustomerID = O.CustomerID;
GO
--------------------------------------------------------------------

-- JOIN در COUNT بررسی رفتار
SELECT 
	C.CustomerID,
	COUNT(*) AS Num
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY C.CustomerID;
GO

SELECT 
	C.CustomerID,
	COUNT(OrderID) AS Num
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID
ORDER BY C.CustomerID;
GO
--------------------------------------------------------------------

/*
FULL [OUTER] JOIN
*/

DROP TABLE IF EXISTS dbo.Personnel, dbo.PersonnelTyp;
GO

CREATE TABLE dbo.Personnel
(
	ID INT IDENTITY,
	Family NVARCHAR(50),
	Typ NVARCHAR(20)
);
GO

CREATE TABLE dbo.PersonnelTyp
(
	ID INT IDENTITY,
	Title NVARCHAR(20)
);
GO

INSERT INTO dbo.Personnel
VALUES
	(N'احمدی',N'مدیر عامل'),
	(N'تقوی',N'سرپرست'),
	(N'سعادت',N'مدیر'),
	(N'جعفری',N'نامشخص');
GO

INSERT INTO dbo.PersonnelTyp
VALUES
	(N'مدیر عامل'),
	(N'مدیر'),
	(N'سرپرست'),
	(N'کارشناس'),
	(N'تکنسین');
GO

SELECT
	P.Family, PT.Title
FROM dbo.Personnel AS P
FULL OUTER JOIN dbo.PersonnelTyp AS PT
	ON P.Typ = PT.Title;
GO

SQL server behaviour with NULL in different JOIN
*/

CREATE TABLE J1
(
	ID INT
);
GO

CREATE TABLE J2
(
	ID INT,
	Title NVARCHAR(10)
);
GO


SELECT * FROM J1
SELECT * FROM J2

INSERT j1
VALUES
	(1),
	(2),
	(NULL),
	(NULL);
GO


INSERT j2
VALUES
	(1, 'One'),
	(2, 'Two'),
	(NULL, 'Three');
GO

-- Null is counted in CROSS JOIN
SELECT
	j1.ID, j2.Title
FROM j1
CROSS JOIN j2;
GO

-- Null gets preserved in JOIN: Nulls fall down because logic is accept true
SELECT
	j1.ID, j2.Title
FROM j1
JOIN j2
	ON j1.ID = j2.ID;
GO


SELECT
	j1.ID, j2.Title
FROM j1
LEFT JOIN j2
	ON j1.ID = j2.ID;
GO

