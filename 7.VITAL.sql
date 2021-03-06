/*This file used to transform PCORnet VITAL table into the OMOP measurement and observation table.*/
/*TRUNCATE TABLE OMOP.dbo.measurement;*/
/*TRUNCATE TABLE OMOP.dbo.observation;*/
/*Please run the ENCOUNTER table ETL code first!!*/

/*Insert height, weight, diastolic and BMI value to measurement table.*/
INSERT INTO OMOP.dbo.measurement(
	measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime,
	measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number, unit_concept_id, 
	visit_occurrence_id, measurement_source_value, measurement_source_concept_id, unit_source_value, value_source_value)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(measurement_id),0) FROM OMOP.dbo.measurement),

	b.person_id,

	CASE
	WHEN HT IS NOT NULL THEN 3036277
	WHEN WT IS NOT NULL THEN 3025315
	WHEN ORIGINAL_BMI IS NOT NULL THEN 3038553
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '01' THEN 3034703 
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '02' THEN 3019962
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '03' THEN 3013940
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'NI' THEN 44814650	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'UN' THEN 44814653	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'OT' THEN 44814649
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '' THEN 44814653	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION IS NULL THEN 44814653 END,

	cast(MEASURE_DATE as date),
	
	CASE
	WHEN MEASURE_DATE IS NOT NULL THEN MEASURE_DATE + ' ' + MEASURE_TIME
	WHEN MEASURE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,
	
	MEASURE_TIME,

	CASE
	WHEN VITAL_SOURCE = 'PR' THEN 32865
	WHEN VITAL_SOURCE = 'PD' THEN 4181515
	WHEN VITAL_SOURCE = 'HC' THEN 44819222
	WHEN VITAL_SOURCE = 'HD' THEN 4181515
	WHEN VITAL_SOURCE = 'DR' THEN 45754907
	WHEN VITAL_SOURCE = 'NI' THEN 44814650
	WHEN VITAL_SOURCE = 'UN' THEN 44814653
	WHEN VITAL_SOURCE = 'OT' THEN 44814649 
	WHEN VITAL_SOURCE = '' THEN 44814653
	WHEN VITAL_SOURCE is null THEN 44814653 END,

	CASE
	WHEN HT IS NOT NULL THEN 4172703
	WHEN WT IS NOT NULL THEN 4172703
	WHEN DIASTOLIC IS NOT NULL THEN 4172703 
	WHEN ORIGINAL_BMI IS NOT NULL THEN 4172703 END,

	CASE 
	WHEN HT IS NOT NULL THEN HT
	WHEN WT IS NOT NULL THEN WT
	WHEN DIASTOLIC IS NOT NULL THEN DIASTOLIC 
	WHEN ORIGINAL_BMI IS NOT NULL THEN ORIGINAL_BMI END,

	CASE 
	WHEN HT IS NOT NULL THEN 9330
	WHEN WT IS NOT NULL THEN 8739
	WHEN DIASTOLIC IS NOT NULL THEN 8876
	WHEN ORIGINAL_BMI IS NOT NULL THEN 9531 END,

	d.visit_occurrence_id,

	CASE 
	WHEN HT IS NOT NULL THEN 'HT'
	WHEN WT IS NOT NULL THEN 'WT'
	WHEN DIASTOLIC IS NOT NULL THEN 'DIASTOLIC'
	WHEN ORIGINAL_BMI IS NOT NULL THEN 'ORIGINAL_BMI' END,
 
	CASE
	WHEN HT IS NOT NULL THEN 3036277
	WHEN WT IS NOT NULL THEN 3025315
	WHEN ORIGINAL_BMI IS NOT NULL THEN 3038553
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '01' THEN 3034703 
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '02' THEN 3019962
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '03' THEN 3013940
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'NI' THEN 44814650	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'UN' THEN 44814653	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = 'OT' THEN 44814649
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION = '' THEN 44814653	
	WHEN DIASTOLIC IS NOT NULL AND BP_POSITION IS NULL THEN 44814653 END,

	CASE 
	WHEN HT IS NOT NULL THEN 'inches'
	WHEN WT IS NOT NULL THEN 'pounds'
	WHEN DIASTOLIC IS NOT NULL THEN 'mmHg'
	WHEN ORIGINAL_BMI IS NOT NULL THEN 'kg/m2' END,

	CASE 
	WHEN HT IS NOT NULL THEN cast(HT as varchar)
	WHEN WT IS NOT NULL THEN cast(WT as varchar)
	WHEN DIASTOLIC IS NOT NULL THEN cast(DIASTOLIC as varchar)
	WHEN ORIGINAL_BMI IS NOT NULL THEN cast(ORIGINAL_BMI as varchar) END

FROM PCORnet.dbo.VITAL a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID
WHERE HT IS NOT NULL OR WT IS NOT NULL OR DIASTOLIC IS NOT NULL OR ORIGINAL_BMI IS NOT NULL;









/*Insert systolic value to measurement table.*/
INSERT INTO OMOP.dbo.measurement(
	measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime,
	measurement_time, measurement_type_concept_id, operator_concept_id, value_as_number, unit_concept_id, 
	visit_occurrence_id, measurement_source_value, measurement_source_concept_id, unit_source_value, value_source_value)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(measurement_id),0) FROM OMOP.dbo.measurement),

	b.person_id,

	CASE
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '01' THEN 3018586 
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '02' THEN 3035856
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '03' THEN 3009395
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'NI' THEN 44814650	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'UN' THEN 44814653	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'OT' THEN 44814649
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '' THEN 44814653	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION IS NULL THEN 44814653 END,

	cast(MEASURE_DATE as date),

	CASE
	WHEN MEASURE_DATE IS NOT NULL THEN MEASURE_DATE + ' ' + MEASURE_TIME
	WHEN MEASURE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	MEASURE_TIME,

	CASE
	WHEN VITAL_SOURCE = 'PR' THEN 32865
	WHEN VITAL_SOURCE = 'PD' THEN 4181515
	WHEN VITAL_SOURCE = 'HC' THEN 44819222
	WHEN VITAL_SOURCE = 'HD' THEN 4181515
	WHEN VITAL_SOURCE = 'DR' THEN 45754907
	WHEN VITAL_SOURCE = 'NI' THEN 44814650
	WHEN VITAL_SOURCE = 'UN' THEN 44814653
	WHEN VITAL_SOURCE = 'OT' THEN 44814649 
	WHEN VITAL_SOURCE = '' THEN 44814653
	WHEN VITAL_SOURCE is null THEN 44814653 END,

	CASE
	WHEN SYSTOLIC IS NOT NULL THEN 4172703 END,

	CASE 
	WHEN SYSTOLIC IS NOT NULL THEN SYSTOLIC END,

	CASE 
	WHEN SYSTOLIC IS NOT NULL THEN 8876 END,

	d.visit_occurrence_id,

	CASE 
	WHEN SYSTOLIC IS NOT NULL THEN 'SYSTOLIC' END,

	CASE
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '01' THEN 3018586 
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '02' THEN 3035856
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '03' THEN 3009395
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'NI' THEN 44814650	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'UN' THEN 44814653	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = 'OT' THEN 44814649
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION = '' THEN 44814653	
	WHEN SYSTOLIC IS NOT NULL AND BP_POSITION IS NULL THEN 44814653 END,

	CASE 
	WHEN SYSTOLIC IS NOT NULL THEN 'mmHg' END,

	CASE 
	WHEN SYSTOLIC IS NOT NULL THEN cast(SYSTOLIC as varchar)
	WHEN TOBACCO IS NOT NULL THEN TOBACCO END

FROM PCORnet.dbo.VITAL a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID
WHERE SYSTOLIC IS NOT NULL;









/*Insert smoking value to observation table.*/
INSERT INTO OMOP.dbo.observation(
	observation_id, person_id, observation_concept_id, observation_date, observation_datetime, 
	observation_type_concept_id, value_as_concept_id, visit_occurrence_id, observation_source_value, observation_source_concept_id,
	obs_event_field_concept_id)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(observation_id),0) FROM OMOP.dbo.observation),

	b.person_id,

	CASE
	WHEN SMOKING IS NOT NULL THEN 40766362 END,

	cast(MEASURE_DATE as date),

	CASE
	WHEN MEASURE_DATE IS NOT NULL THEN MEASURE_DATE + ' ' + MEASURE_TIME
	WHEN MEASURE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN VITAL_SOURCE = 'PR' THEN 32865
	WHEN VITAL_SOURCE = 'PD' THEN 4181515
	WHEN VITAL_SOURCE = 'HC' THEN 44819222
	WHEN VITAL_SOURCE = 'HD' THEN 4181515
	WHEN VITAL_SOURCE = 'DR' THEN 45754907
	WHEN VITAL_SOURCE = 'NI' THEN 44814650
	WHEN VITAL_SOURCE = 'UN' THEN 44814653
	WHEN VITAL_SOURCE = 'OT' THEN 44814649 
	WHEN VITAL_SOURCE = '' THEN 44814653
	WHEN VITAL_SOURCE is null THEN 44814653 END,

	CASE
	WHEN SMOKING = '01' THEN 45881517
	WHEN SMOKING = '02' THEN 45884037
	WHEN SMOKING = '03' THEN 45883458
	WHEN SMOKING = '04' THEN 45879404
	WHEN SMOKING = '05' THEN 45881518
	WHEN SMOKING = '06' THEN 45885135
	WHEN SMOKING = '07' THEN 45884038
	WHEN SMOKING = '08' THEN 45878118
	WHEN SMOKING = 'NI' THEN 44814650
	WHEN SMOKING = 'UN' THEN 44814653
	WHEN SMOKING = 'OT' THEN 44814649
	WHEN SMOKING = '' THEN 44814653 END,

	d.visit_occurrence_id,

	CASE 
	WHEN SMOKING IS NOT NULL THEN 'SMOKING' END,

	CASE
	WHEN SMOKING IS NOT NULL THEN 40766362 END,

	0

FROM PCORnet.dbo.VITAL a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID
WHERE SMOKING IS NOT NULL;









/*Insert tobacco value to observation table.*/
INSERT INTO OMOP.dbo.observation(
	observation_id, person_id, observation_concept_id, observation_date, observation_datetime, 
	observation_type_concept_id, value_as_concept_id, visit_occurrence_id, observation_source_value, observation_source_concept_id,
	obs_event_field_concept_id)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(observation_id),0) FROM OMOP.dbo.observation),

	b.person_id,

	CASE
	WHEN TOBACCO IS NOT NULL THEN 4041306 END,

	cast(MEASURE_DATE as date),

	CASE
	WHEN MEASURE_DATE IS NOT NULL THEN MEASURE_DATE + ' ' + MEASURE_TIME
	WHEN MEASURE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN VITAL_SOURCE = 'PR' THEN 32865
	WHEN VITAL_SOURCE = 'PD' THEN 4181515
	WHEN VITAL_SOURCE = 'HC' THEN 44819222
	WHEN VITAL_SOURCE = 'HD' THEN 4181515
	WHEN VITAL_SOURCE = 'DR' THEN 45754907
	WHEN VITAL_SOURCE = 'NI' THEN 44814650
	WHEN VITAL_SOURCE = 'UN' THEN 44814653
	WHEN VITAL_SOURCE = 'OT' THEN 44814649 
	WHEN VITAL_SOURCE = '' THEN 44814653
	WHEN VITAL_SOURCE is null THEN 44814653 END,

	CASE 
	WHEN TOBACCO = '01' THEN 36309332
	WHEN TOBACCO = '02' THEN 45883537
	WHEN TOBACCO = '03' THEN 36307819
	WHEN TOBACCO = '04' THEN 4184633
	WHEN TOBACCO = '06' THEN 45882295
	WHEN TOBACCO = 'NI' THEN 44814650
	WHEN TOBACCO = 'UN' THEN 44814653
	WHEN TOBACCO = 'OT' THEN 44814649
	WHEN TOBACCO = '' THEN 44814653
	END,

	d.visit_occurrence_id,

	CASE 
	WHEN TOBACCO IS NOT NULL THEN 'TOBACCO' END,

	CASE
	WHEN TOBACCO IS NOT NULL THEN 4041306 END,

	0

FROM PCORnet.dbo.VITAL a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID
WHERE TOBACCO IS NOT NULL;









/*Insert tobacco type value to observation table.*/
INSERT INTO OMOP.dbo.observation(
	observation_id, person_id, observation_concept_id, observation_date, observation_datetime, 
	observation_type_concept_id, value_as_concept_id, visit_occurrence_id, observation_source_value, observation_source_concept_id,
	obs_event_field_concept_id)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(observation_id),0) FROM OMOP.dbo.observation),

	b.person_id,

	CASE
	WHEN TOBACCO_TYPE IS NOT NULL THEN 42528924 END,

	cast(MEASURE_DATE as date),

	CASE
	WHEN MEASURE_DATE IS NOT NULL THEN MEASURE_DATE + ' ' + MEASURE_TIME
	WHEN MEASURE_DATE IS NULL THEN '1900-01-01 00:00:00.000' END,

	CASE
	WHEN VITAL_SOURCE = 'PR' THEN 32865
	WHEN VITAL_SOURCE = 'PD' THEN 4181515
	WHEN VITAL_SOURCE = 'HC' THEN 44819222
	WHEN VITAL_SOURCE = 'HD' THEN 4181515
	WHEN VITAL_SOURCE = 'DR' THEN 45754907
	WHEN VITAL_SOURCE = 'NI' THEN 44814650
	WHEN VITAL_SOURCE = 'UN' THEN 44814653
	WHEN VITAL_SOURCE = 'OT' THEN 44814649 
	WHEN VITAL_SOURCE = '' THEN 44814653
	WHEN VITAL_SOURCE is null THEN 44814653 END,

	CASE 
	WHEN TOBACCO_TYPE = '01' THEN 42530793
	WHEN TOBACCO_TYPE = '02' THEN 42531042
	WHEN TOBACCO_TYPE = '03' THEN 42531020
	WHEN TOBACCO_TYPE = '04' THEN 45878582
	WHEN TOBACCO_TYPE = '05' THEN 42530756
	WHEN TOBACCO_TYPE = 'NI' THEN 46237210
	WHEN TOBACCO_TYPE = 'UN' THEN 45877986
	WHEN TOBACCO_TYPE = 'OT' THEN 45878142
	WHEN TOBACCO_TYPE = '' THEN 45877986
	END,

	d.visit_occurrence_id,

	CASE 
	WHEN TOBACCO_TYPE IS NOT NULL THEN 'TOBACCO_TYPE' END,

	CASE
	WHEN TOBACCO_TYPE IS NOT NULL THEN 42528924 END,

	0

FROM PCORnet.dbo.VITAL a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
ON a.ENCOUNTERID = d.ENCOUNTERID
WHERE TOBACCO_TYPE IS NOT NULL;














	
