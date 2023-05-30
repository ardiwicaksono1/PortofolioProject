/*

Cleaning Data in SQL Queries

*/


select * 
from PortofolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standarisasi format tanggal

select SaleDate, Convert(date,SaleDate) as SaleDateConverted
from PortofolioProject..NashvilleHousing

alter table PortofolioProject..NashvilleHousing
add SaleDateConverted Date



update PortofolioProject..NashvilleHousing
set SaleDateConverted = Convert(date,SaleDate)

Select SaleDateConverted
from PortofolioProject..NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Mengisi Property Address yang kosong, berdasarkan Parcel ID yang sama

Select *
from PortofolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortofolioProject..NashvilleHousing a
Join PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
--where a.PropertyAddress is null



update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
Join PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID



--------------------------------------------------------------------------------------------------------------------------

-- Memisahkan alamat ke beberapa kolom (Address, City, State)

Select PropertyAddress
from PortofolioProject..NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)
, SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))
from PortofolioProject..NashvilleHousing



alter table PortofolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255)

update PortofolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) 

--atau

--update PortofolioProject..NashvilleHousing
--set PropertySplitAddress = parsename(replace(PropertyAddress, ',','.'),2)



alter table PortofolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255)

update PortofolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

--atau
--update PortofolioProject..NashvilleHousing
--set PropertySplitAddress = parsename(replace(PropertyAddress, ',','.'),1)



Select OwnerAddress
from PortofolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) OwnerSplitState
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2) OwnerSplitCity
, PARSENAME(REPLACE(OwnerAddress, ',','.'),3) OwnerSplitAddress
from PortofolioProject..NashvilleHousing



alter table PortofolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update PortofolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)



alter table PortofolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255)

update PortofolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)



alter table PortofolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255)

update PortofolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--------------------------------------------------------------------------------------------------------------------------


-- Mengubah Y dan N ke Yes dan No di 'Sold as Vacant'

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortofolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from PortofolioProject..NashvilleHousing
order by 1



update PortofolioProject..NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from PortofolioProject..NashvilleHousing




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Menghilangkan duplicate

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
From PortofolioProject..NashvilleHousing
)

select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortofolioProject..NashvilleHousing

alter table PortofolioProject..NashvilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















