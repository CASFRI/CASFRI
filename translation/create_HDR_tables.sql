-- sql script to generate HDR files for each CASFRI table.
-- Subsets the inventory_list_cas05 table using the relavent columns and row

-- AB06
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end	, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id = 'AB06';

-- AB16
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end	, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id = 'AB16';

-- BC08
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end	, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id = 'BC08';

-- NB01
SELECT inventory_id, jurisdiction, owner_name, standard_type, standard_version, standard_id, standard_revision, inventory_manual, src_data_format, 
acquisition_date, data_transfer, received_from, contact_info, data_availability, redistribution, permission, license_agreement, 
photo_year_start, photo_year_end	, photo_year_src 
FROM translation.inventory_list_cas05
WHERE inventory_id = 'NB01';