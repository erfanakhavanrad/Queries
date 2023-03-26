use Alpha
SELECT * From dbo.Employees

SELECT COUNT (GenderValue) FROM dbo.Employees

SELECT
   e.GenderValue,
   e.Gender,
    SUM(CAST (GenderValue AS INT))  * 100 / (SELECT COUNT (GenderValue) FROM dbo.Employees) AS Percentage
FROM Employees AS e
GROUP BY e.GenderValue, Gender



SELECT
    Gender,
    SUM(SeniorCitizen) / COUNT(*) * 100 SeniorsPct
FROM MyTable
GROUP BY Gender