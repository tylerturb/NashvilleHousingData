
--Cleaning Data in SQL Queries

USE CovProject
SELECT *
FROM NashvilleHousing

--Standardize Date Format

USE CovProject

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted 
FROM NashvilleHousing

---Populate Property Address Data
USE CovProject
SELECT *
FROM NashvilleHousing
--Where PropertyAddress IS NULL
ORDER BY ParcelId

USE CovProject
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


--- Breaking Out Address into Individual Columns (Address, City, State)

USE CovProject
SELECT PropertyAddress
FROM NashvilleHousing
--ORDER BY ParcelID

USE CovProject
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM [dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT * 
from NashvilleHousing

SELECT OwnerAddress
from NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.') , 3)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 2)
,PARSENAME(REPLACE(OwnerAddress,',','.') , 1)
from NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)


---Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
order by 2

--- Remove Duplicates (Using DELETE statement CTE)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM NashvilleHousing

)
DELETE 
from RowNumCTE
where row_num > 1 

---Delete Unused Columns (for use on views, not raw data) 

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

