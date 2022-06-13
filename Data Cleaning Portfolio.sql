                                           --[Cleaning Data in SQL Queries]
SELECT *
FROM [SQL Project]..[Nashville Housing]


----------------------------------------Standardized Data Format for Acreage----------------------------------------

SELECT Acreage,CONVERT(decimal(10,2),Acreage)
FROM [SQL Project]..[Nashville Housing]

UPDATE [SQL Project]..[Nashville Housing]
SET Acreage = CONVERT(decimal(10,2),Acreage)

--Sometimes it doesn't update this way, hence..


ALTER TABLE [SQL Project]..[Nashville Housing]
ADD AcreageNo DECIMAL(10,2)


UPDATE [SQL Project]..[Nashville Housing]
SET AcreageNo = CONVERT(decimal(10,2),Acreage)

----------------------------------------Standardized Data Format for Sale Date----------------------------------------
SELECT SaleDate, CONVERT(date,SaleDate)
FROM [SQL Project]..[Nashville Housing]

UPDATE [SQL Project]..[Nashville Housing]
SET SaleDate = CONVERT(date,SaleDate) 


ALTER TABLE [SQL Project]..[Nashville Housing]
ADD SaleDateConverted date

UPDATE [SQL Project]..[Nashville Housing]
SET SaleDateConverted = CONVERT(date,SaleDate)
--now we are going to look at the sale date


----------------------------------------Populate the property address Data----------------------------------------

SELECT *
FROM [SQL Project]..[Nashville Housing]
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [SQL Project]..[Nashville Housing] a
JOIN [SQL Project]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 



UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [SQL Project]..[Nashville Housing] a
JOIN [SQL Project]..[Nashville Housing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 



----------------------------------------Breaking out PropertyAddress into individual columns----------------------------------------

SELECT PropertyAddress 
FROM [SQL Project]..[Nashville Housing]
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT LEN([PropertyAddress])
FROM [SQL Project]..[Nashville Housing]

SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address1, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address2
FROM [SQL Project]..[Nashville Housing]

ALTER TABLE [SQL Project]..[Nashville Housing]
ADD PropertySplitAddress nVarChar(256)

ALTER TABLE [SQL Project]..[Nashville Housing]
ADD PropertySplitCity nVarChar(256)

UPDATE [SQL Project]..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE [SQL Project]..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



SELECT *
FROM [SQL Project]..[Nashville Housing]

----------------------------------------Breaking out OwnerAddress into individual columns----------------------------------------

SELECT OwnerAddress
FROM [SQL Project]..[Nashville Housing]


SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),PARSENAME(REPLACE(OwnerAddress,',','.'),2),PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [SQL Project]..[Nashville Housing]


ALTER TABLE [SQL Project]..[Nashville Housing]
ADD OwnerSplitAddress nVarChar(256)

ALTER TABLE [SQL Project]..[Nashville Housing]
ADD OwnerSplitCity nVarChar(256)

ALTER TABLE [SQL Project]..[Nashville Housing]
ADD OwnerSplitState nVarChar(256)

UPDATE [SQL Project]..[Nashville Housing]
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE [SQL Project]..[Nashville Housing]
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE [SQL Project]..[Nashville Housing]
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 


----------------------------------------Change 'Y' and 'N' to Yes and No in 'Sold as vacant' Field----------------------------------------

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [SQL Project]..[Nashville Housing]
GROUP BY SoldAsVacant 
ORDER BY 2



SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM [SQL Project]..[Nashville Housing]


UPDATE [SQL Project]..[Nashville Housing]
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM [SQL Project]..[Nashville Housing]



----------------------------------------Remove Duplicates----------------------------------------

WITH DUPLICATES_CTE as
( 
SELECT *,ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate,LegalReference ORDER BY UniqueID) rownum

FROM [SQL Project]..[Nashville Housing]
--ORDER BY ParcelID
)
SELECT *
FROM DUPLICATES_CTE
WHERE rownum > 1



SELECT *
FROM [SQL Project]..[Nashville Housing]


----------------------------------------Deleting unused columns----------------------------------------

SELECT *
FROM [SQL Project]..[Nashville Housing]

ALTER TABLE [SQL Project]..[Nashville Housing]
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, Acreage



