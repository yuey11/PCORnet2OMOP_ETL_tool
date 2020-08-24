/*This file is used to to transform PCORnet CONDITION table into the OMOP condition_occurrence table.*/
/*TRUNCATE TABLE OMOP.dbo.condition_occurrence;*/
/*Please run the ENCOUNTER table ETL code first!!*/


/*PCORnet_CONDITION_table transformation*/
INSERT INTO OMOP.dbo.condition_occurrence(
	condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_start_datetime, 
	condition_end_date, condition_end_datetime, condition_type_concept_id, condition_status_concept_id, visit_occurrence_id, 
	condition_source_value, condition_source_concept_id, condition_status_source_value)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(condition_occurrence_id),0) FROM OMOP.dbo.condition_occurrence),	

	b.person_id,

	0,

	cast(REPORT_DATE as date),

	CASE
	WHEN REPORT_DATE IS NOT NULL THEN REPORT_DATE
	WHEN REPORT_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	cast(RESOLVE_DATE as date),

	CASE
	WHEN RESOLVE_DATE IS NOT NULL THEN RESOLVE_DATE
	WHEN RESOLVE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN CONDITION_SOURCE = 'PR' THEN 45905770
	WHEN CONDITION_SOURCE = 'HC' THEN 38000245
	WHEN CONDITION_SOURCE = 'RG' THEN 32535
	WHEN CONDITION_SOURCE = 'PC' THEN 0
	WHEN CONDITION_SOURCE = 'DR' THEN 32424
	WHEN CONDITION_SOURCE = 'NI' THEN 44814650
	WHEN CONDITION_SOURCE = 'UN' THEN 44814653
	WHEN CONDITION_SOURCE = 'OT' THEN 44814649 
	WHEN CONDITION_SOURCE is null THEN 44814653 END,

	CASE
	WHEN CONDITION_STATUS = 'AC' THEN 9181
	WHEN CONDITION_STATUS = 'RS' THEN 37109701
	WHEN CONDITION_STATUS = 'IN' THEN 9173
	WHEN CONDITION_STATUS = 'NI' THEN 44814650
	WHEN CONDITION_STATUS = 'UN' THEN 44814653
	WHEN CONDITION_STATUS = 'OT' THEN 44814649 
	WHEN CONDITION_STATUS is null THEN 44814653 END,

	d.visit_occurrence_id,
	
	CONDITION,

	0,

	CONDITION_STATUS


FROM PCORnet.dbo.CONDITION a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID;



/*Fill the condition_source_concept_id value.*/
UPDATE OMOP.dbo.condition_occurrence 
SET condition_source_concept_id = b.concept_id
FROM OMOP.dbo.condition_occurrence a, OMOP.dbo.concept b
WHERE a.condition_source_value = b.concept_code and (b.vocabulary_id like '%ICD%' or b.vocabulary_id in ('SNOMED'))
and a.condition_source_concept_id = 0;


/*Fill the condition_concept_id value.*/
UPDATE OMOP.dbo.condition_occurrence 
SET condition_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE condition_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to'
and condition_concept_id = 0;


