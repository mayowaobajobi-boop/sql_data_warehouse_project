
EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze As
BEGIN

DECLARE @START_TIME DATETIME, @END_TIME DATETIME, @BATCH_START_TIME DATETIME, @BATCH_END_TIME DATETIME; 
	Begin Try
PRINT '============================================================   ';
PRINT 'LOADING BRONZE LAYER';
PRINT '============================================================   ';

PRINT '---------------------------------------------------------------';
PRINT 'LOADING CRM TABLES';
PRINT '---------------------------------------------------------------';

SET @START_TIME = GETDATE();
PRINT '>> TRUNCATING THE TABLE: bronze.crm_Cust_Info';
TRUNCATE TABLE bronze.crm_Cust_Info;

PRINT'>> INSERTING DATA INTO: bronze.crm_Cust_Info'
Bulk Insert bronze.crm_Cust_Info
from 'C:\Users\PC\Downloads\datasets\source_crm\cust_info.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-----------------------------------';

SET @START_TIME = GETDATE();
PRINT'>> TRUNCATING THE TABLE: bronze.crm_prd_Info'
TRUNCATE TABLE bronze.crm_prd_Info;
PRINT'>> INSERTING DATA INTO: bronze.crm_prd_Info'
Bulk Insert bronze.crm_prd_Info
from 'C:\Users\PC\Downloads\datasets\source_crm\prd_info.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-----------------------------------';


SET @START_TIME = GETDATE();
PRINT'>> TRUNCATING THE TABLE: bronze.crm_sls_details'
TRUNCATE TABLE bronze.crm_sls_details;
PRINT'>> INSERTING DATA INTO:bronze.crm_sls_details'
Bulk Insert bronze.crm_sls_details
from 'C:\Users\PC\Downloads\datasets\source_crm\sales_details.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-----------------------------------';


PRINT '------------------------------------------------------------';
PRINT 'LOADING ERP TABLES';
PRINT '-------------------------------------------------------------';

SET @START_TIME = GETDATE();
PRINT'>> TRUNCATING THE TABLE: bronze.erp_loc_a101'
TRUNCATE TABLE bronze.erp_loc_a101;
PRINT'>> INSERTING DATA INTO: bronze.erp_loc_a101'
Bulk Insert bronze.erp_loc_a101
from 'C:\Users\PC\Downloads\datasets\source_erp\loc_a101.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-----------------------------------';


SET @START_TIME = GETDATE();
PRINT'>> TRUNCATING THE TABLE: bronze.erp_cust_az12'
TRUNCATE TABLE bronze.erp_cust_az12;
PRINT'>> INSERTING DATA INTO: bronze.erp_cust_az12'
Bulk Insert bronze.erp_cust_az12
from 'C:\Users\PC\Downloads\datasets\source_erp\cust_az12.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @START_TIME, @END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-----------------------------------';



SET @START_TIME = GETDATE();
PRINT' >> TRUNCATING THE TABLE: bronze.erp_px_cat_g1v2'
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
PRINT' >> INSERTING DATA INTO: bronze.erp_px_cat_g1v2'
Bulk Insert bronze.erp_px_cat_g1v2
from 'C:\Users\PC\Downloads\datasets\source_erp\px_cat_g1v2.csv'
with (
firstrow = 2,
fieldTerminator = ',',
Tablock 
);
SET @END_TIME = GETDATE();
PRINT'>> LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @BATCH_START_TIME, @BATCH_END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'>>-----------------------------------';

SET @BATCH_END_TIME = GETDATE();
PRINT'======================================================';
PRINT'Loading Bronze layer is completed';
PRINT' -TOTAL LOAD DURATION: ' + CAST(DATEDIFF( SECOND, @BATCH_START_TIME, @BATCH_END_TIME) AS NVARCHAR) + ' SECONDS';
PRINT'-------------------------------------------------------------------------';

End Try
Begin Catch
PRINT'=============================================================================='
PRINT'ERROR OCCUR DURING LOADING BRONZE LAYER'
PRINT'ERROR MESSAGE' + ERROR_MESSAGE();
PRINT'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
PRINT'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
PRINT'=============================================================================='
End Catch
END

