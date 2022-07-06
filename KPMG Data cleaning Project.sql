----------------------------------------IMPORTING TABLE----------------------------------------
-------------------Importing table for Transactions Table

USE Modify
GO

CREATE TABLE Transactions
(
transaction_id int,	product_id int,	customer_id int, transaction_date date,	online_order varchar(256), order_status varchar(256),
brand varchar(256), product_line varchar(256),	product_class varchar(256),	product_size varchar(256),	list_price float, standard_cost varchar(256),	
product_first_sold_date int
)
GO

BULK INSERT Transactions 
FROM 'C:\Users\Mubaraq\Downloads\Transactions.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW=2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'

)
GO

SELECT * 
FROM Transactions

--Importing table for CustomerDemographic Table

USE Modify
GO

CREATE TABLE CustomerDemographic
(
customer_id int, first_name varchar(256), last_name varchar(256), gender varchar(256), past_3_years_bike_related_purchases int,	DOB nvarchar(256),
job_title varchar(256),	job_industry_category varchar(256),	wealth_segment varchar(256), deceased_indicator varchar(256),	
owns_car varchar(256), tenure int

)
GO

BULK INSERT CustomerDemographic 
FROM 'C:\Users\Mubaraq\Downloads\CustomerDemographic.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW=2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'

)
GO

SELECT * 
FROM CustomerDemographic


--Importing table for CustomerAddress Table
USE Modify
GO

CREATE TABLE CustomerAddress
(
customer_id int, address varchar(256),	postcode int, state varchar(256), country varchar(256),	property_valuation int

)
GO

BULK INSERT CustomerAddress
FROM 'C:\Users\Mubaraq\Downloads\CustomerAddress.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW=2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n'

)
GO

SELECT * 
FROM CustomerAddress


----------------------------------------DATA CLEANING PROCESS----------------------------------------



SELECT *
FROM CustomerDemographic

-------------------Converting Y to Yes and N to No in the CustomerDemographic table to ensure consistency
SELECT *
FROM Transactions
ORDER BY customer_id

SELECT deceased_indicator
,CASE
	WHEN deceased_indicator = 'N' THEN 'No'
	WHEN deceased_indicator = 'Y' THEN 'Yes'
	ELSE deceased_indicator 
	END AS DeceasedIndicator
FROM CustomerDemographic
JOIN CustomerAddress
	ON CustomerDemographic.customer_id=CustomerAddress.customer_id
WHERE deceased_indicator <> 'N'


ALTER TABLE CustomerDemographic
ADD  DeceasedIndicator varchar(256)

UPDATE CustomerDemographic
SET DeceasedIndicator = CASE
	WHEN deceased_indicator = 'N' THEN 'No'
	WHEN deceased_indicator = 'Y' THEN 'Yes'
	ELSE deceased_indicator 
	END 
FROM CustomerDemographic
JOIN CustomerAddress
	ON CustomerDemographic.customer_id=CustomerAddress.customer_id


SELECT *
FROM [Modify]..[CustomerDemographic]

SELECT deceasedindicator, ISNULL(DeceasedIndicator,'No') 
FROM CustomerDemographic
WHERE deceasedindicator IS NULL

-------------------Replacing the null cells in the deceased indicator column under the CustomerDemographic table

UPDATE [Modify]..[CustomerDemographic]
SET deceasedindicator = 'No'
WHERE deceasedindicator IS NULL



-------------------Expanding the abbreviated states in the CustomerAddress table to ensure consistency

SELECT state
,CASE
	WHEN state =  'VIC' THEN 'Victoria'
	WHEN state =  'NSW' THEN 'New South Wales'
	WHEN state =  'QLD' THEN 'QueensLand'
	ELSE state
END AS states
FROM CustomerAddress

ALTER TABLE CustomerAddress
ADD states varchar(256)

UPDATE CustomerAddress
SET  states = CASE
	WHEN state =  'VIC' THEN 'Victoria'
	WHEN state =  'NSW' THEN 'New South Wales'
	WHEN state =  'QLD' THEN 'QueensLand'
	ELSE state
END 
FROM CustomerAddress

SELECT *
FROM CustomerAddress

--correcting the mistake of having 1843 in the CustomerDemographic Table to 1943 under the DOB column
SELECT DOB
FROM CustomerDemographic
WHERE DOB NOT LIKE '%/%'

UPDATE CustomerDemographic
SET DOB = 21/12/1943
FROM CustomerDemographic
WHERE DOB NOT LIKE '%/%'

--deleting the rows in the DOB table having values to be zero
DELETE FROM CustomerDemographic
WHERE DOB = '0'


-------------------CREATING THE AGE COLUMN FROM IT'S META DATA - DOB COLUMN
SELECT 2022 - SUBSTRING(DOB,7,4) as AGE
FROM CustomerDemographic


ALTER TABLE CustomerDemographic
ADD AGE int

UPDATE CustomerDemographic
SET AGE = 2022 - SUBSTRING(DOB,7,4) 


SELECT *
FROM CustomerDemographic

--Deleting the rows having 'U' under the gender column which have corresponding NULL values in the other columns
DELETE FROM CustomerDemographic
WHERE gender = 'U'

-------------------Converting F to Female and M to Male in the CustomerDemographic table and Updating it to ensure consistency
SELECT *
,CASE
		WHEN gender = 'F' THEN 'Female'
		WHEN gender = 'Femal' THEN 'Female'
		WHEN gender = 'M' THEN 'Male'
		ELSE gender 
END AS Genders
FROM CustomerDemographic
WHERE gender <> 'Female'
AND gender <> 'Male'


UPDATE CustomerDemographic
SET gender = CASE
		WHEN gender = 'F' THEN 'Female'
		WHEN gender = 'Femal' THEN 'Female'
		WHEN gender = 'M' THEN 'Male'
		ELSE gender 
END
FROM CustomerDemographic



-------------------Removing null cells in job_title columns under the CustomerDemographic Table

DELETE FROM CustomerDemographic
WHERE job_title IS NULL


-------------------Renaming the 'n/a' cell in job_industry_category column by updating to improve context 

SELECT job_industry_category
,CASE
	WHEN job_industry_category='n/a' THEN 'Not Specified'
	ELSE job_industry_category
END 
FROM CustomerDemographic


UPDATE CustomerDemographic
SET job_industry_category = CASE
	WHEN job_industry_category='n/a' THEN 'Not Specified'
	ELSE job_industry_category
END 
FROM CustomerDemographic



-------------------checking for duplicate values in CustomerDemographic table, CustomerAddress table & Transactions table

SELECT *
FROM CustomerDemographic


WITH CTE AS
(
SELECT * ,ROW_NUMBER ()  OVER(PARTITION BY first_name, last_name,DOB ORDER BY customer_id ) as rownum
FROM CustomerDemographic
)
SELECT *
FROM CTE
WHERE rownum >1



SELECT *
FROM CustomerAddress
WHERE address = '3 Mariners Cove Terrace'


WITH CTE AS
(
SELECT * ,ROW_NUMBER ()  OVER(PARTITION BY address,postcode ORDER BY customer_id ) as rownum
FROM CustomerAddress
)
SELECT *
FROM CTE
WHERE rownum >1



SELECT *
FROM Transactions
ORDER BY product_first_sold_date


WITH CTE AS
(
SELECT * ,ROW_NUMBER ()  OVER(PARTITION BY transaction_id,transaction_date,brand,product_class,product_size ORDER BY customer_id ) as rownum
FROM Transactions
)
SELECT *
FROM CTE
WHERE rownum >1

-------------------No duplicates value found in the tables



-------------------deriving the no of transactions made in the Transactions column by creating a new table and merging it the CustomerAddress Table and CustomerDemographic Table

ALTER TABLE CustomerAddress
ADD No_Of_Transactions varchar(256)



SELECT customer_id,COUNT(customer_id) AS NoOfTransactions
FROM Transactions
GROUP BY customer_id
ORDER BY customer_id

SELECT *
FROM Transactions


SELECT *
FROM CustomerDemographic
JOIN CustomerAddress
	ON CustomerDemographic.customer_id=CustomerAddress.customer_id


-------------------creating a new table from the transaction table to join to the customer address table and customer demographics table

CREATE TABLE TransactionTable
(customer_id int,
NoOfTransaction int,
)


INSERT INTO TransactionTable 
SELECT customer_id,COUNT(customer_id) AS NoOfTransactions
FROM Modify..Transactions
GROUP BY customer_id
ORDER BY customer_id

SELECT *
FROM TransactionTable
ORDER BY customer_id

-------------------Deleting null values in Transactions table i.e. for product id of zero
DELETE FROM Transactions
WHERE brand IS NULL


-------------------Deleting null values FOR online orders in Transactions table
DELETE FROM Transactions
WHERE online_order IS NULL


-------------------Deleting the unused columns
SELECT * FROM Transactions

SELECT * FROM CustomerDemographic

ALTER TABLE CustomerDemographic
DROP COLUMN deceased_indicator


SELECT * 
FROM CustomerAddress

ALTER TABLE CustomerAddress
DROP COLUMN state

SELECT * FROM TransactionTable


 --------------------------------------THIS TWO TABLES BELOW WOULD BE USED FOR MODEL ANALYSIS, DATA EXPLORATION, AND DATA VISUALIZATION--------------------------------------
SELECT * 
FROM CustomerDemographic
JOIN CustomerAddress
	ON CustomerDemographic.customer_id = CustomerAddress.customer_id 
JOIN TransactionTable
    ON CustomerDemographic.customer_id = TransactionTable.customer_id 


SELECT *
FROM Transactions
