select * from students

alter table students add Code1 INT DEFAULT 10000 WITH VALUES

ALTER TABLE students ADD code2 INT DEFAULT 20000


INSERT INTO students (family) values (N'دری')

sp_helpconstraint 'students'



CREATE TABLE employees 
(
ID INT CONSTRAINT myconst11 CHECK (ID >= 100),
Country NVARCHAR CONSTRAINT myconst22 CHECK (country IN (N'آلمان',N'ایتالیا',N'آمریکا')),
Barcode VARCHAR  CONSTRAINT myconst33 CHECK (barcode like ('[0-9][a-h]/%'))
)
GO


sp_helpconstraint 'employees'


INSERT INTO employees VALUES (100, N'آمریکا', '0a/'), (101, N'آلمان','1e/ir'), (102, N'ایتالیا',' 8h/10')
Go