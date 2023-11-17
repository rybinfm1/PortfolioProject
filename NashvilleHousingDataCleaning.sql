--Change sale date to remove arbritary time

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)

--Checking to verify changes

Select SaleDateConverted
From PortfolioProject1..NashvilleHousing;

/*----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------*/

--Populating null property addresses by matching parcel id's to addresses with a self join

Select a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Updating the null values with the matching addresses
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,B.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] = b.[UniqueID ]
WHERE a.PropertyAddress is null

--Seperating address by Address, City and State into 3 columns for property and owner address

--PROPERTY ADDRESS

Select PropertyAddress
From PortfolioProject1..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject1..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject1..NashvilleHousing

--OWNER ADDRESS


--Using Parsename instead of substring to update columns
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

/*-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------*/

--Changing field SoldAsVacant Y and N to Yes and No

--Finding distinct values for SoldAsVacant Field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' 
		THEN 'Yes'
	WHEN SoldAsVacant = 'N'
		THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' 
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
	END
From NashvilleHousing


/*-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------*/


--Removing all duplicate observations based on matching parcelID, Property Address, Sale Price, Sale Date, and Legal Reference

--Creating a CTE for Later Reference


With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY 
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER By
			UniqueID) row_num
		--IF row_num is > 1 it is a duplicate observation
FROM PortfolioProject1..NashvilleHousing
)
--DELETING ALL Rows With row_num>1
DELETE
From RowNUMCTE
WHERE row_num > 1

				