/*This file used to transform PCORnet DIAGNOSIS table into the OMOP condition_occurrence table.*/
/*TRUNCATE TABLE OMOP.dbo.condition_occurrence;*/
/*Please run the PROVIDER table ETL code first!!*/
/*Please run the ENCOUNTER table ETL code first!!*/


INSERT INTO OMOP.dbo.condition_occurrence(
	condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_start_datetime,
	condition_type_concept_id, condition_status_concept_id, provider_id, visit_occurrence_id, condition_source_value, 
	condition_source_concept_id, condition_status_source_value)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(condition_occurrence_id),0) FROM OMOP.dbo.condition_occurrence),

	b.person_id,

	0,

	cast(DX_DATE as date),

	CASE
	WHEN DX_DATE IS NOT NULL THEN DX_DATE
	WHEN DX_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN DX_ORIGIN = 'OD' THEN 32817
	WHEN DX_ORIGIN = 'BI' THEN 32821
	WHEN DX_ORIGIN = 'CL' THEN 32810
	WHEN DX_ORIGIN = 'DR' THEN 45754907
	WHEN DX_ORIGIN = 'NI' THEN 44814650
	WHEN DX_ORIGIN = 'UN' THEN 44814653
	WHEN DX_ORIGIN = 'OT' THEN 44814649 
	WHEN DX_ORIGIN = '' THEN 44814653
	WHEN DX_ORIGIN is null THEN 44814653 END,

	CASE
	WHEN DX_SOURCE = 'AD' THEN 32890
	WHEN DX_SOURCE = 'DI' THEN 32896
	WHEN DX_SOURCE = 'FI' THEN 40492206
	WHEN DX_SOURCE = 'IN' THEN 40492208
	WHEN DX_SOURCE = 'NI' THEN 44814650
	WHEN DX_SOURCE = 'UN' THEN 44814653
	WHEN DX_SOURCE = 'OT' THEN 44814649
	WHEN DX_SOURCE = '' THEN 44814653
	WHEN DX_SOURCE is null THEN 44814653 END,

	c.provider_id,

	d.visit_occurrence_id,
	
	DX,

	0,

	DX_SOURCE
	
FROM PCORnet.dbo.DIAGNOSIS a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.provider c
ON a.PROVIDERID = c.provider_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID;


/*Fill the condition_source_concept_id value.*/
UPDATE [COVID19_OMOP].dbo.condition_occurrence 
SET condition_source_concept_id = b.concept_id
FROM [COVID19_OMOP].dbo.condition_occurrence a, [COVID19_OMOP].dbo.concept b
WHERE a.condition_source_value = b.concept_code and (b.vocabulary_id in ('SNOMED', 'ICD10CM', 'ICD9CM'));


/*Fill the condition_concept_id value.*/
UPDATE OMOP.dbo.condition_occurrence
SET condition_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE condition_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to';






