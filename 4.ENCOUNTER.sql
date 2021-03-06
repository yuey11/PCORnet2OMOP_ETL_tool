/*This file used to transform PCORnet ENCOUNTER table into the OMOP visit_occurrence, location and care_site table.*/
/*TRUNCATE TABLE OMOP.dbo.visit_occurrence;*/
/*TRUNCATE TABLE OMOP.dbo.location;*/
/*TRUNCATE TABLE OMOP.dbo.care_site;*/

/*Please run the Provider table ETL code first!!*/

/*Create location_id in the OMOP location table.*/
INSERT INTO OMOP.dbo.location(
	location_id, zip, location_source_value)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(location_id),0) FROM OMOP.dbo.location),
	FACILITY_LOCATION,
	FACILITY_LOCATION
FROM PCORnet.dbo.ENCOUNTER
GROUP BY FACILITY_LOCATION;

/*Create care_site_id in the OMOP care_site table.*/
INSERT INTO OMOP.dbo.care_site(
	care_site_id, care_site_name, place_of_service_concept_id, location_id, 
	care_site_source_value, place_of_service_source_value)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(care_site_id),0) FROM OMOP.dbo.care_site),
	FACILITYID,
	0,
	b.location_id,
	FACILITYID,
	FACILITY_TYPE
FROM PCORnet.dbo.ENCOUNTER a, OMOP.dbo.location b
WHERE a.FACILITY_LOCATION = b.location_source_value
GROUP BY FACILITYID, FACILITY_TYPE, b.location_id;

UPDATE OMOP.dbo.care_site 
SET place_of_service_concept_id  =
CASE
	WHEN place_of_service_source_value = 'ADULT_DAY_CARE_CENTER' THEN 4184853
	WHEN place_of_service_source_value = 'AMBULANCE_BASED_CARE' THEN 4014812
	WHEN place_of_service_source_value = 'AMBULATORY_CARE_SITE_OTHER' THEN 4262840
	WHEN place_of_service_source_value = 'AMBULATORY_SURGERY_CENTER' THEN 4236737
	WHEN place_of_service_source_value = 'CARE_OF_THE_ELDERLY_DAY_HOSPITAL' THEN 4148493
	WHEN place_of_service_source_value = 'CHILD_DAY_CARE_CENTER' THEN 4186892
	WHEN place_of_service_source_value = 'CONTAINED_CASUALTY_SETTING' THEN 4260063
	WHEN place_of_service_source_value = 'DIALYSIS_UNIT_HOSPITAL' THEN 763147
	WHEN place_of_service_source_value = 'ELDERLY_ASSESSMENT_CLINIC' THEN 4076899
	WHEN place_of_service_source_value = 'EMERGENCY_DEPARTMENT_HOSPITAL' THEN 42627881
	WHEN place_of_service_source_value = 'FEE_FOR_SERVICE_PRIVATE_PHYSICIANS_GROUP_OFFICE' THEN 4024102
	WHEN place_of_service_source_value = 'FREE_STANDING_AMBULATORY_SURGERY_FACILITY' THEN 4022507
	WHEN place_of_service_source_value = 'FREE_STANDING_BIRTHING_CENTER' THEN 4239088
	WHEN place_of_service_source_value = 'FREE_STANDING_GERIATRIC_HEALTH_CENTER' THEN 4216447
	WHEN place_of_service_source_value = 'FREE_STANDING_LABORATORY_FACILITY' THEN 4262104
	WHEN place_of_service_source_value = 'FREE_STANDING_MENTAL_HEALTH_CENTER' THEN 4201419
	WHEN place_of_service_source_value = 'FREE_STANDING_RADIOLOGY_FACILITY' THEN 4071621
	WHEN place_of_service_source_value = 'HEALTH_ENCOUNTER_SITE_NOT_LISTED' THEN 4192764
	WHEN place_of_service_source_value = 'HEALTH_MAINTENANCE_ORGANIZATION' THEN 4217012
	WHEN place_of_service_source_value = 'HELICOPTER_BASED_CARE' THEN 4234093
	WHEN place_of_service_source_value = 'HOSPICE_FACILITY' THEN 42628597
	WHEN place_of_service_source_value = 'HOSPITAL_BASED_OUTPATIENT_CLINIC_OR_DEPARTMENT_OTHER' THEN 0
	WHEN place_of_service_source_value = 'HOSPITAL_CHILDRENS' THEN 4305507
	WHEN place_of_service_source_value = 'HOSPITAL_COMMUNITY' THEN 4021523
	WHEN place_of_service_source_value = 'HOSPITAL_GOVERNMENT' THEN 4195901
	WHEN place_of_service_source_value = 'HOSPITAL_LONG_TERM_CARE' THEN 4137296
	WHEN place_of_service_source_value = 'HOSPITAL_MILITARY_FIELD' THEN 4182729
	WHEN place_of_service_source_value = 'HOSPITAL_PRISON' THEN 4076511
	WHEN place_of_service_source_value = 'HOSPITAL_PSYCHIATRIC' THEN 4268912
	WHEN place_of_service_source_value = 'HOSPITAL_REHABILITATION' THEN 4213182
	WHEN place_of_service_source_value = 'HOSPITAL_TRAUMA_CENTER' THEN 4263098
	WHEN place_of_service_source_value = 'HOSPITAL_VETERANS_ADMINISTRATION' THEN 4167525
	WHEN place_of_service_source_value = 'HOSPITAL_AMBULATORY_SURGERY_FACILITY' THEN 4239665
	WHEN place_of_service_source_value = 'HOSPITAL_BIRTHING_CENTER' THEN 4199606
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_ALLERGY_CLINIC' THEN 4233864
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_DENTAL_CLINIC' THEN 4009124
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_DERMATOLOGY_CLINIC' THEN 4291308
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_ENDOCRINOLOGY_CLINIC' THEN 4252101
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_FAMILY_MEDICINE_CLINIC' THEN 4135228
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_GASTROENTEROLOGY_CLINIC' THEN 4242280
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_GENERAL_SURGERY_CLINIC' THEN 4236039
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_GERIATRIC_HEALTH_CENTER' THEN 4055912
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_GYNECOLOGY_CLINIC' THEN 4330868
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_HEMATOLOGY_CLINIC' THEN 4209422
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_IMMUNOLOGY_CLINIC' THEN 4236674
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_INFECTIOUS_DISEASE_CLINIC' THEN 4155183
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_MENTAL_HEALTH_CENTER' THEN 4032930
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_NEUROLOGY_CLINIC' THEN 4244378
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_OBSTETRICAL_CLINIC' THEN 4210450
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_ONCOLOGY_CLINIC' THEN 4233354
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_OPHTHALMOLOGY_CLINIC' THEN 4299943
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_ORTHOPEDICS_CLINIC' THEN 4301489
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_OTORHINOLARYNGOLOGY_CLINIC' THEN 4051781
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_PAIN_CLINIC' THEN 4265287
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_PEDIATRIC_CLINIC' THEN 4290359
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_PERIPHERAL_VASCULAR_CLINIC' THEN 4184130
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_REHABILITATION_CLINIC' THEN 4293009
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_RESPIRATORY_DISEASE_CLINIC' THEN 4237309
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_RHEUMATOLOGY_CLINIC' THEN 4141300
	WHEN place_of_service_source_value = 'HOSPITAL_OUTPATIENT_UROLOGY_CLINIC' THEN 4196700
	WHEN place_of_service_source_value = 'HOSPITAL_RADIOLOGY_FACILITY' THEN 4194202
	WHEN place_of_service_source_value = 'HOSPITAL_SHIP' THEN 4049639
	WHEN place_of_service_source_value = 'INDEPENDENT_AMBULATORY_CARE_PROVIDER_SITE_OTHER' THEN 4214691
	WHEN place_of_service_source_value = 'LOCAL_COMMUNITY_HEALTH_CENTER' THEN 4238722
	WHEN place_of_service_source_value = 'NURSING_HOME' THEN 45496309
	WHEN place_of_service_source_value = 'PRIVATE_PHYSICIANS_GROUP_OFFICE' THEN 4214465
	WHEN place_of_service_source_value = 'PRIVATE_RESIDENTIAL_HOME' THEN 764901
	WHEN place_of_service_source_value = 'PSYCHOGERIATRIC_DAY_HOSPITAL' THEN 4147082
	WHEN place_of_service_source_value = 'RESIDENTIAL_INSTITUTION' THEN 764901
	WHEN place_of_service_source_value = 'RESIDENTIAL_SCHOOL_INFIRMARY' THEN 4220654
	WHEN place_of_service_source_value = 'RURAL_HEALTH_CENTER' THEN 4299787
	WHEN place_of_service_source_value = 'SEXUALLY_TRANSMITTED_DISEASE_HEALTH_CENTER' THEN 4105698
	WHEN place_of_service_source_value = 'SKILLED_NURSING_FACILITY' THEN 4164912
	WHEN place_of_service_source_value = 'SOLO_PRACTICE_PRIVATE_OFFICE' THEN 4222172
	WHEN place_of_service_source_value = 'SPORTS_FACILITY' THEN 45765876
	WHEN place_of_service_source_value = 'SUBSTANCE_ABUSE_TREATMENT_CENTER' THEN 4061738
	WHEN place_of_service_source_value = 'TRAVELERS_AID_CLINIC' THEN 4245026
	WHEN place_of_service_source_value = 'VACCINATION_CLINIC' THEN 4263744
	WHEN place_of_service_source_value = 'WALK_IN_CLINIC' THEN 4217918
	WHEN place_of_service_source_value = 'NI' THEN 44814650
	WHEN place_of_service_source_value = 'UN' THEN 44814653
	WHEN place_of_service_source_value = 'OT' THEN 44814649
	WHEN place_of_service_source_value = '' THEN 44814653
	WHEN place_of_service_source_value is null THEN 44814653 END
WHERE place_of_service_source_value IN ('ADULT_DAY_CARE_CENTER','AMBULANCE_BASED_CARE','AMBULATORY_CARE_SITE_OTHER','AMBULATORY_SURGERY_CENTER','CARE_OF_THE_ELDERLY_DAY_HOSPITAL','CHILD_DAY_CARE_CENTER','CONTAINED_CASUALTY_SETTING','DIALYSIS_UNIT_HOSPITAL','ELDERLY_ASSESSMENT_CLINIC','EMERGENCY_DEPARTMENT_HOSPITAL','FEE_FOR_SERVICE_PRIVATE_PHYSICIANS_GROUP_OFFICE','FREE_STANDING_AMBULATORY_SURGERY_FACILITY','FREE_STANDING_BIRTHING_CENTER','FREE_STANDING_GERIATRIC_HEALTH_CENTER','FREE_STANDING_LABORATORY_FACILITY','FREE_STANDING_MENTAL_HEALTH_CENTER','FREE_STANDING_RADIOLOGY_FACILITY','HEALTH_ENCOUNTER_SITE_NOT_LISTED','HEALTH_MAINTENANCE_ORGANIZATION','HELICOPTER_BASED_CARE','HOSPICE_FACILITY','HOSPITAL_BASED_OUTPATIENT_CLINIC_OR_DEPARTMENT_OTHER','HOSPITAL_CHILDRENS','HOSPITAL_COMMUNITY','HOSPITAL_GOVERNMENT','HOSPITAL_LONG_TERM_CARE','HOSPITAL_MILITARY_FIELD','HOSPITAL_PRISON','HOSPITAL_PSYCHIATRIC','HOSPITAL_REHABILITATION','HOSPITAL_TRAUMA_CENTER','HOSPITAL_VETERANS_ADMINISTRATION','HOSPITAL_AMBULATORY_SURGERY_FACILITY','HOSPITAL_BIRTHING_CENTER','HOSPITAL_OUTPATIENT_ALLERGY_CLINIC','HOSPITAL_OUTPATIENT_DENTAL_CLINIC','HOSPITAL_OUTPATIENT_DERMATOLOGY_CLINIC','HOSPITAL_OUTPATIENT_ENDOCRINOLOGY_CLINIC','HOSPITAL_OUTPATIENT_FAMILY_MEDICINE_CLINIC','HOSPITAL_OUTPATIENT_GASTROENTEROLOGY_CLINIC','HOSPITAL_OUTPATIENT_GENERAL_SURGERY_CLINIC','HOSPITAL_OUTPATIENT_GERIATRIC_HEALTH_CENTER','HOSPITAL_OUTPATIENT_GYNECOLOGY_CLINIC','HOSPITAL_OUTPATIENT_HEMATOLOGY_CLINIC','HOSPITAL_OUTPATIENT_IMMUNOLOGY_CLINIC','HOSPITAL_OUTPATIENT_INFECTIOUS_DISEASE_CLINIC','HOSPITAL_OUTPATIENT_MENTAL_HEALTH_CENTER','HOSPITAL_OUTPATIENT_NEUROLOGY_CLINIC','HOSPITAL_OUTPATIENT_OBSTETRICAL_CLINIC','HOSPITAL_OUTPATIENT_ONCOLOGY_CLINIC','HOSPITAL_OUTPATIENT_OPHTHALMOLOGY_CLINIC','HOSPITAL_OUTPATIENT_ORTHOPEDICS_CLINIC','HOSPITAL_OUTPATIENT_OTORHINOLARYNGOLOGY_CLINIC','HOSPITAL_OUTPATIENT_PAIN_CLINIC','HOSPITAL_OUTPATIENT_PEDIATRIC_CLINIC','HOSPITAL_OUTPATIENT_PERIPHERAL_VASCULAR_CLINIC','HOSPITAL_OUTPATIENT_REHABILITATION_CLINIC','HOSPITAL_OUTPATIENT_RESPIRATORY_DISEASE_CLINIC','HOSPITAL_OUTPATIENT_RHEUMATOLOGY_CLINIC','HOSPITAL_OUTPATIENT_UROLOGY_CLINIC','HOSPITAL_RADIOLOGY_FACILITY','HOSPITAL_SHIP','INDEPENDENT_AMBULATORY_CARE_PROVIDER_SITE_OTHER','LOCAL_COMMUNITY_HEALTH_CENTER','NURSING_HOME','PRIVATE_PHYSICIANS_GROUP_OFFICE','PRIVATE_RESIDENTIAL_HOME','PSYCHOGERIATRIC_DAY_HOSPITAL','RESIDENTIAL_INSTITUTION','RESIDENTIAL_SCHOOL_INFIRMARY','RURAL_HEALTH_CENTER','SEXUALLY_TRANSMITTED_DISEASE_HEALTH_CENTER','SKILLED_NURSING_FACILITY','SOLO_PRACTICE_PRIVATE_OFFICE','SPORTS_FACILITY','SUBSTANCE_ABUSE_TREATMENT_CENTER','TRAVELERS_AID_CLINIC','VACCINATION_CLINIC','WALK_IN_CLINIC','NI','UN','OT');

/* Creating a new table to save the mapping between PCORnet ENCOUNTERID and OMOP visit_occurrence_id. 
It will be used for matching the visit_occurrence_id with condition_occurrence_id while the DIAGNOSIS table ETL.*/
/*TRUNCATE TABLE OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping;*/

CREATE TABLE OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping
(
ENCOUNTERID varchar(50),
visit_occurrence_id bigint
)

INSERT INTO OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping(visit_occurrence_id, ENCOUNTERID)
SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(visit_occurrence_id),0) FROM OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping),
	a.ENCOUNTERID

FROM PCORnet.dbo.ENCOUNTER a  
ORDER BY a.ENCOUNTERID


/*PCORnet_ENCOUNTER_table transformation*/
INSERT INTO OMOP.dbo.visit_occurrence(
	visit_occurrence_id, person_id, visit_concept_id, visit_start_date, visit_start_datetime, visit_end_date,
	visit_end_datetime, visit_type_concept_id, provider_id, care_site_id, visit_source_value, 
	visit_source_concept_id, admitted_from_concept_id, admitted_from_source_value, discharge_to_concept_id, discharge_to_source_value)
SELECT 
	
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(visit_occurrence_id),0) FROM OMOP.dbo.visit_occurrence),

	b.person_id,

	CASE
	WHEN ENC_TYPE = 'AV' THEN 38004207
	WHEN ENC_TYPE = 'ED' THEN 9203
	WHEN ENC_TYPE = 'EI' THEN 262
	WHEN ENC_TYPE = 'IP' THEN 9201
	WHEN ENC_TYPE = 'IS' THEN 44814710
	WHEN ENC_TYPE = 'OS' THEN 581385
	WHEN ENC_TYPE = 'IC' THEN 4127751
	WHEN ENC_TYPE = 'OA' THEN 44814711
	WHEN ENC_TYPE = 'NI' THEN 44814650
	WHEN ENC_TYPE = 'UN' THEN 44814653
	WHEN ENC_TYPE = 'OT' THEN 44814649
	WHEN ENC_TYPE = '' THEN 44814653
	WHEN ENC_TYPE IS NULL THEN 44814653 END,

	cast(ADMIT_DATE as date),

	CASE 
	WHEN ADMIT_DATE IS NULL THEN '1900-01-01 00:00:00.000'
	WHEN ADMIT_DATE IS NOT NULL AND ADMIT_TIME IS NULL THEN ADMIT_DATE	
	WHEN ADMIT_DATE IS NOT NULL AND ADMIT_TIME IS NOT NULL THEN CONVERT(datetime, CONVERT(char(8),cast(ADMIT_DATE as date),112)+ ' ' + CONVERT(char(8),cast(ADMIT_TIME as time),108)) END,

	cast(DISCHARGE_DATE as date),

	CASE
	WHEN DISCHARGE_DATE IS NULL THEN '1900-01-01 00:00:00.000'
	WHEN DISCHARGE_DATE IS NOT NULL AND DISCHARGE_TIME IS NULL THEN DISCHARGE_DATE
	WHEN DISCHARGE_DATE IS NOT NULL AND DISCHARGE_TIME IS NOT NULL THEN CONVERT(datetime, CONVERT(char(8),cast(DISCHARGE_DATE as date),112)+ ' ' + CONVERT(char(8),cast(DISCHARGE_TIME as time),108)) END,

	32035,

	c.provider_id,

	e.care_site_id,

	ENC_TYPE,

	CASE
	WHEN ENC_TYPE = 'AV' THEN 44814708
	WHEN ENC_TYPE = 'ED' THEN 44814709
	WHEN ENC_TYPE = 'EI' THEN 262
	WHEN ENC_TYPE = 'IP' THEN 44814707
	WHEN ENC_TYPE = 'IS' THEN 44814710
	WHEN ENC_TYPE = 'OS' THEN 581385
	WHEN ENC_TYPE = 'IC' THEN 4127751
	WHEN ENC_TYPE = 'OA' THEN 44814711
	WHEN ENC_TYPE = 'NI' THEN 44814650
	WHEN ENC_TYPE = 'UN' THEN 44814653
	WHEN ENC_TYPE = 'OT' THEN 44814649
	WHEN ENC_TYPE = '' THEN 44814653
	WHEN ENC_TYPE IS NULL THEN 44814653 END,

	CASE
	WHEN ADMITTING_SOURCE = 'AF' THEN 38004307 
	WHEN ADMITTING_SOURCE = 'AL' THEN 8615 
	WHEN ADMITTING_SOURCE = 'AV' THEN 38004207
	WHEN ADMITTING_SOURCE = 'ED' THEN 9203
	WHEN ADMITTING_SOURCE = 'HH' THEN 38004519
	WHEN ADMITTING_SOURCE = 'HO' THEN 581476
	WHEN ADMITTING_SOURCE = 'HS' THEN 8546
	WHEN ADMITTING_SOURCE = 'IP' THEN 38004279
	WHEN ADMITTING_SOURCE = 'NH' THEN 38004198
	WHEN ADMITTING_SOURCE = 'RH' THEN 38004526
	WHEN ADMITTING_SOURCE = 'RS' THEN 32277
	WHEN ADMITTING_SOURCE = 'SN' THEN 8863
	WHEN ADMITTING_SOURCE = 'IH' THEN 8717
	WHEN ADMITTING_SOURCE = 'NI' THEN 44814650
	WHEN ADMITTING_SOURCE = 'UN' THEN 44814653
	WHEN ADMITTING_SOURCE = 'OT' THEN 44814649
	WHEN ADMITTING_SOURCE = '' THEN 44814653
	WHEN ADMITTING_SOURCE IS NULL THEN 44814653 END,

	ADMITTING_SOURCE,

	CASE
	WHEN DISCHARGE_DISPOSITION = 'A' THEN 4161979 
	WHEN DISCHARGE_DISPOSITION = 'E' THEN 4216643 
	WHEN DISCHARGE_DISPOSITION = 'NI' THEN 44814650
	WHEN DISCHARGE_DISPOSITION = 'UN' THEN 44814653
	WHEN DISCHARGE_DISPOSITION = 'OT' THEN 44814649
	WHEN DISCHARGE_DISPOSITION = '' THEN 44814653
	WHEN DISCHARGE_DISPOSITION IS NULL THEN 44814653 END,

	DISCHARGE_DISPOSITION

FROM PCORnet.dbo.ENCOUNTER a  
LEFT JOIN OMOP.dbo.person b
ON a.PATID = b.person_source_value
LEFT JOIN OMOP.dbo.provider c
ON a.PROVIDERID = c.provider_source_value
LEFT JOIN OMOP.dbo.location d
ON a.FACILITY_LOCATION = d.zip
LEFT JOIN OMOP.dbo.care_site e
ON a.FACILITYID = e.care_site_name and d.location_id = e.location_id
ORDER BY a.ENCOUNTERID;






