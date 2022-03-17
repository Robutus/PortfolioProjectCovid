/*
Cleaning Data
*/

select *
from PortfolioProject..NashvilleHousing
-------------------------------------
-- Standardise Sale Data Format

select SaleDateConverted, convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

-- Didn't update properly
alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

-------------------------------------
-- Populate Property Address Data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select NH1.[UniqueID ], Nh1.ParcelID, NH1.PropertyAddress, NH2.[UniqueID ], NH2.ParcelID, NH2.PropertyAddress, isnull(NH1.PropertyAddress, NH2.PropertyAddress)
from PortfolioProject..NashvilleHousing as NH1
join PortfolioProject..NashvilleHousing as NH2
	on NH1.ParcelID = NH2.ParcelID
	and NH1.[UniqueID ] != NH2.[UniqueID ]
--where NH1.PropertyAddress is Null

-- Update table to get rid of null
update NH1
set NH1.PropertyAddress = isnull(NH1.PropertyAddress, NH2.PropertyAddress)
from PortfolioProject..NashvilleHousing as NH1
join PortfolioProject..NashvilleHousing as NH2
	on NH1.ParcelID = NH2.ParcelID
	and NH1.[UniqueID ] != NH2.[UniqueID ]
where NH1.PropertyAddress is Null

-------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
	substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
,	substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress)) as City 
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress))

-- Looking at Owner Address

select OwnerAddress
from PortfolioProject..NashvilleHousing

select
	parsename(replace(OwnerAddress, ',', '.'), 3)
,	parsename(replace(OwnerAddress, ',', '.'), 2)
,	parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

-------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,	case	when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			End
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case	when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						End

-------------------------------------
-- Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over (
		partition by	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						order by
							UniqueID
							) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-------------------------------------
-- Remove Unused Columns (Not used often with raw data)

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict

alter table PortfolioProject..NashvilleHousing
drop column SaleDate