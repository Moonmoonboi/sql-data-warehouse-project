/*
================
Create Database and Schemas
================
Script Purpose:
	This script creates a new database 'DataWarehouse' after checking if it exists.
	If the database exists, it is dropped and recreated. This script also sets up three
	schemas within the database: 'Bronze', 'Silver', 'gold'. 

CAUTION:
Running this script will drop the entire database 'DataWarehouse' database if it exists. All data
in the database will be permanently deleted. PRocees with caution and ensure proper backups are in 
order before running.
*/
Use master;
GO
--Drop and recreate DataWarehouse database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;

--Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse
GO

USE DataWarehouse
GO
--Create Schemas
Create Schema Bronze;
GO
Create Schema Silver;
GO
Create Schema gold;
GO
