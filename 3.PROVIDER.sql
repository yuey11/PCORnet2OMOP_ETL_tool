/*This file used to transform PCORnet PROVIDER table into the OMOP provider table.
  Please run this file before ENCOUNTER/DIAGNOSIS/IMMUNIZATION/MED_ADMIN/OBS_CLIN/OBS_GEN/PRESCRIBING/PROCEDURES table ETL code implementation.*/
/*TRUNCATE TABLE OMOP.dbo.provider;*/
/*PCORnet_PROVIDER_table transformation*/

INSERT INTO OMOP.dbo.provider(
	provider_id, npi, specialty_concept_id, 
	gender_concept_id, provider_source_value, specialty_source_value, 
	specialty_source_concept_id, gender_source_value, gender_source_concept_id)

SELECT 
	
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(provider_id),0) FROM OMOP.dbo.provider),

	PROVIDER_NPI,

	0,

	CASE
	WHEN PROVIDER_SEX = 'A' THEN 8570 
	WHEN PROVIDER_SEX = 'F' THEN 8532 
	WHEN PROVIDER_SEX = 'M' THEN 8507
	WHEN PROVIDER_SEX = 'NI' THEN 8551
	WHEN PROVIDER_SEX = 'UN' THEN 8551
	WHEN PROVIDER_SEX = 'OT' THEN 8521 
	WHEN PROVIDER_SEX = '' THEN 8551
	WHEN PROVIDER_SEX IS NULL THEN 8551 END,

	PROVIDERID,

	PROVIDER_SPECIALTY_PRIMARY,
	
	0,

	PROVIDER_SEX,

	CASE 
	WHEN PROVIDER_SEX = 'A' THEN 44814664 
	WHEN PROVIDER_SEX = 'F' THEN 44814665 
	WHEN PROVIDER_SEX = 'M' THEN 44814666
	WHEN PROVIDER_SEX = 'NI' THEN 44814650
	WHEN PROVIDER_SEX = 'UN' THEN 44814653
	WHEN PROVIDER_SEX = 'OT' THEN 44814649
	WHEN PROVIDER_SEX = '' THEN 44814653
	WHEN PROVIDER_SEX IS NULL THEN 44814653 END

FROM PCORnet.dbo.PROVIDER;

/*Fill the specialty_source_concept_id value.*/
UPDATE OMOP.dbo.provider 
SET specialty_source_concept_id = b.concept_id
FROM OMOP.dbo.provider a, OMOP.dbo.concept b
WHERE a.specialty_source_value = b.concept_code;

UPDATE OMOP.dbo.provider 
SET specialty_source_concept_id = 44814650
WHERE specialty_source_value = 'NI';

UPDATE OMOP.dbo.provider 
SET specialty_source_concept_id = 44814653
WHERE specialty_source_value = 'UN';

UPDATE OMOP.dbo.provider 
SET specialty_source_concept_id = 44814649
WHERE specialty_source_value = 'OT';

/*Fill the specialty_concept_id value.*/
UPDATE OMOP.dbo.provider 
SET specialty_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE specialty_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to';

UPDATE OMOP.dbo.provider 
SET specialty_concept_id = 44814650
WHERE specialty_source_value = 'NI';

UPDATE OMOP.dbo.provider 
SET specialty_concept_id = 44814653
WHERE specialty_source_value = 'UN';

UPDATE OMOP.dbo.provider 
SET specialty_concept_id = 44814649
WHERE specialty_source_value = 'OT';



