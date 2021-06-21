/*This file is used to to transform PCORnet DEATH/DEATH_CAUSE table into the OMOP death table (OMOP v5.0) 
or person/condition_occurrence table (OMOP v6.0 and up, since the death table is not recommended anymore).*/
/*TRUNCATE TABLE OMOP.dbo.death;*/

/*Insert the death data into death table. (for OMOP 5.0)*/
INSERT INTO OMOP.dbo.death(
	person_id, death_date, death_datetime, death_type_concept_id, cause_concept_id, 
	cause_source_value, cause_source_concept_id)
SELECT 

	c.person_id,

	cast(DEATH_DATE as date),

	a.DEATH_DATE,

	CASE
	WHEN b.DEATH_CAUSE_TYPE = 'C' THEN 32516
	WHEN b.DEATH_CAUSE_TYPE = 'I' THEN 32515
	WHEN b.DEATH_CAUSE_TYPE = 'O' THEN 44814649
	WHEN b.DEATH_CAUSE_TYPE = 'U' THEN 32517
	WHEN b.DEATH_CAUSE_TYPE = 'NI' THEN 44814650
	WHEN b.DEATH_CAUSE_TYPE = 'UN' THEN 44814653
	WHEN b.DEATH_CAUSE_TYPE = 'OT' THEN 44814649
	WHEN b.DEATH_CAUSE_TYPE = '' THEN 44814653
	WHEN b.DEATH_CAUSE_TYPE IS NULL THEN 44814653 END, 

	0,

	DEATH_CAUSE,

	0

FROM PCORnet.dbo.DEATH a  
LEFT JOIN PCORnet.dbo.DEATH_CAUSE b
ON a.PATID = b.PATID
LEFT JOIN OMOP.dbo.person c
ON a.PATID = c.person_source_value;

/*Fill the cause_source_concept_id value.*/
UPDATE OMOP.dbo.death 
SET cause_source_concept_id = b.concept_id
FROM OMOP.dbo.death a, OMOP.dbo.concept b
WHERE a.cause_source_value = b.concept_code and b.vocabulary_id like '%ICD%';


/*Fill the cause_concept_id value.*/
UPDATE OMOP.dbo.death 
SET cause_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE cause_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to';









/*Insert the death data into person/condition_occurrence table. (for OMOP 6.0 and up)*/
/*Fill the death data into person table. */
UPDATE OMOP.dbo.person
SET death_datetime = b.DEATH_DATE
FROM OMOP.dbo.person a, PCORnet.dbo.DEATH b
WHERE a.person_source_value = b.PATID


/*Insert the death cause data into condition_occurrence table.*/
INSERT INTO OMOP.dbo.condition_occurrence(
	condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_start_datetime, 
	condition_end_date, condition_end_datetime, condition_type_concept_id, condition_status_concept_id, condition_source_value, 
	condition_source_concept_id)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(condition_occurrence_id),0) FROM OMOP.dbo.condition_occurrence),	

	c.person_id,

	0,

	cast(DEATH_DATE as date),

	CASE
	WHEN DEATH_DATE IS NOT NULL THEN DEATH_DATE
	WHEN DEATH_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	cast(DEATH_DATE as date),

	CASE
	WHEN DEATH_DATE IS NOT NULL THEN DEATH_DATE
	WHEN DEATH_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN b.DEATH_CAUSE_TYPE = 'C' THEN 255
	WHEN b.DEATH_CAUSE_TYPE = 'I' THEN 254
	WHEN b.DEATH_CAUSE_TYPE = 'O' THEN 38003569
	WHEN b.DEATH_CAUSE_TYPE = 'U' THEN 256
	WHEN b.DEATH_CAUSE_TYPE = 'NI' THEN 44814650
	WHEN b.DEATH_CAUSE_TYPE = 'UN' THEN 44814653
	WHEN b.DEATH_CAUSE_TYPE = 'OT' THEN 44814649
	WHEN b.DEATH_CAUSE_TYPE = '' THEN 44814653
	WHEN b.DEATH_CAUSE_TYPE IS NULL THEN 44814653 END, 

	4230359,
	
	DEATH_CAUSE,

	0

FROM PCORnet.dbo.DEATH a  
JOIN PCORnet.dbo.DEATH_CAUSE b
ON a.PATID = b.PATID
LEFT JOIN OMOP.dbo.person c
ON a.PATID = c.person_source_value;



/*Fill the condition_source_concept_id value.*/
UPDATE OMOP.dbo.condition_occurrence 
SET condition_source_concept_id = b.concept_id
FROM OMOP.dbo.condition_occurrence a, OMOP.dbo.concept b
WHERE a.condition_source_value = b.concept_code and b.vocabulary_id IN ('ICD9CM','ICD10CM')
and a.condition_source_concept_id = 0;


/*Fill the condition_concept_id value.*/
UPDATE OMOP.dbo.condition_occurrence 
SET condition_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE condition_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to'
and condition_concept_id = 0;


