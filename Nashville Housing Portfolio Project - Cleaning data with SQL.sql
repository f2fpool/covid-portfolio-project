/*

Cleaning Data in SQL queries

*/

SELECT * 
FROM PortfolioProject.dbo.NashvilleHosuing

-----------------------------------------------------------------------------------

-- Standardize date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHosuing

UPDATE  NashvilleHosuing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHosuing
ADD SaleDateConverted Date;

UPDATE  NashvilleHosuing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-----------------------------------------------------------------------------------

-- Populate property address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHosuing a
JOIN PortfolioProject.dbo.NashvilleHosuing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHosuing a
JOIN PortfolioProject.dbo.NashvilleHosuing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-----------------------------------------------------------------------------------

-- Breaking out address into Individual columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHosuing

ALTER TABLE NashvilleHosuing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHosuing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHosuing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHosuing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NashvilleHosuing
ADD 
OwnerSplitAddress NVARCHAR(255), 
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255)


UPDATE NashvilleHosuing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHosuing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHosuing

UPDATE NashvilleHosuing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHosuing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1


-----------------------------------------------------------------------------------

-- Delete Unused Columns (Most used on Views)

SELECT *
FROM PortfolioProject.dbo.NashvilleHosuing

ALTER TABLE PortfolioProject.dbo.NashvilleHosuing
DROP COLUMN TaxDistrict, OwnerAddress, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------