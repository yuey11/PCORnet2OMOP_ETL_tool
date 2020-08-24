/*This file used to transform PCORnet PROCEDURES table into the OMOP procedure_occurrence table.*/
/*TRUNCATE TABLE OMOP.dbo.procedure_occurrence;*/
/*Please run the PROVIDER table ETL code first!!*/
/*Please run the ENCOUNTER table ETL code first!!*/


INSERT INTO OMOP.dbo.procedure_occurrence(
	procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_datetime,
	procedure_type_concept_id, modifier_concept_id, provider_id, visit_occurrence_id, procedure_source_value, 
	procedure_source_concept_id)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(procedure_occurrence_id),0) FROM OMOP.dbo.procedure_occurrence),

	b.person_id,

	0,

	cast(PX_DATE as date),

	CASE
	WHEN PX_DATE IS NOT NULL THEN PX_DATE
	WHEN PX_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN PX_SOURCE = 'OD' THEN 38000275
	WHEN PX_SOURCE = 'BI' THEN 0
	WHEN PX_SOURCE = 'CL' THEN 32468
	WHEN PX_SOURCE = 'DR' THEN 32425
	WHEN PX_SOURCE = 'NI' THEN 44814650
	WHEN PX_SOURCE = 'UN' THEN 44814653
	WHEN PX_SOURCE = 'OT' THEN 44814649 
	WHEN PX_SOURCE = '' THEN 44814653
	WHEN PX_SOURCE is null THEN 44814653 END,

	0,

	c.provider_id,

	d.visit_occurrence_id,

	PX,

	0

FROM PCORnet.dbo.PROCEDURES a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.provider c
ON a.PROVIDERID = c.provider_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID


/*Fill the procedure_source_concept_id value.*/
UPDATE OMOP.dbo.procedure_occurrence 
SET procedure_source_concept_id = b.concept_id
FROM OMOP.dbo.procedure_occurrence a, OMOP.dbo.concept b
WHERE a.procedure_source_value = b.concept_code and b.vocabulary_id in ('CPT4', 'HCPCS', 'ICD9Proc', 'ICD10PCS', 'LOINC', 'NDC');


/*Fill the procedure_concept_id value.*/
UPDATE OMOP.dbo.procedure_occurrence
SET procedure_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE procedure_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to';




