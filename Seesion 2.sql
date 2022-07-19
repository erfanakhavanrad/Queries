use test01


SELECT * FROM sys.sysfiles
GO

use master

DROP DATABASE IF EXISTS test01

CREATE DATABASE test01 
	ON
	(NAME  = naDB1, FILENAME = 'F:\Programming\Developmnet\Databases\Test01Data.mdf', SIZE =  10MB, MAXSIZE = 100, FILEGROWTH = 20MB),
	(NAME  = naDB2, FILENAME = 'F:\Programming\Developmnet\Databases\Test02Data.ndf', SIZE =  15MB, MAXSIZE = 100, FILEGROWTH = 20%),
	(NAME  = naDB3, FILENAME = 'F:\Programming\Developmnet\Databases\Test03Data.ndf', SIZE =  10MB, MAXSIZE = UNLIMITED, FILEGROWTH = 20)
	LOG ON
	(NAME  = nal1, FILENAME = 'F:\Programming\Developmnet\Databases\Test01Log1.ldf', SIZE =  100MB, MAXSIZE =100, FILEGROWTH = 20),
	(NAME  = nal2, FILENAME = 'F:\Programming\Developmnet\Databases\Test01Log2.ldf', SIZE =  50MB, MAXSIZE =100, FILEGROWTH = 20)
	Go

	use test01

	select * from sys.sysfiles

