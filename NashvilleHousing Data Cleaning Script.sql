------------------------------------------------------------------------------------------------------------------
--POPULATING PROPERTY ADDRESS USING SELF JOIN

SELECT A.ParcelID, 
	   A.PropertyAddress,
	   B.ParcelID, 
	   B.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, 
	   A.PropertyAddress,
	   B.ParcelID, 
	   B.PropertyAddress, 
	   ISNULL(B.PropertyAddress, A.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL
------------------------------------------------------------------------------------------------------------------
--POPULATING TABLE USING SELF-JOIN 

UPDATE A
SET PropertyAddress = ISNULL(B.PropertyAddress, A.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing A
JOIN PortfolioProject.dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
------------------------------------------------------------------------------------------------------------------
--STANDARDIZING OR NORMALIZING DATA

SELECT SaleDate, CONVERT(DATE, Saledate) AS SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SaleDate, CAST(Saledate AS DATE) AS SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------------
--UPDATE COLUMN DATATYPE FROM DATETIME TO DATE

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, Saledate)
------------------------------------------------------------------------------------------------------------------
--ADDING NEW COLUMN TO REPLACE PREVIOUS COLUMN 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
------------------------------------------------------------------------------------------------------------------
--REMOVING COMMA OR DELIMINER

SELECT PropertyAddress,
	   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS StreetAddress
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------------
--SPLITTING TO EACH INDIVIDUAL COLUMN

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------------------
--ADDING NEW COLUMN FOR SPLIT ADDRESS AND CITTY

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
------------------------------------------------------------------------------------------------------------------
--POPOULATE NEW COLUMNS USING SUBTRING AND CHARINDEX FUNCTION

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

------------------------------------------------------------------------------------------------------------------
--SPLITTING OWNER ADDRESS INTO INDIVIDUAL COLUMN & REPLACING COMMA FOR PERIOD USING PARSENAME

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetNameSplit,
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCitySplit,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerStateSplit,
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerStreetNameSplit VARCHAR(255);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerCitySplit VARCHAR(50);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerStateSplit VARCHAR(50);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerStreetNameSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerCitySplit =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------------------------------------------------------------------------------------------------------------------
--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing

UDPATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			            WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

------------------------------------------------------------------------------------------------------------------
--SHOW DUPLICATES USING HAVING CLAUSE OR ROW_NUMBER FUNCTION

SELECT LegalReference, PropertyAddress, SaleDate, SalePrice, COUNT(*) AS RowNum
FROM PortfolioProject.dbo.NashVilleHousing
GROUP BY LegalReference, PropertyAddress, SaleDate, SalePrice
HAVING COUNT(*) > 1
OORDER BY PropertyAddress, RowNum DESC

WITH CTE AS (
SELECT LegalReference, 
	   PropertyAddress, 
	   SaleDate, 
	   SalePrice, 
	   ROW_NUMBER() OVER (PARTITION BY LegalReference, 
									   PropertyAddress, 
									   SaleDate, 
									   SalePrice
									   ORDER BY UniqueID) AS RowNum
FROM PortfolioProject.dbo.NashVilleHousing)
SELECT *
FROM CTE
WHERE RowNum > 1
------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES USING CTE

SELECT LegalReference, 
	   PropertyAddress, 
	   SaleDate, 
	   SalePrice,
	   ROW_NUMBER() OVER (PARTITION BY LegalReference, PropertyAddress, SaleDate ORDER BY LegalReference) RowNum
FROM PortfolioProject.dbo.NashVilleHousing
ORDER BY LegalReference

WITH CTE AS 
(
SELECT LegalReference, 
       PropertyAddress, 
	   SaleDate, 
	   SalePrice,
	   ROW_NUMBER() OVER (PARTITION BY LegalReference, PropertyAddress, SaleDate ORDER BY LegalReference) AS RowNum
From PortfolioProject.dbo.NashVilleHousing
)
DELETE
FROM CTE
WHERE RowNum > 1

------------------------------------------------------------------------------------------------------------------
--REMOVING DUPLICATE USING SUBQUERY IN DELETE STATEMENT
DELETE FROM PortfolioProject.dbo.NashVilleHousing
WHERE (LegalReference, PropertyAddress, SaleDate, SalePrice) IN (
    SELECT LegalReference, PropertyAddress, SaleDate, SalePrice
    FROM PortfolioProject.dbo.NashVilleHousing
    GROUP BY LegalReference, PropertyAddress, SaleDate, SalePrice
    HAVING COUNT(*) > 1;


DELETE FROM PortfolioProject.dbo.NashVilleHousing
WHERE (LegalReference, PropertyAddress, SaleDate, SalePrice) IN (
    SELECT LegalReference, PropertyAddress, SaleDate, SalePrice
    FROM PortfolioProject.dbo.NashVilleHousing
    GROUP BY LegalReference, PropertyAddress, SaleDate, SalePrice
    HAVING COUNT(*) > 1;
------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
------------------------------------------------------------------------------------------------------------------




