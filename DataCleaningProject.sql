/*

Cleaning data in SQL queries

*/

select * 
from NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------

--Standardizing Date format (removing time)


select SaleDate, convert(DAte, SaleDate) --we will use convert function to convert this data time data to date only
from NashvilleHousing

Alter Table NashvilleHousing  -- here we added another column 'SaleDateConverted' of datatype date
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)  -- here we put the desired values in our new column

select SaleDateConverted from NashvilleHousing --result


------------------------------------------------------------------------------------------------------------------------------


--Populating Property address data
/* 
   The idea here is: the houses with the same parcel ID have the same property address. So if some unique id 'a' has no property address (NULL) but 
   shares it's parcel ID with some other unique id 'b', then 'a' will be assigned the property address of 'b'.
*/

select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress
from NashvilleHousing a							
	join NashvilleHousing b					-- Here we selected all the unique IDs 'a' that have null propertyAddress but share the parcel IDs with
	on a.ParcelID = b.ParcelID				-- some other unique ID 'b' where propertyAddress in not null.
	and a.[UniqueID ] <> b.[UniqueID ]		
where a.PropertyAddress is null

-- now we will assign PropertyAddress of b to a
update a 
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a							
	join NashvilleHousing b					-- The first parameter in IsNull is the parameter to be updated if = NULL & second parameter determines 
	on a.ParcelID = b.ParcelID				-- what is to be placed at that place.
	and a.[UniqueID ] <> b.[UniqueID ]		
where a.PropertyAddress is null

-- After updating, if we try to re-run the first query of this part, then it will give us an empty table as there are no empty entries left that 
-- satisfy that condition.


------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress --first we will do it for property address column
from NashvilleHousing

-- Here's how we separate address and city: in the data we can see that address and city are separated by a comma. So we will split 
-- It into 2 columns from the comma

select -- charindex returns the index of specified character of the specified column
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address, -- This will select the string from the 1st index until we find a comma -1 th index
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as City  --This will select the substring starting from the index next to the comma until the length of the value in the column
from NashvilleHousing

-- Now we will add and update the columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Now let's break the owner's address column 

select OwnerAddress
From NashvilleHousing

select
PARSENAME(Replace(OwnerAddress,',','.'), 1) as State,  --parsename returns parts of an object seperated by a period '.', so we replace ',' with '.' and get the last part by passing 1 
PARSENAME(Replace(OwnerAddress,',','.'), 2) as City,  --to get the second past part
PARSENAME(Replace(OwnerAddress,',','.'), 3) as Address  --to get the third last part
from NashvilleHousing

-- Now we will add and update the columns
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), count(SoldAsVacant) as Count
from NashvilleHousing		--We can see that we have Y & N insetad of Yes & No in some entries
group by SoldAsVacant
order by count

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'  --This statement changes Y to Yes 
	 when SoldAsVacant = 'N' then 'No'   --This statement changes N to No 
	 Else SoldAsVacant					 --If Y or N not found then leave the entry as is
	 End
From NashvilleHousing

--Now we will update the SoldAsVacant column using logic in the statement above 

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'   
				   when SoldAsVacant = 'N' then 'No'     
			       Else SoldAsVacant					  
				   End

--We can verify the change using the first query of this section


------------------------------------------------------------------------------------------------------------------------------


-- Deleting Unused Columns


Select *
From  NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate  -- This will delete the selected columns