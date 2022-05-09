---CLEANING DATA IN SQL QUERIES

SELECT *
FROM PortfolioProjects..NashvilleHousing;


--------------------------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

SELECT SaleDate,CAST(SaleDate AS date)
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(DATE,SaleDate);

---------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

Select *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;


Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing AS A
JOIN PortfolioProjects..NashvilleHousing AS B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

Update A
SET PropertyAddress= ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing AS A
JOIN PortfolioProjects..NashvilleHousing AS B
ON A.ParcelID=B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


--------------------------------------------------------------------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(Address,City,State)


Select PropertyAddress
FROM PortfolioProjects..NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS State
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAdress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAdress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

---OWNER ADDRESS 

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing;

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-----------------------------------------------------------------------------------------------------------------------------

--CHANGE 'Y' AND 'N' TO YES AND NO IN "Sold as Vacant" FIELD

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE  WHEN SoldASVacant='Y' THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProjects..NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant=CASE  WHEN SoldASVacant='Y' THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProjects..NashvilleHousing;;


------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES


WITH RowNumCTE AS(
SELECT*,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelId,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				  UniqueID
				  ) Row_num
FROM PortfolioProjects..NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE Row_num>1
ORDER BY PropertyAddress;

-----------------------------------------------------------------------------------------------------------------------

---DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-----------------------------------------------------------------------------------------------------------------------------

Tutorial found on Youtube from Alex the Data Analyst. 
