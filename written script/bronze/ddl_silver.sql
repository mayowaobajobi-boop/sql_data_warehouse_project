
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
Declare @Start_time DATETime, @End_time DATETIME, @Batch_Start_time DATETIME, @Batch_end_Time DATETIME; 
Begin try
	Set @Batch_Start_Time = GetDate();
PRINT '============================================================   ';
PRINT 'LOADING SILVER LAYER';
PRINT '============================================================   ';

PRINT '---------------------------------------------------------------';
PRINT 'LOADING CRM TABLES';
PRINT '---------------------------------------------------------------';

----Loading silver.crm_Cust_Info
set @Start_Time = GetDate();
Print'>> Truncating the table:Insert Into silver.crm_Cust_Info'
Truncate Table silver.crm_Cust_Info;
Print'>>Inserting Data into: silver.crm_Cust_Info'
Insert Into silver.crm_Cust_Info ( Cst_Id,
Cst_Key,
Cst_firstname,
Cst_Lastname,
Cst_Marital_Status,
Cst_gndr,
Cst_create_Date
)
Select 
cst_id,
Cst_key,
Trim(Cst_firstName) As Cst_firstname,
Trim (Cst_lastname) As cst_lastname,
            CASE when UPPER(TRIM(cst_marital_status)) = 'S' Then 'Single'
			when UPPER(TRIM(cst_marital_status)) = 'm' Then 'Married'
			Else 'n/a'
End As cst_marital_status,
	CASE when UPPER(TRIM(Cst_gndr)) = 'F' Then 'Female'
		when UPPER(TRIM(Cst_gndr)) = 'm' Then 'Male'
			Else 'n/a'
			End As Cst_gndr,
	cst_create_Date
From (
Select *,
Row_number() Over( partition By Cst_Id Order By Cst_create_date DESC) as Flag_last
From bronze.crm_cust_info Where cst_id  Is Not Null) t
Where Flag_last = 1;
SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='




----loading silver.crm_prd_Info
SET @Start_Time = GETDATE();
Print'>> Truncating the table:silver.crm_prd_Info'
Truncate Table silver.crm_prd_Info;
Print'>>Inserting Data into:silver.crm_prd_Info'
INSERT INTO silver.crm_prd_Info (
prd_Id,
cat_id,
prd_Key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select
prd_Id,
Replace(Substring(prd_Key,1,5), '-', '_') as cat_id,
Substring(prd_Key, 7,len(prd_key)) As prd_key,
prd_nm,
ISNULL(prd_cost, 0) As prd_cost,
CASE UPPER(TRIM(prd_line))
	When 'M' Then 'Mountain'
	WHEN 'R' Then 'Road'
	WHEN 'S' Then 'Other Sales'
	WHEN 'T' Then 'Touring'
	ELSE 'n/a'
	End As prd_line,
CAST(prd_start_dt As Date) As prd_start_dt,
CAST(LEAD(prd_start_dt) Over( partition By prd_key Order By prd_start_dt)-1 As Date ) As prd_end_dt
from bronze.crm_prd_Info;
SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='




----Loading silver.crm_sls_details
SET @Start_Time = GETDATE();
Print'>> Truncating the table:silver.crm_sls_details'
Truncate Table silver.crm_sls_details;
Print'>>Inserting Data into:silver.crm_sls_details'
Insert Into silver.crm_sls_details (
sls_ord_num,
sls_prd_Key,
sls_cust_Id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
) 
select
sls_ord_num,
sls_prd_Key,
sls_cust_Id,
CASE When sls_order_dt = 0 or LEN(sls_order_dt) != 8 Then NULL
Else CAST(CAST(sls_order_dt As Varchar) As Date) 
End As sls_order_dt,
CASE When sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 Then NULL
Else CAST(CAST(sls_ship_dt As Varchar) As Date) 
End As sls_ship_dt,
CASE When sls_due_dt = 0 or LEN(sls_due_dt) != 8 Then NULL
Else CAST(CAST(sls_due_dt As Varchar) As Date) 
End As sls_due_dt,
CASE When sls_sales IS NULL Or sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
Then sls_quantity * ABS(sls_price)
ELSE sls_sales
END sls_sales,
sls_quantity,
CASE When sls_price Is Null Or sls_price <= 0
Then sls_sales / NULLIF(sls_quantity,0) 
Else sls_price
END As sls_price
From bronze.crm_sls_details;
SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='



PRINT '---------------------------------------------------------------';
PRINT 'LOADING ERP TABLES';
PRINT '---------------------------------------------------------------';

--- Loading silver.erp_cust_az12
SET @START_TIME = GETDATE();
Print'>> Truncating the table:silver.erp_cust_az12'
Truncate Table silver.erp_cust_az12;
Print'>>Inserting Data into:silver.erp_cust_az12'
Insert Into silver.erp_cust_az12 (
cid,
bdate,
gen
)
Select
CASE When cid Like 'NAS%' Then SUBSTRING(cid,4,LEN(cid))
	Else cid 
End As cid,
CASE When bdate > GETDATE() Then NULl
	Else bdate
End bdate,
CASE When UPPER(TRIM(gen)) IN ('F', 'FEMALE') Then 'Female'
	When UPPER(TRIM(gen)) IN ('M', 'MALE') Then 'Male'
	Else 'n/a'
End gen
from bronze.erp_cust_az12;
SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='



----Loading silver.erp_loc_a101
SET @START_TIME = GETDATE();
Print'>> Truncating the table:silver.erp_loc_a101'
Truncate Table silver.erp_loc_a101;
Print'>>Inserting Data into:silver.erp_loc_a101'
Insert Into silver.erp_loc_a101 (
cid,
cntry
)
Select
Replace(cid,'-','') As cid,
CASE When TRIM(cntry) = 'DE' Then 'Germany'
	When TRIM(cntry) IN ('US', 'USA') Then 'United State'
	When TRIM(cntry) = '' OR cntry IS NULL Then 'n/a'
	Else Trim(cntry)
End cntry
From bronze.erp_loc_a101;
SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='




---loading silver.erp_px_cat_g1v2
SET @Start_Time = GETDATE();
Print'>> Truncating the table:silver.erp_px_cat_g1v2'
Truncate Table silver.erp_px_cat_g1v2;
Print'>>Inserting Data into:silver.erp_px_cat_g1v2'
Insert Into silver.erp_px_cat_g1v2 (
id,
cat,
subcat,
maintenance
)
Select
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2;

SET @end_Time = GETDATE();
PRINT' >> Loading Duration:' + CAST(DATEDIFF(SECOND, @Start_Time, @End_Time) As NVARCHAR) + 'Seconds';
PRINT '>>======================================='



SET @Batch_End_Time = GETDATE();
PRINT'=================================================='
PRINT'Loading silver layer is completed';
PRINT' - Total Load Duration:' + CAST(DATEDIFF(SECOND, @Batch_Start_Time, @Batch_End_Time) As NVARCHAR) + 'Seconds';
PRINT '============================================================'


End Try
Begin Catch
PRINT'=============================================================================='
PRINT'ERROR OCCUR DURING LOADING SILVER LAYER'
PRINT'ERROR MESSAGE' + ERROR_MESSAGE();
PRINT'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
PRINT'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
PRINT'=============================================================================='
End Catch
END
