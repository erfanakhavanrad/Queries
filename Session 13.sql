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

کوئری‌ای بنویسید که علاوه بر نمایش کد و شهر هر مشتری، ستون‌های رنکینگ متانسب با نتایج هم در خروجی ظاهر شود.
نحوه انتخاب 
Window Functions
کاملا وابسته به نتایچ است.

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
/*
تمرین کلاسی شماره 2

کوئری‌ای بنویسید که علاوه بر نمایش عنوان هر شرکت و تعداد سفارشاتش، ستون 
Ranking
بر اساس تعداد سفارش هر مشتری باشد.
نحوه انتخاب 
Window Functions
کاملا وابسته به نتایچ است.


رنکینگ بر‌اساس بیشترین تعداد سفارش از هر شرکت

Ranking    CompanyName     Num
-------   -------------   ----
  1        شرکت IR- CS     31
  2        شرکت IR- AT     30
  3        شرکت IR- CK     28
  4        شرکت IR- AX     19
  4        شرکت IR- BK     19
  ...    		    
  87       شرکت IR- BG     2
  87       شرکت IR- BQ     2
  89       شرکت IR- AM     1

(89 rows affected)

*/

-- JOIN
SELECT
	RANK() OVER(ORDER BY COUNT(o.OrderID) DESC) AS Ranking,
	c.CompanyName,
	COUNT(o.OrderID) AS Num
FROM dbo.Customers AS c
INNER JOIN dbo.Orders AS o
	ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName 

-- Subquery
SELECT
	RANK() OVER(ORDER BY COUNT(o.OrderID) DESC) AS Ranking,
	(SELECT c.CompanyName FROM dbo.Customers AS c
		WHERE c.CustomerID = o.CustomerID) AS CompanyName,
	COUNT(o.OrderID) AS Num
FROM dbo.Orders AS o
GROUP BY o.CustomerID;
GO
--------------------------------------------------------------------
/*
NTILE(integer_expression) OVER(ORDER BY Clause)
*/

/*
NTILE اعمال تابع

:نحوه محاسبه دسته‌ها به صورت زیر است
ابتدا تعداد رکوردها بر عدد آرگومان تقسیم می‌شود
.اگر باقی‌مانده برابر با صفر نبود رکوردهای اضافی را از اولین گروه‌های ایجاد‌شده و به‌صورت مساوی میان آن‌ها تقسیم می‌کند

   |  3
77 |_____ 
75    25
___
2

*/

SELECT
	NTILE(3) OVER (ORDER BY UnitPrice) AS Ranking,
	ProductName,UnitPrice
FROM dbo.Products;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Price;
GO

CREATE TABLE dbo.Price
(
	Pname NVARCHAR(20),
	Price INT
);
GO

INSERT INTO dbo.Price
	VALUES (N'کالای 1',100),(N'کالای 2',200),(N'کالای 3',300),(N'کالای 4',200),(N'کالای 5',250),
		  (N'کالای 6',200),(N'کالای 7',100),(N'کالای 8',400),(N'کالای 9',450),(N'کالای 10',100);
GO

/*
10 / 3 = 3
10 % 3 = 1
ابتدا 3 دسته با ظرفیت  3 رکورد ایجاد می‌کند ‌
.چون باقی مانده برابر با 1 شده بنابراین 
.ظرفیت اولین دسته را به 4 رکورد افزایش می‌دهد‌

.در حقیقت یک دسته با 4 رکورد و دو دسته با 3 رکورد خواهیم داشت
*/
SELECT
	NTILE(3) OVER (ORDER BY Price)
		AS Ranking,
	Pname,
	Price
FROM dbo.Price;
GO

/*
10 / 6 = 1
10 % 6 = 4
ابتدا 6 دسته با ظرفیت  1 رکورد ایجاد می‌کند ‌
.چون باقی مانده برابر با 4 شده بنابراین 
.ظرفیت چهار دسته ابتدایی را به 2 رکورد افزایش می‌دهد‌

.در حقیقت چهار دسته با 2 رکورد و دو دسته با 1 رکورد خواهیم داشت
*/
SELECT
	NTILE(6) OVER (ORDER BY Price)
		AS Ranking,
	Pname,
	Price
FROM dbo.Price;
GO

SELECT * FROM dbo.Price;
GO

-- آیا کوئری زیر ایراد دارد؟
SELECT
	CASE NTILE(3) OVER (ORDER BY Price)
		WHEN 1 THEN 'Cheap'
		WHEN 2 THEN 'Normal'
		ELSE 'Expensive' END AS Ranking,
	Pname,
	Price
FROM dbo.Price;
GO



-- PARTITIONING

/*
Ranking_Function_Name() OVER (<partition_by_clause> <order_by_clause>)
*/

SELECT
	ROW_NUMBER() OVER(ORDER BY City) AS Ranking,
	CustomerID,
	City
FROM dbo.Customers;
GO

/*
ORDER BY ابتدا گروه‌بندی انجام می‌شود و سپس بر‌اساس فیلد جلو 
.مرتب‌سازی به‌ازای هر گروه و متناسب با تابع آن انجام می‌شود
*/
SELECT
	ROW_NUMBER() OVER(PARTITION BY City ORDER BY CustomerID) AS Ranking,
	CustomerID,
	City
FROM dbo.Customers;
GO
--------------------------------------------------------------------
/*
تمرین کلاسی شماره 3

.تمامی محصولات بر‌اساس نوع کالا، دسته‌بندی شده و رتبه‌بندی براساس قیمت واحد و صعودی باشد

	Ranking   ProductID   CategoryID  UnitPrice  ProductName
	--------  ----------  ----------  ---------  --------------
	  1         24          1           4.50       نوشابه رژیمی
	  2         75          1           7.75       آب انگور
	  3         67          1           14.00      آب آناناس
	  3         34          1           14.00      ماءالشعیر
	  4         70          1           15.00      آب انبه
	  5         39          1           18.00      آب میوه طبیعی
	  5         35          1           18.00      نکتار
	  5         1           1           18.00      آب پرتقال
	  5         76          1           18.00      آب سیب
	  6         2           1           19.00      نوشابه گازدار
	  7         43          1           46.00      آب میوه رژیمی
	  8         38          1           263.50     آب میوه گازدار
	  ...	  			  		   		   
	  1         13          8           6.00       کالاماری
	  2         45          8           9.50       ماهی قزل آلا
	  3         41          8           9.65       ماهی سنگسر
	  4         46          8           12.00      ماهی شیر
	  5         58          8           13.25      ماهی حلوا
	  6         73          8           15.00      ماهی سلمون
	  7         40          8           18.40      ماهی کیلکا
	  8         36          8           19.00      ماهی حلوا سیاه
	  9         30          8           25.89      ماهی زبیدی
	  10        37          8           26.00      ماهی حلوا سفید
	  11        10          8           31.00      میگو
	  12        18          8           62.50      ماهی سوف

(77 rows affected)
*/
SELECT
	DENSE_RANK() OVER(PARTITION BY p.CategoryID ORDER BY p.UnitPrice) AS Ranking,
	p.ProductID,
	p.CategoryID,
	p.UnitPrice,
	p.ProductName
FROM dbo.Products AS p;
GO


-- غلط است
SELECT
	DENSE_RANK() OVER(ORDER BY UnitPrice PARTITION BY CategoryID) AS Ranking,
	ProductID, CategoryID, UnitPrice, ProductName
FROM dbo.Products;
GO

-- غلط است
SELECT
	DENSE_RANK() OVER() AS Ranking,
	ProductID, CategoryID, UnitPrice, ProductName
FROM dbo.Products;
GO
--------------------------------------------------------------------

/*
Window_Aggregate_Function_Name(Aggregate Column) OVER(<partition_by_clause>)  
*/


SELECT * FROM dbo.Products
ORDER BY CategoryID;
GO

/*
Category بیشترین و کمترین قیمت از هر
*/

-- Query1
SELECT
	CategoryID, 
	ProductName,
	MIN(UnitPrice) AS MIN_Price,
	MAX(UnitPrice) AS MAX_Price
FROM dbo.products
GROUP BY CategoryID, ProductName
ORDER BY CategoryID;
GO

-- Subquery به‌روش Query1 رفع مشکل
SELECT
	CategoryID,
	ProductName,
	(SELECT MIN(UnitPrice) FROM Products P2
		WHERE p2.CategoryID = P1.CategoryID) AS MIN_Price,
	(SELECT MAX(UnitPrice) FROM Products P2
		WHERE p2.CategoryID = P1.CategoryID) AS MAX_Price
FROM dbo.Products AS P1
ORDER BY Categoryid;
GO

-- Partitioning به‌روش Query1 رفع مشکل
SELECT
	CategoryID,
	ProductName,
	MIN(UnitPrice) OVER(PARTITION BY CategoryID) AS MIN_Price,
	MAX(UnitPrice) OVER(PARTITION BY CategoryID) AS MAX_Price
FROM dbo.Products;
GO
--------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.TestTable;
GO

CREATE TABLE dbo.TestTable (ID INT , Val INT)
GO

--درج تعدادی رکورد تستی در جدول
INSERT INTO dbo.TestTable (ID, Val)
	VALUES (1,10),(2,20),(3,30),(4,40),(5,50),(6,60),(7,70);
GO

--مشاهده رکوردهای تستی درج شده در جدول
SELECT
    ID, Val FROM dbo.TestTable
GO

/*
Running Total

 ID    Value   RunningTotal
----  ------  -------------
 1      10        10
 2      20        30
 3      30        60
 4      40        100
 5      50        150
 6      60        210
 7      70        280

(7 row(s) affected)

*/


SELECT
	T1.ID, T1.Val, SUM(T2.Val) AS RunningTotal
FROM dbo.TestTable AS T1
JOIN dbo.TestTable AS T2
	ON T2.ID <= T1.ID
GROUP BY T1.ID, T1.Val;
GO

SELECT 
	ID, Val, (SELECT SUM(Val) FROM dbo.TestTable T2
				WHERE T2.ID <= T1.ID) AS RunningTotal
FROM dbo.TestTable AS T1
GO

-- !!!به‌بعد قابل اجرا است SQL 2012 این کوئری در
SELECT 
	ID, Val,
	SUM(Val) OVER(ORDER BY ID) AS RunningTotal -- (ROWS | RANGE UNBOUNDED PRECEDING AND CURRENT ROW)
FROM dbo.TestTable;
GO

-- TestTable_ID جدول ID ایندکس‌گذاری بر روی فیلد
CREATE CLUSTERED INDEX TestTable_ID ON dbo.TestTable (ID);
GO

/*
مقایسه 3 کوئری بالا پس از ایندکس‌گذاری
*/

SELECT
	T1.ID, T1.Val, SUM(T2.Val)
FROM dbo.TestTable AS T1
	JOIN dbo.TestTable AS T2
		ON T2.ID <= T1.ID
GROUP BY T1.ID, T1.Val;
GO

SELECT 
	ID, Val, (SELECT SUM(Val) FROM dbo.TestTable T2
				WHERE T2.ID <= T1.ID) AS RunningTotal
FROM dbo.TestTable T1
GO

SELECT 
	ID, Val, SUM(Val) OVER(ORDER BY ID) AS RunningTotal
FROM dbo.TestTable;
GO



-- TRANSACTION
/*
Auto Commit Transaction 
*/


DROP TABLE IF EXISTS dbo.Transact;
GO

CREATE TABLE dbo.Transact
(
	ID TINYINT,
	Family NVARCHAR(50)
);
GO

CHECKPOINT;

INSERT INTO dbo.Transact
	VALUES (1,N'پویا');
GO

SELECT * FROM sys.fn_dblog(NULL, NULL)
WHERE PartitionId IN
(
	SELECT partition_id FROM sys.partitions
	WHERE object_id = OBJECT_ID('Transact')
)
GO

SELECT * FROM sys.fn_dblog(NULL, NULL)
	WHERE [Transaction ID]='0000:0001e1ce'
GO

SELECT * FROM dbo.Transact;
GO

INSERT INTO dbo.Transact
	VALUES (2,N'تقوی'),(300,N'کریمی'),(4,N'محمدی');
GO

SELECT * FROM dbo.Transact;
GO
--------------------------------------------------------------------

/*
Explicit Transaction
*/

BEGIN TRAN -- BEGIN TRANSACTION
UPDATE dbo.Customers
	SET City = N'طهران'
		WHERE City = N'تهران';
COMMIT; -- COMMIT TRANSACTION یا COMMIT TRANS
GO

SELECT * FROM dbo.Customers
	WHERE City = N'طهران';
GO

BEGIN TRAN
UPDATE dbo.Customers
	SET City = N'تهران'
		WHERE City = N'طهران';
ROLLBACK;
GO

SELECT * FROM dbo.Customers
	WHERE City = N'طهران';
GO

BEGIN TRAN
UPDATE dbo.Customers
	SET City = N'تهران'
		WHERE City = N'طهران';
COMMIT;
GO

SELECT * FROM dbo.Customers
	WHERE City = N'تهران';
GO



-- LOCKING AND BLOCKING

DROP TABLE IF EXISTS dbo.Lock_Table;
GO

CREATE TABLE dbo.Lock_Table
(
	C1 INT
); 
GO

INSERT INTO dbo.Lock_Table
	VALUES (1) 
GO

BEGIN TRAN
	DELETE dbo.Lock_Table
		WHERE  C1 = 1 
	SELECT 
		dtl.request_session_id,
		dtl.resource_databASe_id,
		dtl.resource_ASsociated_entity_id,
		dtl.resource_type,
		dtl.resource_description,
		dtl.request_mode,
		dtl.request_status
	FROM  sys.dm_tran_locks AS dtl -- TRANSACTION ها به‌ازایLOCK نمایش
		WHERE  dtl.request_session_id = @@SPID ;
ROLLBACK;
--------------------------------------------------------------------

/*
Locking & Blocking
*/

------------------------
------------------------
-- جاری Session در
--1
BEGIN TRAN 
UPDATE  dbo.Lock_Table
	SET C1 = 100
	WHERE C1 = 1;
--4
ROLLBACK TRAN;
------------------------
------------------------


------------------------
------------------------
-- دیگر Session در
--2
USE NikamoozDB;
GO
--3
SELECT * FROM dbo.Lock_Table;
GO
------------------------
------------------------

/*
Locking & Blocking استخراج اطلاعاتی درباره
*/

SELECT
    session_id, wait_duration_ms, wait_type, blocking_session_id 
FROM sys.dm_os_waiting_tasks 
    WHERE blocking_session_id <> 0;
GO
------------------------

SELECT 
    T1.resource_type,
    T1.resource_databASe_id,
    T1.resource_ASsociated_entity_id,
    T1.request_mode,
    T1.request_session_id,
    T2.blocking_session_id
FROM sys.dm_tran_locks AS T1
    INNER JOIN sys.dm_os_waiting_tASks AS T2
        ON T1.lock_owner_address = T2.resource_address;
GO
------------------------

SELECT
    session_id,
    blocking_session_id,
    wait_time,
    wait_type,
    lASt_wait_type,
    wait_resource,
    lock_timeout
FROM sys.dm_exec_requests
    WHERE blocking_session_id <> 0;
GO
------------------------

SELECT
    t1.resource_type
    ,db_name(resource_databASe_id) AS [databASe]
    ,t1.resource_ASsociated_entity_id AS [blk object]
    ,t1.request_mode
    ,t1.request_session_id ----- spid of waiter
    ,(SELECT text FROM sys.dm_exec_requests AS r  ---- get sql for waiter
    cross apply sys.dm_exec_sql_text(r.sql_handle)
    WHERE r.session_id = t1.request_session_id) AS waiter_text
    ,t2.blocking_session_id -- spid of blocker
    , (SELECT TOP 1 request_mode
 FROM sys.dm_tran_locks t1
 JOIN sys.dm_os_waiting_tASks t2
 ON t1.request_session_id = t2.blocking_session_id
 WHERE request_mode NOT LIKE 'IX%'
 AND resource_type NOT LIKE 'DATABASE'
 AND resource_type NOT LIKE 'METADATA%'
 ORDER BY request_mode desc) AS blocking_lock
 ,(SELECT text FROM sys.sysprocesses AS p------get sql for blocker
 cross apply sys.dm_exec_sql_text(p.sql_handle)
 WHERE p.spid = t2.blocking_session_id) AS blocker_text
 FROM
 sys.dm_tran_locks AS t1,
 sys.dm_os_waiting_tASks AS t2
 WHERE
 t1.lock_owner_address = t2.resource_address;
GO
------------------------

WITH [Blocking]
AS (SELECT w.[session_id]
   ,s.[original_login_name]
   ,s.[login_name]
   ,w.[wait_duration_ms]
   ,w.[wait_type]
   ,r.[status]
   ,r.[wait_resource]
   ,w.[resource_description]
   ,s.[program_name]
   ,w.[blocking_session_id]
   ,s.[host_name]
   ,r.[command]
   ,r.[percent_complete]
   ,r.[cpu_time]
   ,r.[total_elapsed_time]
   ,r.[reads]
   ,r.[writes]
   ,r.[logical_reads]
   ,r.[row_count]
   ,q.[text]
   ,q.[dbid]
   ,p.[query_plan]
   ,r.[plan_handle]
	FROM [sys].[dm_os_waiting_tASks] w
	INNER JOIN [sys].[dm_exec_sessions] s
		ON w.[session_id] = s.[session_id]
	INNER JOIN [sys].[dm_exec_requests] r
		ON s.[session_id] = r.[session_id]
	CROSS APPLY [sys].[dm_exec_sql_text](r.[plan_handle]) q
	CROSS APPLY [sys].[dm_exec_query_plan](r.[plan_handle]) p
		WHERE w.[session_id] > 50
		AND w.[wait_type] NOT IN ('DBMIRROR_DBM_EVENT'
      ,'ASYNC_NETWORK_IO'))
	SELECT b.[session_id] AS [WaitingSessionID]
      ,b.[blocking_session_id] AS [BlockingSessionID]
      ,b.[login_name] AS [WaitingUserSessionLogin]
      ,s1.[login_name] AS [BlockingUserSessionLogin]
      ,b.[original_login_name] AS [WaitingUserConnectionLogin] 
      ,s1.[original_login_name] AS [BlockingSessionConnectionLogin]
      ,b.[wait_duration_ms] AS [WaitDuration]
      ,b.[wait_type] AS [WaitType]
      ,t.[request_mode] AS [WaitRequestMode]
      ,UPPER(b.[status]) AS [WaitingProcessStatus]
      ,UPPER(s1.[status]) AS [BlockingSessionStatus]
      ,b.[wait_resource] AS [WaitResource]
      ,t.[resource_type] AS [WaitResourceType]
      ,t.[resource_databASe_id] AS [WaitResourceDatabASeID]
      ,DB_NAME(t.[resource_databASe_id]) AS [WaitResourceDatabASeName]
      ,b.[resource_description] AS [WaitResourceDescription]
      ,b.[program_name] AS [WaitingSessionProgramName]
      ,s1.[program_name] AS [BlockingSessionProgramName]
      ,b.[host_name] AS [WaitingHost]
      ,s1.[host_name] AS [BlockingHost]
      ,b.[command] AS [WaitingCommandType]
      ,b.[text] AS [WaitingCommandText]
      ,b.[row_count] AS [WaitingCommandRowCount]
      ,b.[percent_complete] AS [WaitingCommandPercentComplete]
      ,b.[cpu_time] AS [WaitingCommandCPUTime]
      ,b.[total_elapsed_time] AS [WaitingCommandTotalElapsedTime]
      ,b.[reads] AS [WaitingCommandReads]
      ,b.[writes] AS [WaitingCommandWrites]
      ,b.[logical_reads] AS [WaitingCommandLogicalReads]
      ,b.[query_plan] AS [WaitingCommandQueryPlan]
      ,b.[plan_handle] AS [WaitingCommandPlanHandle]
	FROM [Blocking] b
	INNER JOIN [sys].[dm_exec_sessions] s1
		ON b.[blocking_session_id] = s1.[session_id]
	INNER JOIN [sys].[dm_tran_locks] t
		ON t.[request_session_id] = b.[session_id]
		WHERE t.[request_status] = 'WAIT';
GO