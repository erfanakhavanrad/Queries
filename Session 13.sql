use SampleDb
use NikamoozDB
/*
Session 13
*/


/*
ROW_NUMBER() OVER(ORDER BY Clause)
*/

-- City با توجه به مرتب‌سازی صعودی بر روی ستون Customers ایجاد شماره ردیف برای رکوردهای جدول
SELECT
	ROW_NUMBER() OVER(ORDER BY City) AS Row_Num,
	City, State, CustomerID
FROM dbo.Customers;
GO

SELECT
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS Ranking,
	CustomerID,
	CompanyName,
	City
FROM dbo.Customers;
GO

SELECT
	ROW_NUMBER() OVER(ORDER BY State, City DESC) AS Ranking,
	EmployeeID,
	State,
	City
FROM dbo.Employees;
GO
--------------------------------------------------------------------

-- Ranking Functions عدم دسترسی به مقادیر تولید‌شده توسط
SELECT
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS Ranking,
	CustomerID,
	CompanyName,
	City
FROM dbo.Customers
	WHERE Ranking BETWEEN 10 AND 20;
GO

-- WHERE در بخش OVER عدم استفاده از
SELECT
	ROW_NUMBER() OVER(ORDER BY CustomerID) AS Ranking,
	CustomerID,
	CompanyName,
	City
FROM dbo.Customers
	WHERE ROW_NUMBER() OVER(ORDER BY CustomerID) BETWEEN 10 AND 20;
GO

-- Derived Table با استفاده از Ranking Function رفع مشکل دسترسی به فیلدهای
SELECT *
FROM (SELECT
		ROW_NUMBER() OVER(ORDER BY CustomerID) AS Ranking,
		CustomerID,
		CompanyName,
		City
	  FROM dbo.Customers) AS Tmp
WHERE Tmp.Ranking BETWEEN 10 AND 20;
GO

-- CTE با استفاده از Ranking Function رفع مشکل دسترسی به فیلدهای
WITH CTE
AS
(
	SELECT
		ROW_NUMBER() OVER(ORDER BY CustomerID) AS Ranking,
		CustomerID,
		CompanyName,
		City
	FROM dbo.Customers
)
SELECT * FROM CTE
	WHERE Ranking BETWEEN 10 AND 20;
GO
--------------------------------------------------------------------

-- Ranking اضافی در هنگام استفاده از توابع ORDER BY
SELECT
	ROW_NUMBER() OVER(ORDER BY State) AS Ranking , -- State رنکینگ براساس فیلد
	EmployeeID,
	State,
	City
FROM dbo.Employees;
GO

SELECT
	ROW_NUMBER() OVER(ORDER BY State) AS Ranking , -- State رنکینگ براساس فیلد
	EmployeeID,
	State,
	City
FROM dbo.Employees
ORDER BY City;
GO


/*
DENSE_RANK() OVER(ORDER BY Clause)
*/

/*Dense_Rank اعمال تابع*/
SELECT
	DENSE_RANK() OVER(ORDER BY City) AS Ranking,
	CustomerID, City
FROM dbo.Customers;
GO

/*.است Row_Number بر روی مقادیر منحصر به‌فرد همانند استفاده از تابع*/
SELECT
	DENSE_RANK() OVER(ORDER BY CustomerID) AS Ranking,
	CustomerID, City
FROM dbo.Customers;
GO

SELECT
	DENSE_RANK() OVER(ORDER BY City, Region) AS Ranking,
	CustomerID, City, Region
FROM dbo.Customers;
GO
--------------------------------------------------------------------

/*
تمرین کلاسی شماره 1

Row_Num  Ranking  CustomerID   City
-------  -------  ----------  -------
 1        1        31          اردبیل
 2        1        48          اردبیل
 3        1        66          اردبیل
 4        2        60          ارومیه
 5        2        24          ارومیه
 ...	    		 			 
 87       28       41          یزد
 88       28       25          یزد
 89       28       7           یزد
 90       28       77          یزد
 91       28       90          یزد

(91 row(s) affected)
*/
SELECT
	ROW_NUMBER() OVER(ORDER BY c.city) AS Row_Num,
	DENSE_RANK() OVER(ORDER BY c.city) AS Ranking,
	c.CustomerID, c.City
FROM dbo.Customers AS c;
GO
--------------------------------------------------------------------
