SELECT SaleDateAltered, *
 FROM PortfolioProject.dbo. NashvilleHousingData

--Standardize Date Format
Select NHD1.SaleDate , CONVERT(Date,SaleDate)
From NashvilleHousingData NHD1

UPDATE NashvilleHousingData
SET Saledate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousingData 
ADD SaleDateAltered DATE

UPDATE NashvilleHousingData
SET SaledateAltered = CONVERT(DATE,SaleDate)

--Populate Property Address

SELECT NHD1.ParcelID,NHD1.PropertyAddress,NHD2.ParcelID,NHD2.PropertyAddress,ISNULL(NHD1.PropertyAddress,NHD2.PropertyAddress)
FROM NashvilleHousingData NHD1
JOIN NashvilleHousingData NHD2
on NHD1.ParcelID = NHD2.ParcelID
AND NHD1.UniqueID <> NHD2.UniqueID 
WHERE NHD1.PropertyAddress is NULL

UPDATE NHD1
SET NHD1.PropertyAddress = ISNULL(NHD1.PropertyAddress,NHD2.PropertyAddress)
FROM NashvilleHousingData NHD1
JOIN NashvilleHousingData NHD2
on NHD1.ParcelID = NHD2.ParcelID
AND NHD1.UniqueID <> NHD2.UniqueID 
WHERE NHD1.PropertyAddress is NULL

--SPLIT PROPERTY ADDRESS INTO Address and City
SELECT 
SUBSTRING(NHD1.PropertyAddress,1,CHARINDEX(',',NHD1.PropertyAddress)-1) as Address,
SUBSTRING(NHD1.PropertyAddress,CHARINDEX(',' , NHD1.PropertyAddress)+1,LEN(NHD1.PropertyAddress)) as ADDRESS
FROM NashvilleHousingData NHD1

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress VARCHAR(255)

UPDATE NashvilleHousingData 
SET PropertySplitAddress =
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity VARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT NHD1.PropertySplitAddress,NHD1.PropertySplitCity 
FROM NashvilleHousingData NHD1

SELECT NHD1.PropertySplitAddress
FROM NashvilleHousingData NHD1

SELECT NHD1.OwnerAddress
FROM NashvilleHousingData NHD1

SELECT
PARSENAME(REPLACE(NHD1.OwnerAddress , ',' , '.'),3),
PARSENAME(REPLACE(NHD1.OwnerAddress, ',', '.' ),2),
PARSENAME(REPLACE(NHD1.OwnerAddress, ',', '.'),1)
FROM NashvilleHousingData NHD1


ALTER TABLE NashvilleHousingData
ADD  OwnerAlterAddress VARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerAlterAddress = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),3)

ALTER TABLE NashvilleHousingData
ADD  OwnerAlterCity VARCHAR (255)

UPDATE NashvilleHousingData
SET OwnerAlterCity = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),2)


ALTER TABLE NashvilleHousingData
ADD  OwnerAlterState VARCHAR(55);

UPDATE NashvilleHousingData
SET OwnerAlterState = PARSENAME(REPLACE(OwnerAddress, ',' ,'.'),1)


SELECT NHD1.OwnerAlterAddress, NHD1.OwnerAlterCity,NHD1.OwnerAlterState
FROM NashvilleHousingData NHD1

--Changed Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldASVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsvacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END
      FROM NashvilleHousingData

      UPDATE NashvilleHousingData
      SET SoldAsVacant = CASE WHEN SoldAsvacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END

-- Remove Duplicates
   SELECT * ,
   ROW_NUMBER() OVER(
    PARTITION BY ParcelId,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY
                 UniqueID)
                 Row_Num
                 From NashvilleHousingData

  WITH RowNumCTE AS (
      SELECT * ,
   ROW_NUMBER() OVER(
    PARTITION BY ParcelId,
                 PropertyAddress,
                 SaleDate,
                 SalePrice,
                 LegalReference
                 ORDER BY
                 UniqueID)
                 Row_Num
                 From NashvilleHousingData 
  )
   DELETE
   FROM RowNumCTE
   where Row_Num >1

-- Drop Unused Columns
ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

SELECT *
FROM NashvilleHousingData










