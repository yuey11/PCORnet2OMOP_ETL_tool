/*This file used to transform PCORnet DEMOGRAPHIC table into the OMOP PERSON table.
  Please firstly run this file ahead of all of the other files.*/
/*TRUNCATE TABLE OMOP.dbo.person;*/

/*Data transformation*/
INSERT INTO OMOP.dbo.person(person_id, gender_concept_id, year_of_birth, month_of_birth, day_of_birth, birth_datetime,
race_concept_id, ethnicity_concept_id, person_source_value, gender_source_value, 
gender_source_concept_id, race_source_value, race_source_concept_id, ethnicity_source_value, ethnicity_source_concept_id)
SELECT 
	
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(person_id),0) FROM OMOP.dbo.person),
	
	CASE 
	WHEN SEX = 'A' THEN 8570 
	WHEN SEX = 'F' THEN 8532 
	WHEN SEX = 'M' THEN 8507
	WHEN SEX = 'NI' THEN 8551
	WHEN SEX = 'UN' THEN 8551
	WHEN SEX = 'OT' THEN 8521
	WHEN SEX = '' THEN 8551
	WHEN SEX IS NULL THEN 8551 END,

	CASE
	WHEN BIRTH_DATE IS NOT NULL THEN YEAR(BIRTH_DATE)
	WHEN BIRTH_DATE IS NULL THEN YEAR(1900) END,

	MONTH(BIRTH_DATE),

	DAY(BIRTH_DATE),

	CASE
 	WHEN [BIRTH_DATE] IS NULL THEN '1900-01-01 00:00:00.000'
 	WHEN [BIRTH_DATE] IS NOT NULL AND [BIRTH_TIME] IS NULL THEN [BIRTH_DATE]
 	WHEN [BIRTH_DATE] IS NOT NULL AND [BIRTH_TIME] IS NOT NULL THEN CONVERT(datetime, CONVERT(char(8),cast([BIRTH_DATE] as date),112)+ ' ' + CONVERT(char(8),cast([BIRTH_TIME] as time),108)) END,
 

	CASE
	WHEN RACE = '01' THEN 8657
	WHEN RACE = '02' THEN 8515
	WHEN RACE = '03' THEN 8516
	WHEN RACE = '04' THEN 8557
	WHEN RACE = '05' THEN 8527
	WHEN RACE = '06' THEN 8522
	WHEN RACE = '07' THEN 8552
	WHEN RACE = 'NI' THEN 8552
	WHEN RACE = 'UN' THEN 8552
	WHEN RACE = 'OT' THEN 8522
	WHEN RACE = '' THEN 8552
	WHEN RACE IS NULL THEN 8552 END,
	
	CASE
	WHEN HISPANIC = 'Y' THEN 38003563
	WHEN HISPANIC = 'N' THEN 38003564
	WHEN HISPANIC = 'R' THEN 8552
	WHEN HISPANIC = 'NI' THEN 8552
	WHEN HISPANIC = 'UN' THEN 8552
	WHEN HISPANIC = 'OT' THEN 8522
	WHEN HISPANIC = '' THEN 8552
	WHEN HISPANIC IS NULL THEN 8552 END,

	PATID,

	SEX,

	CASE 
	WHEN SEX = 'A' THEN 44814664 
	WHEN SEX = 'F' THEN 44814665 
	WHEN SEX = 'M' THEN 44814666
	WHEN SEX = 'NI' THEN 44814650
	WHEN SEX = 'UN' THEN 44814653
	WHEN SEX = 'OT' THEN 44814649
	WHEN SEX = '' THEN 44814653 
	WHEN SEX IS NULL THEN 44814653 END,

	RACE,

	CASE
	WHEN RACE = '01' THEN 44814654
	WHEN RACE = '02' THEN 44814655
	WHEN RACE = '03' THEN 44814656
	WHEN RACE = '04' THEN 44814657
	WHEN RACE = '05' THEN 44814658
	WHEN RACE = '06' THEN 44814659
	WHEN RACE = '07' THEN 44814660
	WHEN RACE = 'NI' THEN 44814650
	WHEN RACE = 'UN' THEN 44814653
	WHEN RACE = 'OT' THEN 44814649 
	WHEN RACE = '' THEN 44814653
	WHEN RACE IS NULL THEN 44814653 END,
	
	HISPANIC,

	CASE
	WHEN HISPANIC = 'Y' THEN 44814651
	WHEN HISPANIC = 'N' THEN 44814652
	WHEN HISPANIC = 'R' THEN 44814660
	WHEN HISPANIC = 'NI' THEN 44814650
	WHEN HISPANIC = 'UN' THEN 44814653
	WHEN HISPANIC = 'OT' THEN 44814649 
	WHEN HISPANIC = '' THEN 44814653
	WHEN HISPANIC IS NULL THEN 44814653 END

FROM PCORnet.dbo.DEMOGRAPHIC





