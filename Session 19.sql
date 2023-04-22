use SampleDb
use NikamoozDB
/*
Session 19
*/

--01 - Buffer Pool

-- SQL Server مشاهده قسمت های مختلف حافظه در 
DBCC MemoryStatus;
GO

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

-- به‌ازای هر دیتابیس Buffer Pool مشاهده فضای تخصیص داده شده در 
WITH CTE
AS
(
	SELECT
		database_id, db_buffer_pages = COUNT_BIG(*)
	FROM sys.dm_os_buffer_descriptors
	GROUP BY database_id
)
SELECT
	db_name = CASE database_id
				WHEN 32767	THEN 'Resource DB'
				ELSE db_name(database_id) END,
	db_buffer_pages,
	db_buffer_MB = CAST(db_buffer_pages / 128.0 AS DECIMAL(6,2))
FROM CTE
ORDER BY db_buffer_MB DESC;
GO

DROP TABLE IF EXISTS Test_Table;
GO	

CREATE TABLE Test_Table 
(
   FirstName NCHAR(1000),
   LastName  NCHAR(1000),
   Email     NCHAR(1000),   
);
GO

SET NOCOUNT ON;
GO

INSERT INTO Test_Table(FirstName,LastName,Email)
	VALUES	(N'علی',N'سعادتی',N'ali.s2020@gmail.com');
GO 1000

SELECT * FROM Test_Table;
GO

--02 - Log File Architecture

-- بررسی معماری منطقی لاگ فایل
USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 NVARCHAR(10),
	Col3 NVARCHAR(10)
);
GO

INSERT Test_Table(Col2,Col3)
	VALUES	(N'T1',N'T11');
GO

-- های دیتابیس جاری VLF مشاهده تعداد
DBCC LOGINFO;
GO

/*
Status	:
	There are 2 possible values 0 and 2. 
	2 means that the VLF cannot be reused and 
	0 means that it is ready for re-use.
Parity	:
	There are 2 possible values 64 and 128.
CreateLSN	:
	This is the LSN when the VLF was created. 
	If the createLSN is 0, it means it was created 
	when the physical transaction log file was created.
*/

/*
های دیتابیس جاری VLF مشاهده تعداد
SQL SERVER 2017 اضافه شده در
*/
SELECT * FROM sys.dm_db_log_info(DEFAULT);
GO

/*
Log Fragmentation
.های آن‌ها بیش از 100 عدد است VLF مشاهده دیتابیس‌هایی که تعداد
*/
SELECT 
	S.name, COUNT(L.database_id) AS 'VLF_Count' 
FROM sys.databases AS S
CROSS APPLY sys.dm_db_log_info(S.database_id) AS L
GROUP BY S.name
	HAVING COUNT(L.database_id) > 100;
GO
--------------------------------------------------------------------

-- برای تنظیم اندازه لاگ فایل Best Practice بررسی یک 

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

-- ساخت دیتابیسی با اندازه‌های پیش فرض  
CREATE DATABASE Test_DB
ON  PRIMARY 
(
	NAME = N'Test_DB',
	FILENAME = N'C:\TempDB\Test_DB.mdf',
	SIZE = 8192KB, MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB
)
LOG ON
(
	NAME = N'Test_DB_log',
	FILENAME = N'C:\TempDB\Test_DB_log.ldf',
	SIZE = 8192KB, MAXSIZE = 2048GB, FILEGROWTH = 65536KB
);
GO

USE Test_DB;
GO

SP_HELPFILE;
GO

-- های دیتابیس جاری VLF مشاهده تعداد
SELECT * FROM sys.dm_db_log_info(DEFAULT);
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 CHAR(4000),
	Col3 CHAR(4000)
);
GO

SET NOCOUNT ON;
GO

-- .ها کنترل شودVLF حدود 7 الی 8 بار اجرا و هر بار تعداد 
INSERT Test_Table(Col2,Col3)
	VALUES	(NULL,NULL);
GO 1000

-- های دیتابیس جاری VLF مشاهده تعداد
SELECT * FROM sys.dm_db_log_info(DEFAULT);
GO

/*
رفع مشکل سناریو بالا
ساخت دیتابیس و تنظیم اعداد مناسب برای لاگ فایل 
*/

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO


CREATE DATABASE Test_DB
ON  PRIMARY
( 
	NAME = N'Test_DB',
	FILENAME = N'C:\TempDB\Test_DB.mdf',
	SIZE = 8192KB, MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB
)
LOG ON
( 
	NAME = N'Test_DB_log',
	FILENAME = N'C:\TempDB\Test_DB_log.ldf',
	SIZE = 1GB, MAXSIZE = 2048GB, FILEGROWTH = 1GB
);
GO

USE Test_DB;
GO

SP_HELPFILE;
GO

-- های دیتابیس جاری VLF مشاهده تعداد
SELECT * FROM sys.dm_db_log_info(DEFAULT);
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 CHAR(4000),
	Col3 CHAR(4000)
);
GO

-- .ها کنترل شودVLF حدود 7 الی 8 بار اجرا و هر بار تعداد 
INSERT INTO Test_Table(Col2,Col3)
	VALUES	(NULL,NULL);
GO 1000

-- های دیتابیس جاری VLF مشاهده تعداد
SELECT * FROM sys.dm_db_log_info(DEFAULT);
GO

/*
< 64MB there will be 4 new VLFs (each 1/4 of growth size)
64MB to 1GB there will be 8 new VLFs (each 1/8 of growth size)
> 1GB there will be 16 new VLFs (each 1/16 of growth size)
*/
--------------------------------------------------------------------

-- مشاهده معماری فیزیکی لاگ فایل
ALTER DATABASE Test_DB SET RECOVERY SIMPLE;
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 NVARCHAR(100),
	Col3 NVARCHAR(100)
);
GO

CHECKPOINT;
GO

INSERT Test_Table(Col2,Col3)
	VALUES	(N'T1',N'T11');
GO

-- مشاهده محتوای لاگ رکوردها
SELECT * FROM SYS.fn_dblog(NULL,NULL);
GO

INSERT Test_Table(Col2,Col3)
	VALUES	(N'T2',N'T22');
GO

--03 - Simple Recovery Model

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 CHAR(4000),
	Col3 CHAR(4000)
);
GO

INSERT INTO Test_Table(Col2,Col3)
	VALUES	(N'T1',N'T11');
GO

-- دیتابیس‌ Recovery Model مشاهده وضعیت 
SELECT 
	database_id, name, recovery_model_desc 
FROM sys.databases
	WHERE name = 'Test_DB';
GO

-- Log File مشاهده وضعیت استفاده از 
DBCC SQLPERF('LOGSPACE');
GO

-- مشاهده ظرفیت فایل‌های دیتابیس
SP_HELPFILE;
GO

-- log_reuse_wait مشاهده وضعیت 
SELECT 
	name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases
	WHERE name = 'Test_DB';
GO

-- Simple به حالت Recovery Model تنظیم 
ALTER DATABASE Test_DB SET RECOVERY SIMPLE;
GO

-- Recovery Model مشاهده وضعیت
SELECT 
	database_id, name, recovery_model_desc 
FROM sys.databases
	WHERE name = 'Test_DB';
GO

-- مشاهده ظرفیت فایل‌های دیتابیس
SP_HELPFILE;
GO

--Log File مشاهده وضعیت استفاده از 
DBCC SQLPERF('LOGSPACE');
GO

/*
ایجاد کرده و مانیتورینگ Test_DB بر روی دیتابیس Work load می‌خواهیم
.مربوط به ویندوز پیگیری کنیم Performance Monitor آن را از طریق
اضافه کرده Performance Monitor های زیر را در Counter برای این کار ابتدا

MSSQLSERVER: Databases :Log File Size(KB)
MSSQLSERVER: Databases :Log File Used Size(KB)
MSSQLSERVER: Databases :Percent Log Used

.‌و سپس کوئری زیر را اجرا می‌کنیم
*/

SET NOCOUNT ON;
GO

INSERT INTO Test_Table(Col2,Col3)
	VALUES (N'T1',N'T11');
GO 100000

DBCC SQLPERF('LOGSPACE');
GO

--04 - Full Recovery Model

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

-- دیتابیس‌ Recovery Model مشاهده وضعیت 
SELECT 
	database_id, name, recovery_model_desc 
FROM sys.databases
	WHERE name = 'Test_DB';
GO

/*
!باید باشد Full Backup شروع زنجیره لاگ باید با اولین 
.داده نخواهد شد Full Backup تا قبل از اولین Log Backup بنابراین اجازه
*/
BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_LOG.bak'
	WITH FORMAT;
GO

BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Full.bak'
	WITH FORMAT;
GO

DROP TABLE IF EXISTS Test_Table;
GO

CREATE TABLE Test_Table
(
	Col1 INT IDENTITY PRIMARY KEY,
	Col2 CHAR(4000),
	Col3 NVARCHAR(4000)
);
GO

SP_HELPFILE;
GO

-- Log File مشاهده وضعیت استفاده از 
DBCC SQLPERF('LOGSPACE');
GO

/*
ایجاد کرده و مانیتورینگ Test_DB بر روی دیتابیس Work load می‌خواهیم
.مربوط به ویندوز پیگیری کنیم Performance Monitor و مانیتورینگ آن را از طریق
اضافه کرده Performance Monitor های زیر را در Counter برای این کار ابتدا

MSSQLSERVER: Databases :Log File Size(KB)
MSSQLSERVER: Databases :Log File Used Size(KB)
MSSQLSERVER: Databases :Percent Log Used

.و سپس کوئری زیر را اجرا می‌کنیم
*/

SET NOCOUNT ON;
GO

INSERT INTO Test_Table(Col2,Col3)
	VALUES (N'T1',N'T11');
GO 100000

DBCC SQLPERF('LOGSPACE');
GO

BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_LOG.bak'
	WITH FORMAT;
GO

BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_LOG.bak'
GO

--05 - Type of Backup

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

/*
!گیری‌های زیر به مسیر ذخیره‌سازی توجه داشته باشید Backup در تمامی انواع
*/
-- Full Backup (C:\Temp_Backup\)
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB.bak';
GO

-- Differential Backup
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH DIFFERENTIAL;
GO

-- Log Backup
BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Log.bak';
GO


--06 - Backup Info

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

-- دیتابیس Recovery Model مشاهده وضعیت
SELECT
	name, recovery_model_desc
FROM sys.databases
	WHERE name = 'Test_DB';
GO

-- از دیتابیس Full Backup قبل از اولین Differential Backup عدم امکان گرفتن
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH DIFFERENTIAL;
GO

-- از دیتابیس Full Backup قبل از اولین Log Backup عدم امکان گرفتن
BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Log.bak';
GO

/*
دستور زیر را دو بار اجرا می‌کنیم تا
.گرفته شود Full Backup دو Test_DB از دیتابیس
.می‌شوند Append موردنظر Media ها در Backup تمامی
*/
-- Full Backup
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- DIFFERENTIAL Backup
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Backup.bak'
	WITH DIFFERENTIAL;
GO

-- LOG Backup
BACKUP LOG Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- Full Backup msdb
BACKUP DATABASE msdb
TO DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- Media مشاهده اطلاعاتی در باره
RESTORE LABELONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- Media های موجود در Backupset مشاهده اطلاعاتی از
/*
BackupType انواع

1: Full Backup
2: LOG Backup
5: DIFFERENTIAL Backup
*/
RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- Media موجود در Backupset مشاهده اطلاعات اولین
RESTORE FILELISTONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Backup.bak';
GO

-- Media ای خاص در Backupset مشاهده اطلاعات
RESTORE FILELISTONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Backup.bak'
	WITH FILE = 5;
GO


--07 - Backup Device

USE master;
GO

-- Local بر روی دیسک Backup Device ایجاد
EXEC sp_addumpdevice 'DISK', 'My_BackupDevice', 'C:\Temp_Backup\Test_BackupDevice.bak';
GO

-- Tape بر روی Backup Device ایجاد
EXEC sp_addumpdevice 'TAPE', 'My_Tape_BackupDevice', '\\.\tape0';
GO

-- بر روی شبکه Backup Device ایجاد
EXEC sp_addumpdevice 'DISK', 'My_Network_BackupDevice', '\\192.168.80.94\New folder\Test.bak'
GO
--------------------------------------------------------------------

-- ها Backup Device استخراج اطلاعاتي درباره
SP_HELPDEVICE;
GO

SP_HELPDEVICE 'My_BackupDevice';
GO

SELECT * FROM SYS.backup_devices;
GO
--------------------------------------------------------------------

/*
استفاده شود آن‌گاه بک‌آپ  Backup Device در صورتی‌که به شکل زیر از
ذخیره خواهد شد Instance مورد نظر در مسیر پیش‌فرض مربوط به بک‌آپ‌ها در
*/
BACKUP DATABASE Northwind TO DISK = 'My_BackupDevice';
GO

-- Backup Device نحوه استفاده صحیح از
BACKUP DATABASE Northwind TO My_BackupDevice;
GO

-- Backup Device نحوه استفاده صحیح از
BACKUP DATABASE msdb TO My_BackupDevice;
GO

RESTORE LABELONLY FROM My_BackupDevice;
GO

RESTORE HEADERONLY FROM My_BackupDevice;
GO

-- معادل دستور بالا
RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_BackupDevice.bak';
GO
--------------------------------------------------------------------

-- بدون فايل Backup Device حذف
EXEC sp_dropdevice 'My_BackupDevice';
GO

-- به‌همراه فايل Backup Device حذف
EXEC sp_dropdevice 'My_BackupDevice','DELFILE';
GO


--08 - Backupset Option

USE Test_DB;
GO

/*
NAME & DESCRIPTION
Backupset تعیین نام و توضیحات برای
*/

BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithName&Desc.bak'
	WITH NAME = N'Test_DB دیتابیس', 
		 DESCRIPTION = N'... توضیحات دلخواه';
GO

BACKUP DATABASE msdb
TO DISK ='C:\Temp_Backup\Test_DB_WithName&Desc.bak'
	WITH NAME = N'msdb دیتابیس', 
		 DESCRIPTION = N'... توضیحات دلخواه';
GO

RESTORE HEADERONLY FROM DISK ='C:\Temp_Backup\Test_DB_WithName&Desc.bak';
GO
--------------------------------------------------------------------

/*
MEDIANAME & MEDIADESCRIPTION
Media تعیین نام و توضیحات برای
*/
BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithMediaName&Desc.bak'
	WITH NAME = N'Test_DB دیتابیس', 
		 DESCRIPTION = N'... توضیحات دلخواه',
		 MEDIANAME = N'Media عنوان دلخواه برای',
		 MEDIADESCRIPTION = N'Media توضیحات دلخواه برای';
GO

RESTORE LABELONLY FROM DISK ='C:\Temp_Backup\Test_DB_WithMediaName&Desc.bak';
GO
--------------------------------------------------------------------
/*
RETAINDAYS & EXPIREDATE
INIT

کنترل رفتار بازنویسی

*/
-- !!!تاریخ سیستم را یک روز به عقب می‌بریم BACKUP قبل از
BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithRetains.bak'
	WITH NAME = N'Test_DB بک‌آپ دیتابیس',
		 RETAINDAYS = 1;
GO

BACKUP DATABASE Northwind
TO DISK='C:\Temp_Backup\Test_DB_WithRetains.bak'
	WITH NAME = N'Northwind بک‌آپ دیتابیس';
GO

-- Media Date: 
RESTORE LABELONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithRetains.bak';
GO

RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithRetains.bak';
GO

-- !!!عدم اجازه
BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithRetains.bak'
	WITH INIT;
GO
/*
BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithRetains.bak'
	WITH INIT,
		 SKIP;
GO
*/

-- !!!تاریخ سیستم را اصلاح می‌کنیم
BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithRetains.bak'
	WITH INIT;
GO

RESTORE HEADERONLY FROM  DISK='C:\Temp_Backup\Test_DB_WithRetains.bak';
GO

RESTORE FILELISTONLY FROM  DISK='C:\Temp_Backup\Test_DB_WithRetains.bak';
GO

-- Media Date: 
RESTORE LABELONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithRetains.bak';
GO
--------------------------------------------------------------------

/*
FORMAT

.را هم بازنویسی می‌کند Media Hearder است با این تفاوت که INIT همانند
*/

BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithFormat.bak'
	WITH NAME = N'Test_DB بک‌آپ دیتابیس',
		 RETAINDAYS = 1;
GO

BACKUP DATABASE Northwind
TO DISK='C:\Temp_Backup\Test_DB_WithFormat.bak'
	WITH NAME = N'Northwind بک‌آپ دیتابیس';
GO

-- Media Date: 
RESTORE LABELONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithFormat.bak';
GO

RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithFormat.bak';
GO

BACKUP DATABASE Test_DB
TO DISK='C:\Temp_Backup\Test_DB_WithFormat.bak'
	WITH FORMAT;
GO

-- Media Date: 
RESTORE LABELONLY FROM DISK = 'C:\Temp_Backup\Test_DB_WithFormat.bak';
GO

RESTORE HEADERONLY FROM  DISK='C:\Temp_Backup\Test_DB_WithFormat.bak';
GO


--09 - Restore Full Backup

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak';
GO

RESTORE HEADERONLY
FROM DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak';
GO

RESTORE FILELISTONLY
FROM DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak';
GO
--------------------------------------------------------------------

/*
Test_DB بازیابی دیتابیس
این عملیات با استفاده از دستور زیر امکان‌پذیر نیست چرا که
!چنین دیتابیسی با همین فایل‌ها و در همان مسیر از قبل وجود دارد
*/
RESTORE DATABASE Test_DB
FROM DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak';
GO

USE master;
GO

--------------------------------------------------------------------

/*
.شده باشد USE دیگری Session در Test_DB حتما دیتابیس RESTORE قبل از
!های دیگر امکان‌پذیر نیست Session بودن دیتابیس در USE دستور زیر به دلیل
*/

--------------------------------------------------------------------

ALTER DATABASE Test_DB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

USE master;
GO

RESTORE DATABASE Test_DB
FROM DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak'
	WITH REPLACE,
		 STATS = 10;
GO
--------------------------------------------------------------------

/*
نسخه‌ای مشابه از Full Backup در صورتی‌که بخواهیم با استفاده از
:و با نام دیگری ایجاد کنیم باید از روش زیر استفاده کنیم Test_DB دیتابیس
*/
RESTORE DATABASE Test_DB1
FROM DISK = 'C:\Temp_Backup\Test_DB_FullBackup.bak'
	WITH
		MOVE 'Test_DB' TO 'C:\TempDB\Test_DB1.mdf',
		MOVE 'Test_DB_log' TO 'C:\TempDB\Test_DB1.ldf',
		 STATS = 10;
GO


--10 - Restore Differential Backup

/*
به‌تنهایی امکان‌پذیر نیست Differential Backup یک Restore
!است Full Backup چرا که وابسته به آخرین
*/

USE master;
GO

IF DB_ID('Test_DB') > 0
	BEGIN
		ALTER DATABASE Test_DB
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE Test_DB;
	END;
GO

CREATE DATABASE Test_DB;
GO

USE Test_DB;
GO

CREATE TABLE dbo.Person
(
	ID INT IDENTITY,
	Family NVARCHAR(100)
);
GO

-- Full Backup
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Full.bak'
	WITH FORMAT;
GO

-- Test_DB اولین تغییر بر روی دیتابیس
INSERT INTO dbo.Person
	VALUES (N'کاربر 1');
GO

-- Differential Backup اولین  
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH DIFFERENTIAL,
		 FORMAT;
GO

-- Test_DB دومین تغییر بر روی دیتابیس
INSERT INTO dbo.Person
	VALUES (N'کاربر 2');
GO

-- Differential Backup دومین  
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH DIFFERENTIAL;
GO

-- Test_DB سومین تغییر بر روی دیتابیس
INSERT INTO dbo.Person
	VALUES (N'کاربر 3');
GO

-- Differential Backup سومین  
BACKUP DATABASE Test_DB
TO DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH DIFFERENTIAL;
GO

/*
؟؟؟
?دوم شامل چیست Differential Backup
*/

RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Full.bak';
GO

RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 1;
RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 2;
RESTORE HEADERONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 3;
GO
--------------------------------------------------------------------

/*
!به‌تنهایی Differential Backup شدن Restore عدم
*/

RESTORE FILELISTONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak';
GO

RESTORE DATABASE New_Test_DB
FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 2,
		 MOVE 'Test_DB'		TO 'C:\TempDB\Test_DB.mdf',
		 MOVE 'Test_DB_log'	TO 'C:\TempDB\Test_DB_log.ldf';
GO
--------------------------------------------------------------------

/*
Differential Backup و Full Backup کردن Restore سناریو
*/

/*
گام اول) Full Backup کردن Restore

باشد چرا که در غیر این‌صورت NORECOVERY باید در حالت Restore توجه داشته باشید که فرایند
.ها بر روی این دیتابیس با مشکل روبرو خواهیم شد Backup سایر Restore در ادامه برای
*/
RESTORE FILELISTONLY FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak';
GO

RESTORE DATABASE New_Test_DB
FROM DISK = 'C:\Temp_Backup\Test_DB_Full.bak'
	WITH STATS = 1,
		 MOVE 'Test_DB'		TO 'C:\TempDB\New_Test_DB.mdf',
		 MOVE 'Test_DB_log'	TO 'C:\TempDB\New_Test_DB_log.ldf',
		 NORECOVERY;
GO

/*
گام دوم) Backup کردن انواع دیگر Restore

دیگر هم Backup توجه داشته باشید که اگر قرار باشد در ادامه چندین
.انجام شود NORECOVERY شود می‌بایست این فرایند باز هم در حالت Restore

توجه داشته باشید که در این حالت نیازی به مسیر نیست چرا که عملیات     
.در ادامه بر روی دیتابیس جهت اعمال تغییرات بعدی انجام خواهد شد Restore
*/
RESTORE DATABASE New_Test_DB
FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 2,
		 NORECOVERY;
GO

RESTORE DATABASE New_Test_DB
	WITH RECOVERY;
GO
--------------------------------------------------------------------
--------------------------------------------------------------------

/*
هیچگونه قعالیتی بر روی دیتابیس امکان‌پذیر نیست NORECOVERY به‌صورت Restore در صورت
Restore در حین فرایند STANDBY اما می‌توان با استفاده از حالت
.دسترسی داشت Read Only به دیتابیس آن هم در حالت
*/

/*
Differential Backup و Full Backup کردن Restore سناریو
*/

/*
گام اول) Full Backup کردن Restore
*/
RESTORE DATABASE New_Test_DB2
FROM DISK = 'C:\Temp_Backup\Test_DB_Full.bak'
	WITH STATS = 1,
		 MOVE 'Test_DB'		TO 'C:\TempDB\New_Test_DB2.mdf',
		 MOVE 'Test_DB_log'	TO 'C:\TempDB\New_Test_DB2_log.ldf',
		 STANDBY = 'C:\TempDB\New_Test_DB.UNDO';
GO

/*
گام دوم) Backup کردن انواع دیگر Restore
*/
RESTORE DATABASE New_Test_DB2
FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 1,
		 STANDBY = 'C:\TempDB\New_Test_DB.UNDO';
GO

RESTORE DATABASE New_Test_DB2
FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 2,
		 STANDBY = 'C:\TempDB\New_Test_DB.UNDO';
GO

RESTORE DATABASE New_Test_DB2
FROM DISK = 'C:\Temp_Backup\Test_DB_Diff.bak'
	WITH FILE = 3,
		 STANDBY = 'C:\TempDB\New_Test_DB.UNDO';
GO

-- .بر می‌گردانیم RECOVERY در پایان دیتابیس را به‌وضعیت
RESTORE DATABASE New_Test_DB2
	WITH RECOVERY;
GO