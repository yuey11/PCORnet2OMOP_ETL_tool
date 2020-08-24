/*This file used to transform PCORnet ENROLLMENT table into the OMOP observation_period table.*/
/*TRUNCATE TABLE OMOP.dbo.observation_period;*/

INSERT INTO OMOP.dbo.observation_period(
	observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id)
SELECT 
	
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(observation_period_id),0) FROM OMOP.dbo.observation_period),

	b.person_id,

	CASE
	WHEN ENR_START_DATE IS NOT NULL THEN cast(ENR_START_DATE as date)
	WHEN ENR_START_DATE IS NULL THEN '1900-01-01' END,

	CASE
	WHEN ENR_END_DATE IS NOT NULL THEN cast(ENR_END_DATE as date)
	WHEN ENR_END_DATE IS NULL THEN '1900-01-01' END,

	CASE
	WHEN ENR_BASIS = 'I' THEN 44814722
	WHEN ENR_BASIS = 'D' THEN 0
	WHEN ENR_BASIS = 'G' THEN 45890994
	WHEN ENR_BASIS = 'A' THEN 44814725
	WHEN ENR_BASIS = 'E' THEN 44814724
	WHEN ENR_BASIS = '' THEN 44814653
	WHEN ENR_BASIS IS NULL THEN 44814653 END

FROM PCORnet.dbo.ENROLLMENT a, OMOP.dbo.person b
WHERE a.PATID = b.person_source_value