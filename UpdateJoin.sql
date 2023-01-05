SELECT * FROM dbo.Employees

UPDATE dbo.Employees 
SET Gender = 
(SELECT CAST( case e.TitleofCourtesy when 'Mr.' then 'Male' else 'Female' end AS NVARCHAR) 'Gender'
FROM dbo.Employees AS e), 
GenderValue = (SELECT CAST (case e.TitleofCourtesy when 'Mr.' then 1 else 0 end AS bit) 'GenderValue'
FROM dbo.Employees AS e)

Update T1
Set T1.Gender = T2.Gender, T1.GenderValue = T2.GenderValue
From dbo.Employees T1 inner Join 
(SELECT EmployeeID,CAST( case TitleofCourtesy when 'Mr.' then 'Male' else 'Female' end AS NVARCHAR) 'Gender',
CAST (case TitleofCourtesy when 'Mr.' then 1 else 0 end AS bit) 'GenderValue'
FROM dbo.Employees ) as T2
On T1.EmployeeID = T2.EmployeeID


SELECT * FROM dbo.Employees

SELECT 
GenderValue,
	SUM (CAST(GenderValue AS INT)) AS Sum,

	SUM (CAST(GenderValue AS INT)) / COUNT(*) * 100 Suming
FROm dbo.Employees
GROUP BY GenderValue

SELECT SUM(CAST(bitColumn AS INT))
FROM dbo.MyTable

--select
--    case
--      WHEN @myBoolean=1 then 'TRUE'
--      WHEN @myBoolean=0 then 'FALSE'
--      ELSE NULL

SELECT 
	e2.EmployeeID,
	COUNT (case TitleofCourtesy When 'mr.' then 1 else null end) AS Count
FROM dbo.Employees AS e2
GROUP By e2.EmployeeID

SELECT * FROM dbo.Employees



--select count(case Position when 'Manager' then 1 else null end)
--from ...


DELETE TOP (4) From dbo.Employees

--Caution
drop table if exists Alpha.dbo.Employees

SELECT * INTO Alpha.dbo.Employees
FROM NikamoozDB.dbo.Employees

SELECT * FROM dbo.Employees
ORDER BY EmployeeID