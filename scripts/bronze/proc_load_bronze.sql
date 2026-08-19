/*Script Purpose: 
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  -Truncates the bronze tables before loading the data.
  -Uses the 'BULK INSERT' command to load data from csv files to bronze tables.
Parameters:
  None.
This stored procedure does not accept any parameters or return any values.
Usage Example:
  EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
	SET @batch_start_time= GETDATE();
		Print '=====================================';
		Print 'Loading Bronze Layer';
		Print '=====================================';



		Print '------------------------------------';
		Print 'Loading CRM Tables';
		Print '------------------------------------';
		SET @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info
		Print '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.crm_cust_info

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';

		SET @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_prod_info';
		TRUNCATE TABLE bronze.crm_prod_info;
		Print '>> Inserting Data Into: bronze.crm_prod_info'
		BULK INSERT bronze.crm_prod_info
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.crm_prod_info
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';

		SET @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		Print '>> Inserting Data Into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';
		Print '------------------------------------';
		Print 'Loading ERP Tables';
		Print '------------------------------------';

		SET @start_time = GETDATE();
		Print '>> Truncating Table: bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12;
		Print '>> Inserting Data Into: bronze.erp_CUST_AZ12'
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.erp_CUST_AZ12
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';
		SET @start_time = GETDATE();
		Print '>> Truncating Table: bronze.erp_LOC_A101';
		TRUNCATE TABLE bronze.erp_LOC_A101;
		Print '>> Inserting Data Into: bronze.erp_LOC_A101'
		BULK INSERT bronze.erp_LOC_A101
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.erp_LOC_A101
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';

		SET @start_time = GETDATE();
		Print '>> Truncating Table: erp_PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
		Print '>> Inserting Data Into: PX_CAT_G1V2'
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\justi\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR =',',
			TABLOCK
		);
		Select 
		count(*)
		from bronze.erp_PX_CAT_G1V2
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_Time, @end_time) AS NVARCHAR)+'seconds';
		SET @batch_end_time = GETDATE();

		PRINT '>>Batch Load Duration: '+ CAST(DATEDIFF(second,@batch_start_Time, @batch_end_time) AS NVARCHAR)+'seconds';
	END TRY
	BEGIN CATCH
		PRINT '=========================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER()as NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE()as NVARCHAR);
		PRINT '=========================================================='
	END CATCH
END
