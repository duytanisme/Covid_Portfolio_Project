

/* Cleaning data in SQL queries
*/

SELECT * FROM Portfolio_Project2..NashvilleHousing

/* Standardize date format */

SELECT SaleDate, CONVERT(date,SaleDate)
  FROM Portfolio_Project2..NashvilleHousing

-- Change the SaleDate column to date type

ALTER TABLE Portfolio_Project2..NashvilleHousing
  ADD Sale_Date_Converted date

UPDATE Portfolio_Project2..NashvilleHousing
  SET Sale_Date_Converted = CONVERT(date,SaleDate)


SELECT Sale_Date_Converted
  FROM Portfolio_Project2..NashvilleHousing




/* Step 2: Populate Property Address data 
It means the Parcel ID is represented for PropertyAddress
If PropertyAddress is NULL, just populate it from other row has the same ParcelID
*/

SELECT *
  FROM Portfolio_Project2..NashvilleHousing
  --WHERE PropertyAddress IS NULL
  ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS New_Property_Address
  FROM Portfolio_Project2..NashvilleHousing AS a
  JOIN Portfolio_Project2..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project2..NashvilleHousing AS a
  JOIN Portfolio_Project2..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress IS NULL


/* STEP 3: Breaking out PropertyAddress into columns */

SELECT 
	PropertyAddress, 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,Len(PropertyAddress)) AS City
  FROM Portfolio_Project2..NashvilleHousing

ALTER TABLE Portfolio_Project2..NashvilleHousing
  ADD Property_Adress_Splited nvarchar(255)

ALTER TABLE Portfolio_Project2..NashvilleHousing
  ADD Property_City nvarchar(255)

UPDATE Portfolio_Project2..NashvilleHousing
  SET Property_Adress_Splited = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE Portfolio_Project2..NashvilleHousing
  SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,Len(PropertyAddress))

SELECT PropertyAddress, Property_Adress_Splited, Property_City
  FROM Portfolio_Project2..NashvilleHousing


/* STEP 4: Breaking out OwnerAddress into columns */

SELECT
	OwnerAddress,
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
  FROM Portfolio_Project2..NashvilleHousing


ALTER TABLE Portfolio_Project2..NashvilleHousing
ADD Owner_Split_Address nvarchar(255)

ALTER TABLE Portfolio_Project2..NashvilleHousing
ADD Owner_Split_City nvarchar(255)

ALTER TABLE Portfolio_Project2..NashvilleHousing
ADD Owner_Split_State nvarchar(255)

UPDATE Portfolio_Project2..NashvilleHousing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

UPDATE Portfolio_Project2..NashvilleHousing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

UPDATE Portfolio_Project2..NashvilleHousing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT 
	OwnerAddress,
	Owner_Split_Address,
	Owner_Split_City,
	Owner_Split_State
  FROM Portfolio_Project2..NashvilleHousing







/* STEP 5: Change Y and N to Yes and No in "SoldAsVacant" field */
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
  FROM Portfolio_Project2..NashvilleHousing
  GROUP BY SoldAsVacant
  ORDER BY 2

SELECT 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS New_Sold_As_Vacant
FROM Portfolio_Project2..NashvilleHousing

UPDATE Portfolio_Project2..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END






/* STEP 6: Remove duplicates */
-- Create a temp table --

--WITH Row_Num_CTE 
--AS(
--	SELECT *,
--		ROW_NUMBER() OVER(PARTITION BY
--			ParcelID,
--			PropertyAddress,
--			SalePrice,
--			SaleDate,
--			LegalReference
--			ORDER BY UniqueID) AS row_num
--	  FROM Portfolio_Project2..NashvilleHousing
--	  --ORDER BY ParcelID
--)
--DELETE
--  FROM Row_Num_CTE
--  WHERE row_num > 1



WITH Row_Num_CTE 
AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY UniqueID) AS row_num
	  FROM Portfolio_Project2..NashvilleHousing
	  --ORDER BY ParcelID
)
SELECT * 
  FROM Row_Num_CTE
  WHERE row_num > 1




/* Delete unused columns */

SELECT * FROM Portfolio_Project2..NashvilleHousing

--ALTER TABLE Portfolio_Project2..NashvilleHousing
--DROP COLUMN ...