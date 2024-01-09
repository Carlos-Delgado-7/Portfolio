
-- Cleaning data in SQL
--------------------------------------------------------------

-------------------------------------------------------------
-- Bkup Original Data

SELECT * 
INTO NashvilleHousingOriginal
FROM NashvilleHousing


-- Restore Original Point

delete from NashvilleHousing;

insert into NashvilleHousing 
Select * from NashvilleHousingOriginal;

-------------------------------------------------------------
-- Standarize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate) from NashvilleHousing;
UPDATE NashvilleHousing set SaleDate = CONVERT(Date,SaleDate);

-------------------------------------------------------------
-- Populate Property Address data

SELECT PropertyAddress FROM NashvilleHousing

SELECT * FROM NashvilleHousing WHERE PropertyAddress IS NULL

-- Udpdate empty PropertyAddress based on ParcelID

Update NashvilleHousing
SET PropertyAddress = nv.PropertyAddress
FROM NashvilleHousing
JOIN NashvilleHousing nv on dbo.[NashvilleHousing].ParcelID = nv.ParcelID
WHERE dbo.[NashvilleHousing].ParcelID = nv.ParcelID and nv.PropertyAddress IS NOT NULL

-------------------------------------------------------------
-- Breaking out Address into individual columns (Address, City, State)
 
SELECT PropertyAddress FROM NashvilleHousing

SELECT 
    PropertyAddress,
    LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS StreetName,
    LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))) AS City
FROM dbo.NashvilleHousing
WHERE CHARINDEX(',', PropertyAddress) > 0;
 
 
 ALTER TABLE NashvilleHousing Add PropertySplitAddress Nvarchar(255);
 ALTER TABLE NashvilleHousing Add PropertySplitCity Nvarchar(255);
 
UPDATE dbo.NashvilleHousing
SET 
    PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)))
WHERE CHARINDEX(',', PropertyAddress) > 0;

 
SELECT PropertyAddress,PropertySplitAddress, PropertySplitCity  FROM NashvilleHousing



-------------------------------------------------------------
-- Breaking out Owner Address into individual columns (Address, City, State)
 
 
 SELECT OwnerAddress FROM NashvilleHousing
 
 
  SELECT OwnerAddress ,
    PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    PARSENAME(REPLACE(OwnerAddress,',','.'),1)
  FROM NashvilleHousing
 
 
 ALTER TABLE NashvilleHousing Add OwnerSplitAddress Nvarchar(255);
 ALTER TABLE NashvilleHousing Add OwnerSplitCity Nvarchar(255);
 ALTER TABLE NashvilleHousing Add OwnerSplitState Nvarchar(255);
 
 
 UPDATE NashvilleHousing set OwnerSplitAddress =   PARSENAME(REPLACE(OwnerAddress,',','.'),3);
 UPDATE NashvilleHousing set OwnerSplitCity =   PARSENAME(REPLACE(OwnerAddress,',','.'),2);
 UPDATE NashvilleHousing set OwnerSplitState =   PARSENAME(REPLACE(OwnerAddress,',','.'),1);
 
 SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState FROM NashvilleHousing
 
 
-------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant"

Select DISTINCT (SoldAsVacant) from NashvilleHousing

Update NashvilleHousing set SoldAsVacant = 'Yes' where SoldAsVacant = 'Y';
Update NashvilleHousing set SoldAsVacant = 'No' where SoldAsVacant = 'N';
 
-------------------------------------------------------------
-- Remove Duplicates

SELECT *
FROM NashvilleHousing AS nh1
WHERE EXISTS (
    SELECT 1
    FROM NashvilleHousing AS nh2
    WHERE nh1.ParcelID = nh2.ParcelID
      AND nh1.LandUse = nh2.LandUse
      AND nh1.PropertyAddress = nh2.PropertyAddress
      AND nh1.SaleDate = nh2.SaleDate
      AND nh1.SalePrice = nh2.SalePrice
      AND nh1.LegalReference = nh2.LegalReference
      AND nh1.SoldAsVacant = nh2.SoldAsVacant
      AND nh1.OwnerName = nh2.OwnerName
      AND nh1.OwnerAddress = nh2.OwnerAddress
      AND nh1.Acreage = nh2.Acreage
      AND nh1.TaxDistrict = nh2.TaxDistrict
      AND nh1.LandValue = nh2.LandValue
      AND nh1.BuildingValue = nh2.BuildingValue
      AND nh1.TotalValue = nh2.TotalValue
      AND nh1.YearBuilt = nh2.YearBuilt
      AND nh1.Bedrooms = nh2.Bedrooms
      AND nh1.FullBath = nh2.FullBath
      AND nh1.HalfBath = nh2.HalfBath
      AND nh1.UniqueID <> nh2.UniqueID
);


select * from NashvilleHousing where UniqueID in (26141,27129)

select * from NashvilleHousing where ParcelID = '091 07 0 389.00'

DELETE FROM NashvilleHousing where UniqueID IN (SELECT MAX (UniqueID)
FROM NashvilleHousing AS nh1
WHERE EXISTS (
    SELECT 1
    FROM NashvilleHousing AS nh2
    WHERE nh1.ParcelID = nh2.ParcelID
      AND nh1.LandUse = nh2.LandUse
      AND nh1.PropertyAddress = nh2.PropertyAddress
      AND nh1.SaleDate = nh2.SaleDate
      AND nh1.SalePrice = nh2.SalePrice
      AND nh1.LegalReference = nh2.LegalReference
      AND nh1.SoldAsVacant = nh2.SoldAsVacant
      AND nh1.OwnerName = nh2.OwnerName
      AND nh1.OwnerAddress = nh2.OwnerAddress
      AND nh1.Acreage = nh2.Acreage
      AND nh1.TaxDistrict = nh2.TaxDistrict
      AND nh1.LandValue = nh2.LandValue
      AND nh1.BuildingValue = nh2.BuildingValue
      AND nh1.TotalValue = nh2.TotalValue
      AND nh1.YearBuilt = nh2.YearBuilt
      AND nh1.Bedrooms = nh2.Bedrooms
      AND nh1.FullBath = nh2.FullBath
      AND nh1.HalfBath = nh2.HalfBath
      AND nh1.UniqueID <> nh2.UniqueID
)
GROUP BY nh1.ParcelID)

-------------------------------------------------------------
-- Delete Unused Columns

ALTER TABLE NashvilleHousing DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
SELECT * FROM NashvilleHousing;
