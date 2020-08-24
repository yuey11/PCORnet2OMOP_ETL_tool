/*This file used to transform PCORnet LDS_ADDRESS_HISTORY table into the OMOP location table.*/
/*TRUNCATE TABLE OMOP.dbo.location;*/


INSERT INTO OMOP.dbo.location(
	location_id, city, state, zip, location_source_value)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(location_id),0) FROM OMOP.dbo.location),
	
	ADDRESS_CITY,

	ADDRESS_STATE,

	ADDRESS_ZIP5,

	ADDRESSID

	FROM PCORnet.dbo.LDS_ADDRESS_HISTORY a
	LEFT JOIN OMOP.dbo.person b
	ON a.PATID = b.person_source_value;


/*Fill location_id in the OMOP person table.*/
UPDATE OMOP.dbo.person
SET location_id = b.location_id
FROM OMOP.dbo.person a, OMOP.dbo.location b, PCORnet.dbo.LDS_ADDRESS_HISTORY c
WHERE a.person_source_value = c.PATID and b.location_source_value = c.ADDRESSID;


/*Update location_source_value in the OMOP location table.*/
UPDATE OMOP.dbo.location
SET location_source_value = b.ADDRESS_CITY + ' ' + b.ADDRESS_STATE + ' ' + b.ADDRESS_ZIP5 + ' ' + b.ADDRESS_ZIP9
FROM OMOP.dbo.location a, PCORnet.dbo.LDS_ADDRESS_HISTORY b
WHERE a.location_source_value = b.ADDRESSID;

	







