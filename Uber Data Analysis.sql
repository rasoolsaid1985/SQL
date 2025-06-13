select * from housing_data;

alter table housing_data
change column ï»¿UniqueID uniqueId int;
-- setting dataetable to date type
select SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y') AS ParsedDate
from housing_data;

UPDATE housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

ALTER TABLE housing_data
MODIFY COLUMN SaleDate DATE;
-- entering address on the basis of parcel id 
select * from housing_data
order by parcelID;

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ifnull(a.propertyaddress,b.propertyaddress)
from housing_data a
join housing_data b
on a.parcelId = b.ParcelID
and a.uniqueId <> b.uniqueId;

update housing_data a
join housing_data b
on a.parcelId = b.ParcelID
and a.uniqueId <> b.uniqueId
set a.propertyaddress = ifnull(a.propertyaddress,b.propertyaddress);

-- Breaking address into columns

select propertyaddress from housing_data;

select
substring(propertyaddress,1, instr(propertyaddress,',')-1) as street_address,
substring(propertyaddress, instr(propertyaddress,',')+2) as city_address
from housing_data;

alter table housing_data
add street_address varchar(255);

update housing_data
set street_address = substring(propertyaddress,1, instr(propertyaddress,',')-1);

alter table housing_data
add city_address varchar(255);

update housing_data
set city_address = substring(propertyaddress,instr(propertyaddress,',')+2);

-- setting owner address

alter table housing_Data
add owner_street varchar(255);

update housing_data
set owner_street = substring(owneraddress,1,instr(owneraddress,',')-1);

alter table housing_data
add owner_city varchar(255);

update housing_data
set owner_city = substring(owneraddress,instr(owneraddress,',')+2);

-- can also use parsename as well update housing_data set owner_city = parsename(replace(owneraddress,',','.'), 3) 
-- here parsename only split by '.' so first we replaced , with . and then 3 referes to the first name means 1 refer to last name  and so on parse name is for mysql server for workbench use substring
-- lets try it on owner city be spliting the state

alter table housing_data
add owner_state varchar(255);

update housing_data
set owner_state = trim(substring_index(owner_city,',', -1));
-- to delete state from owner city
update housing_data
set owner_city = trim(substring_index(owner_city,',',1));

select * from housing_data;

-- setting soldasvacant column

select distinct soldasvacant, count(soldasvacant)
from housing_data
group by soldasvacant;

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
Else soldasvacant
End as rty
from housing_data;

update housing_data
set soldasvacant = case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
Else soldasvacant
End;

-- removing duplicates

with row_num_cte as(
select *,
row_number() over(
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid
) row_num
from housing_data
order by parcelid
)
delete from row_num_cte
where row_num >1;

CREATE TABLE `housingdata` (
  `uniqueId` int DEFAULT NULL,
  `ParcelID` text,
  `LandUse` text,
  `PropertyAddress` text,
  `SaleDate` date DEFAULT NULL,
  `SalePrice` int DEFAULT NULL,
  `LegalReference` text,
  `SoldAsVacant` text,
  `OwnerName` text,
  `OwnerAddress` text,
  `Acreage` double DEFAULT NULL,
  `TaxDistrict` text,
  `LandValue` int DEFAULT NULL,
  `BuildingValue` int DEFAULT NULL,
  `TotalValue` int DEFAULT NULL,
  `YearBuilt` int DEFAULT NULL,
  `Bedrooms` int DEFAULT NULL,
  `FullBath` int DEFAULT NULL,
  `HalfBath` int DEFAULT NULL,
  `street_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `city_address` varchar(255) DEFAULT NULL,
  `owner_street` varchar(255) DEFAULT NULL,
  `owner_city` varchar(255) DEFAULT NULL,
  `owner_state` varchar(255) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into housingdata
select *,
row_number() over(
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by uniqueid
) row_num
from housing_data;

select * from housingdata
where row_num >1;
SET SQL_SAFE_UPDATES = 0;
delete from housingdata where row_num>1;
SET SQL_SAFE_UPDATES = 1;

-- deleting unuse columns
alter table housingdata
drop column owneraddress, 
drop column taxdistrict, 
drop column propertyaddress;

alter table housingdata
change column street_address property_street_address varchar(255),
change column city_Address property_city_address varchar(255);

select * from housingdata;
describe housing_data;

SHOW COLUMNS FROM housing_data LIKE 'SaleDate';
