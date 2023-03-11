SELECT * 
FROM PortfolioProject..NashvilleHousing

--Standardizing date format for sale dates 
SELECT SaleDate, CONVERT(Date, Saledate) SaleDateConverted 
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date 


UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, Saledate)


--Populating property address data 
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID]<> b.[UniqueID] 
WHERE a.PropertyAddress is null 


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID]<> b.[UniqueID] 
WHERE a.PropertyAddress is null 


--Breaking out property address into individual columns (Address, City) 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City 
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)


UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)


UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Breaking out owner address into individual columns (Address, City, State) 
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)


UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)


UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Fixing some errors
--Updating inconsistencies for land use 
SELECT LandUse, COUNT(LandUse)
FROM PortfolioProject..NashvilleHousing 
GROUP BY LandUse 
ORDER BY LandUse


SELECT LandUse,
REPLACE(LandUse, 'VACANT RES LAND', 'VACANT RESIDENTIAL LAND')
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing 
SET LandUse = REPLACE(LandUse, 'VACANT RES LAND', 'VACANT RESIDENTIAL LAND')


UPDATE PortfolioProject..NashvilleHousing 
SET LandUse = REPLACE(LandUse, 'VACANT RESIENTIAL LAND', 'VACANT RESIDENTIAL LAND')


--Updating Y and N entries to Yes and No  
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END 
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END 


--Removing Duplicates 
With RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
ORDER BY UniqueID) row_num 
FROM PortfolioProject..NashvilleHousing 
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--Deleting Unused Columns 
ALTER TABLE PortfolioProject..NashvilleHousing 
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
