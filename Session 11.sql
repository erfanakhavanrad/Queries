use SampleDb
use NikamoozDB
/*
Session 11
*/

--------------------------------------------------------------------
			/*		Questions 01 حل تمرین فایل		*/
--------------------------------------------------------------------

USE NikamoozDB;
GO

/*
Exersice 01
مجموع تمامی تعداد سفارشات مشتریان شهرهای تهران، شیراز و اصفهان
*/

/*
Subquery

Outer Query: Orders
Subquery: Customers
*/
SELECT
	(SELECT C.City FROM dbo.Customers AS C
		WHERE C.CustomerID = O.CustomerID
		AND C.City IN (N'تهران', N'اصفهان', N'شیراز')) AS City,
	COUNT(O.OrderID) AS Num
FROM dbo.Orders AS O
GROUP BY O.CustomerID;
GO

/*
Subquery

Outer Query: Customers
Subquery: Orders
*/
SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C
	WHERE C.City IN (N'تهران', N'اصفهان', N'شیراز')
GROUP BY C.City; -- , C.CustomerID
GO


-- اصلاح روش بالا
SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE EXISTS(SELECT 1 FROM dbo.Customers AS C1
						WHERE C1.CustomerID = O.CustomerID
						AND C1.City = C.City)) AS Num
FROM dbo.Customers AS C
	WHERE C.City IN (N'تهران', N'اصفهان', N'شیراز')
GROUP BY C.City; 
GO


-- Derived Table
SELECT
	Tmp.City,
	SUM(Tmp.Num) AS Num
FROM
(
SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C
	WHERE C.City IN (N'تهران', N'اصفهان', N'شیراز')
) AS Tmp
GROUP BY Tmp.City;
GO


-- CTE
WITH CTE
AS
(
	SELECT
		C.City,
		(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
			WHERE O.CustomerID = C.CustomerID) AS Num
	FROM dbo.Customers AS C
		WHERE C.City IN (N'تهران', N'اصفهان', N'شیراز')
)
SELECT
	CTE.City,
	SUM(CTE.Num) AS Num
FROM CTE
GROUP BY CTE.City;
GO

-- JOIN
SELECT
	C.City,
	COUNT(O.OrderID) AS Num
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
WHERE C.City IN (N'تهران', N'اصفهان', N'شیراز')
GROUP BY C.City;
GO
--------------------------------------------------------------------

/*
Exersice 02
کوئری زیر علاوه بر نمایش تعداد سفارشات و جدیدترین سفارش هر کارمند
.همین اطلاعات را در همان سطر و به‌ازای رئیس‌اش نیز انجام می‌دهد
*/

SELECT
	E.EmployeeID, OE.NumOrders, OE.MaxDate
	,OM.Employeeid, OM.NumOrders, OM.MaxDate
FROM dbo.Employees AS E
JOIN
(SELECT
	EmployeeID, COUNT(*) AS NumOrders, MAX(OrderDate) AS MaxDate
 FROM dbo.Orders
 GROUP BY EmployeeID) AS OE
	ON E.EmployeeID = OE.EmployeeID
LEFT JOIN
(SELECT
	EmployeeID, COUNT(*) AS NumOrders, MAX(OrderDate) AS MaxDate
 FROM dbo.Orders
 GROUP BY EmployeeID) AS OM
	ON E.mgrid = OM.EmployeeID;
GO

/*
CTE بازنویسی با
*/
WITH Emp_Cnt_Max
AS
(
	SELECT
		EmployeeID,
		COUNT(*) AS NumOrders,
		MAX(OrderDate) AS MaxDate
	FROM dbo.Orders
	GROUP BY EmployeeID
)
SELECT
	ECM1.EmployeeID, ECM1.NumOrders, ECM1.MaxDate,
	ECM2.EmployeeID, ECM2.NumOrders, ECM2.MaxDate
FROM Emp_Cnt_Max AS ECM1
JOIN dbo.Employees AS E
	ON E.EmployeeID = ECM1.EmployeeID
LEFT JOIN Emp_Cnt_Max AS ECM2
	ON E.mgrid = ECM2.EmployeeID;
GO

/*
CTE بازنویسی با
*/
WITH Emp_Cnt_Max
AS
(
	SELECT
		O.EmployeeID,
		COUNT(O.OrderID) AS NumOrders,
		MAX(O.OrderDate) AS MaxDate,
		(SELECT E.mgrid FROM dbo.Employees AS E
			WHERE E.EmployeeID = O.EmployeeID) AS mgrid
	FROM dbo.Orders AS O
	GROUP BY O.EmployeeID
)
SELECT
	ECM1.EmployeeID, ECM1.NumOrders, ECM1.MaxDate,
	ECM2.EmployeeID, ECM2.NumOrders, ECM2.MaxDate
FROM Emp_Cnt_Max AS ECM1
LEFT JOIN Emp_Cnt_Max AS ECM2
	ON ECM1.mgrid = ECM2.EmployeeID;
GO
--------------------------------------------------------------------

/*
Exersice 03
.مشخصات کارمند شماره 9 و نفراتی که به‌لحاظ ساختار سازمانی بالاتر از او هستند
*/
WITH CTE
AS
(
	SELECT
		EmployeeID, mgrid, FirstName, LastName
	FROM dbo.Employees
		WHERE EmployeeID = 9
	UNION ALL
	SELECT
		E.EmployeeID, E.mgrid, E.FirstName, E.LastName
	FROM dbo.Employees AS E
	JOIN CTE
		ON E.EmployeeID = CTE.mgrid
)
SELECT * FROM CTE;
GO


/*
Exersice 01
نمایش سطح هر کارمند در ساختار سلسه مراتبی
*/

WITH Employees_CTE
AS
(
	SELECT
		EmployeeID, Mgrid, Firstname, Lastname, 1 AS Employee_Level
	FROM dbo.Employees
		WHERE EmployeeID = 2 -- Anchor_Member

	UNION ALL

	SELECT
		E.EmployeeID, E.Mgrid, E.Firstname, E.Lastname, Emp_CTE.Employee_Level + 1
	FROM Employees_CTE AS Emp_CTE
	JOIN dbo.Employees AS E
		ON E.Mgrid = Emp_CTE.EmployeeID -- Recursive_Member
)
SELECT
	EmployeeID, Mgrid, Firstname, Lastname, Employee_Level
FROM Employees_CTE;
GO
--------------------------------------------------------------------

/*
Exersice 02
VIEW تعداد کالای ثبتِ‌سفارش شده توسط هر کارمند در هر سال با استفاده از
مجموع تعداد کالاهای ثبت شده در هر سال VIEW و در ادامه با استفاده از
.با مجموع سال‌های قبلی همان کارمند محاسبه شود
*/

--------------------------------
	/* VIEW With JOIN */
--------------------------------
DROP VIEW IF EXISTS dbo.VJ_Employee_Orders;
GO

-- VIEW ایجاد
CREATE VIEW dbo.VJ_Employee_Orders
AS
	SELECT
		O.EmployeeID,
		YEAR(O.OrderDate) AS OrderYear,
		SUM(OD.Qty) AS Qty
	FROM dbo.Orders AS O
	JOIN dbo.OrderDetails AS OD
		ON O.OrderID = OD.OrderID
GROUP BY O.EmployeeID, YEAR(O.OrderDate);
GO

-- VIEW فراخوانی
SELECT * FROM dbo.VJ_Employee_Orders
ORDER BY EmployeeID;
GO

-- جهت نمایش تعداد سفارشات هر سال و سال‌های ماقبل آن VIEW فراخوانی
SELECT
	VJ1.EmployeeID, VJ1.OrderYear, VJ1.Qty,
	SUM(VJ2.Qty) AS Total
FROM dbo.VJ_Employee_Orders AS VJ1
JOIN dbo.VJ_Employee_Orders AS VJ2
	ON VJ1.OrderYear >= VJ2.OrderYear
	AND VJ1.EmployeeID = VJ2.EmployeeID
GROUP BY VJ1.EmployeeID, VJ1.OrderYear, VJ1.Qty
ORDER BY VJ1.EmployeeID;
GO

-- ???
SELECT
	V1.EmployeeID, V1.OrderYear, V1.Qty,
	SUM(V1.Qty) AS Total
FROM dbo.VJ_Employee_Orders AS V1
JOIN dbo.VJ_Employee_Orders AS V2
	ON V1.OrderYear >= V2.OrderYear
	AND V1.EmployeeID = V2.EmployeeID
GROUP BY V1.EmployeeID, V1.OrderYear, V1.Qty
ORDER BY V1.EmployeeID;
GO

--------------------------------
	/* 
	VIEW With Subquery 
	Outer Query: Orders
	Subquery: OrderDetails
	*/
--------------------------------
DROP VIEW IF EXISTS dbo.VS_Employee_Orders;
GO

-- VIEW ایجاد
CREATE VIEW dbo.VS_Employee_Orders
AS
	SELECT
		O.EmployeeID,
		YEAR(O.OrderDate) AS OrderYear,
		(SELECT SUM(OD.Qty) FROM dbo.OrderDetails AS OD
			WHERE OD.OrderID = O.OrderID)
	FROM dbo.Orders AS O
	GROUP BY O.EmployeeID, YEAR(O.OrderDate); --, O.OrderID
GO

-- رفع مشکل کوئری بالا
DROP VIEW IF EXISTS dbo.VS_Employee_Orders;
GO

CREATE VIEW dbo.VS_Employee_Orders
AS
	SELECT
		O.EmployeeID,
		YEAR(O.OrderDate) AS OrderYear,
		(SELECT SUM(OD.Qty) FROM dbo.OrderDetails AS OD
			WHERE EXISTS (SELECT 1 FROM dbo.Orders AS O1
							WHERE O1.OrderID = OD.OrderID
							AND YEAR(O1.OrderDate) = YEAR(O.OrderDate)
							AND O1.EmployeeID = O.EmployeeID)) AS Qty
	FROM dbo.Orders AS O
	GROUP BY O.EmployeeID, YEAR(O.OrderDate);
GO

-- VIEW فراخوانی
SELECT * FROM dbo.VS_Employee_Orders
ORDER BY EmployeeID;
GO

-- جهت نمایش تعداد سفارشات هر سال و سال‌های ماقبل آن VIEW فراخوانی
SELECT
	VS1.EmployeeID, VS1.OrderYear, VS1.Qty,
	(SELECT SUM(VS2.Qty) FROM dbo.VS_Employee_Orders AS VS2
		WHERE VS2.EmployeeID = VS1.EmployeeID
		AND VS2.OrderYear <= VS1.OrderYear) AS Total
FROM dbo.VS_Employee_Orders AS VS1
ORDER BY VS1.EmployeeID;
GO

------------------------------------
	/* VIEW With Derived Table */
------------------------------------
SELECT
	O.EmployeeID,
	YEAR(O.OrderDate) AS OrderYear,
	(SELECT SUM(OD.Qty) FROM dbo.OrderDetails AS OD
		WHERE O.OrderID = OD.OrderID) AS Qty
FROM dbo.Orders AS O;
GO

DROP VIEW IF EXISTS dbo.VDT_Employee_Orders;
GO

-- VIEW ایجاد
CREATE VIEW dbo.VDT_Employee_Orders
AS
SELECT
	Tmp.EmployeeID,
	Tmp.OrderYear,
	SUM(Tmp.Qty) AS Qty
FROM
(SELECT
	O.EmployeeID,
	YEAR(O.OrderDate) AS OrderYear,
	(SELECT SUM(OD.Qty) FROM dbo.OrderDetails AS OD
		WHERE O.OrderID = OD.OrderID) AS Qty
FROM dbo.Orders AS O) AS Tmp
GROUP BY Tmp.EmployeeID, Tmp.OrderYear;
GO

-- جهت نمایش تعداد سفارشات هر سال و سال‌های ماقبل آن VIEW فراخوانی
SELECT
	V1.EmployeeID, V1.OrderYear, V1.Qty,
	SUM(V2.Qty) AS Total
FROM dbo.VDT_Employee_Orders AS V1
JOIN dbo.VDT_Employee_Orders AS V2
	ON V1.EmployeeID = V2.EmployeeID
	AND V1.OrderYear >= V2.OrderYear
GROUP BY V1.EmployeeID, V1.OrderYear, V1.Qty
ORDER BY EmployeeID;
GO

-- جهت نمایش تعداد سفارشات هر سال و سال‌های ماقبل آن VIEW فراخوانی
SELECT
	V1.EmployeeID, V1.OrderYear, V1.Qty,
	(SELECT SUM(V2.Qty) FROM dbo.VDT_Employee_Orders AS V2
		WHERE V2.EmployeeID = V1.EmployeeID
		AND V2.OrderYear <= V1.OrderYear) AS Total
FROM dbo.VDT_Employee_Orders AS V1
ORDER BY EmployeeID;
GO
--------------------------------------------------------------------

/*
Exersice 03
نمایش بیشترین و کم‌ترین تعداد سفارش شرکت‌های تهرانی
*/

SELECT
	C.City,
	COUNT(O.OrderID) AS Num
FROM dbo.Customers AS C
JOIN dbo.Orders AS O
	ON C.CustomerID = O.CustomerID
	WHERE C.City = N'تهران'
GROUP BY C.City	;
GO

SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID)AS Num
FROM dbo.Customers AS C
	WHERE C.City = N'تهران';
GO

-- Derived Table
SELECT
	TMP.City,
	MAX(Tmp.Num) AS MaxOrders,
	MIN(Tmp.Num) AS MINOrders
FROM
(
SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
		WHERE O.CustomerID = C.CustomerID)AS Num
FROM dbo.Customers AS C
	WHERE C.City = N'تهران'
) AS Tmp
GROUP BY TMP.City;
GO


-- نمایش بیشترین و کم‌ترین تعداد سفارش شرکت‌های هر شهر
SELECT
	DISTINCT C.City, Tmp.MaxOrders, Tmp.MinOrders
FROM dbo.Customers AS C
CROSS APPLY (SELECT
				Tmp_In.City,
				MAX(Tmp_In.Num) AS MaxOrders,
				MIN(Tmp_In.Num) AS MinOrders
			 FROM (SELECT
						C.City,
						(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O
							WHERE O.CustomerID = C.CustomerID) AS Num
				   FROM dbo.Customers AS C) AS Tmp_In
			 GROUP BY Tmp_In.City) AS Tmp
	WHERE C.City = Tmp.City;
GO

-- معادل کوئری بالا
SELECT
	Tmp.City,
	MAX(Tmp.Num) AS MaxOrders,
	MIN(Tmp.Num) AS MinOrders
FROM
(
SELECT
	C.City,
	(SELECT COUNT(O.OrderID) FROM dbo.Orders AS O 
		WHERE O.CustomerID = C.CustomerID) AS Num
FROM dbo.Customers AS C) AS Tmp
GROUP BY Tmp.City;
GO


/*
بازگشتی CTE حل تمرینات هفتگی
*/

USE tempdb;
GO

DROP TABLE IF EXISTS Ancestors;
GO

CREATE TABLE Ancestors
(
	ID INT,
	Name VARCHAR(20),
	MotherID INT,
	FatherID INT
);
GO

INSERT INTO Ancestors
VALUES
	(1,'David',NULL,NULL),
	(2,'Rose',NULL,NULL),
	(3,'Anna',2,1),
	(4,'Jack',2,1),
	(5,'Mary',NULL,NULL),
	(6,'Erick',5,4),
	(7,'Joe',5,4);
GO

--------------------------------------------------------------------
--------------------------------------------------------------------
/*
تمرین شماره 1

Erick اجداد پدری

Name     FatherID
------   --------
Jack        1
David      NULL

(2 rows affected)
*/


/*
روش اول
سهل‌انگاری یا افق دید محدود
*/
WITH Family_Tree
AS
(
	SELECT Name, FatherID FROM Ancestors
		WHERE Name = 'Erick' -- Anchor Member/*از کجا معلوم در شجره‌نامه فرد دیگری با همین نام وجود نداشته باشد*/
	UNION ALL
	SELECT A.Name, A.FatherID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID -- Recursive Member
)
SELECT * FROM Family_Tree
	WHERE Name <> 'Erick'; -- عدم توجه به ساختار کلی مساله و دیدن مساله در ابعاد کوچک
GO

/*
بهبود روش اول
نوشتن کوئری با روش اول و تغییر در شرط کوئری بیرونی
*/
WITH Family_Tree
AS
(
	SELECT Name, FatherID FROM Ancestors
		WHERE Name = 'Erick' -- Anchor Member/*از کجا معلوم در شجره‌نامه فرد دیگری با همین نام وجود نداشته باشد*/
	UNION ALL
	SELECT A.Name, A.FatherID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID -- Recursive Member
)
SELECT * FROM Family_Tree
	WHERE NOT EXISTS (SELECT Name FROM Ancestors -- هدردهی فسفر
						WHERE Family_Tree.Name = 'Erick');
GO

/*
روش دوم
اندیشیدن آنی
*/
WITH Family_Tree
AS
(
	SELECT Name, FatherID FROM Ancestors
		WHERE ID = 6 -- Anchor Member
	UNION ALL
	SELECT A.Name, A.FatherID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID -- Recursive Member
)
/*
CTE در Erick آقای ID با توجه به عدم وجود
!!! دست ما کوتاه و خرما بر نخیل
*/
SELECT * FROM Family_Tree;
	-- WHERE حرکت به‌سمت هنرنمایی‌های روش اول 
GO

/*
روش سوم
تفکر خلاق
*/
WITH Family_Tree
AS
(
	SELECT Name, FatherID, ID FROM Ancestors
		WHERE ID = 6 -- Anchor Member
	UNION ALL
	SELECT A.Name, A.FatherID, A.ID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID -- Recursive Member
)
SELECT Name, FatherID FROM Family_Tree
	WHERE ID <> 6;
GO

/*
روش چهارم
همیشه قرار نیست بعد از راه سوم
!راه چهارمی وجود نداشته باشد
*/
WITH Family_Tree
AS
(
	SELECT Name, FatherID, '' AS Gender FROM Ancestors 
		WHERE ID = 6
	UNION ALL
	SELECT A.Name, A.FatherID, 'M' AS Gender FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID
)
SELECT Name, FatherID FROM Family_Tree
	WHERE  Gender = 'M';
GO
--------------------------------------------------------------------
--------------------------------------------------------------------

/*
تمرین شماره 2

Erick اجداد مادری

ID  Name    MotherID   FatherID 
--  -----   --------   -------- 
5   Mary    NULL       NULL	    
2   Rose    NULL       NULL	    

(2 rows affected)
*/


/*
روش اول
*/
WITH Family_Tree
AS
(
	SELECT
		ID, Name, FatherID, MotherID
	FROM Ancestors
		WHERE ID = 6
	UNION ALL
	SELECT A.ID, A.NAME, A.FatherID, A.MotherID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON A.ID = FT.FatherID -- جد پدری
)
-- SELECT * FROM Family_Tree
SELECT
	A.ID, A.NAME, A.MotherID, A.FatherID
FROM Ancestors AS A
JOIN Family_Tree AS FT
	ON A.ID = FT.MotherID
ORDER BY a.ID DESC;
GO

/*
روش دوم
*/
WITH Family_Tree
AS
(
	SELECT ID, Name, MotherID, FatherID FROM Ancestors
		WHERE ID = 6
	UNION ALL
	SELECT A.ID, A.Name, A.MotherID, A.FatherID FROM Ancestors AS A
	JOIN Family_Tree AS FT
		ON FT.MotherID = A.ID
		OR FT.FatherID = A.ID
)
SELECT
	ID, NAME, MotherID, FatherID
FROM Family_Tree AS FT
	WHERE EXISTS (SELECT 1 FROM Ancestors AS A 
					WHERE A.MotherID = FT.ID);
GO

-- JOIN یا Subquery حل تمرین بدون استفاده از
WITH Family_Tree
AS
(
	SELECT
		ID ,Name ,MotherID ,FatherID ,'' AS Gender
	FROM Ancestors AS A 
		WHERE ID = 6
	UNION ALL
	SELECT
		A.ID, A.Name, A.MotherID, A.FatherID, 'M' AS Gender
	FROM Ancestors AS A 
	JOIN Family_Tree AS FT
		ON FT.FatherID = A.ID 
	UNION ALL
	SELECT A.ID, A.NAME, A.MotherID, A.FatherID, 'F' AS Gender FROM Ancestors AS A 
	JOIN Family_Tree AS FT
		ON FT.MotherID = A.ID 		
)
SELECT
	ID, NAME, MotherID, FatherID
FROM Family_Tree 
	WHERE Gender = 'F';
GO

