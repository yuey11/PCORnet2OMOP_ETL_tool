/*This file used to transform PCORnet OBS_GEN table into the OMOP observation table.*/
/*TRUNCATE TABLE OMOP.dbo.observation;*/
/*Please run the ENCOUNTER table ETL code first!!*/
/*Please run the PROVIDER table ETL code first!!*/

INSERT INTO OMOP.dbo.observation(
	observation_id, person_id, observation_concept_id, observation_date, observation_datetime, 
	observation_type_concept_id, value_as_number, value_as_string, value_as_concept_id, qualifier_concept_id,
	unit_concept_id, provider_id, visit_occurrence_id, observation_source_value, observation_source_concept_id, 
	unit_source_value, qualifier_source_value, obs_event_field_concept_id)

SELECT 
	ROW_NUMBER() OVER (order by (select 1))+ (SELECT COALESCE(MAX(observation_id),0) FROM OMOP.dbo.observation),

	b.person_id,

	0,

	cast(OBSGEN_DATE as date),

	CASE
	WHEN OBSGEN_DATE IS NULL THEN '1900-01-01 00:00:00.000'
	WHEN OBSGEN_DATE IS NOT NULL AND OBSGEN_TIME IS NULL THEN OBSGEN_DATE	
	WHEN OBSGEN_DATE IS NOT NULL AND OBSGEN_TIME IS NOT NULL THEN CONVERT(datetime, CONVERT(char(8),cast(OBSGEN_DATE as date),112)+ ' ' + CONVERT(char(8),cast(OBSGEN_TIME as time),108)) END,

	CASE
	WHEN OBSGEN_SOURCE = 'OD' THEN 38000280
	WHEN OBSGEN_SOURCE = 'BI' THEN 38000280
	WHEN OBSGEN_SOURCE = 'CL' THEN 32467
	WHEN OBSGEN_SOURCE = 'RG' THEN 38000280
	WHEN OBSGEN_SOURCE = 'DR' THEN 32445
	WHEN OBSGEN_SOURCE = 'NI' THEN 44814650
	WHEN OBSGEN_SOURCE = 'UN' THEN 44814653
	WHEN OBSGEN_SOURCE = 'OT' THEN 44814649 
	WHEN OBSGEN_SOURCE = '' THEN 44814653
	WHEN OBSGEN_SOURCE is null THEN 44814653 END,
	
	OBSGEN_RESULT_NUM,

	OBSGEN_RESULT_TEXT,

	CASE
	WHEN OBSGEN_RESULT_QUAL = 'POSITIVE' THEN 9191
	WHEN OBSGEN_RESULT_QUAL = 'NEGATIVE' THEN 9189
	WHEN OBSGEN_RESULT_QUAL = 'BORDERLINE' THEN 4162852
	WHEN OBSGEN_RESULT_QUAL = 'ELEVATED' THEN 4328749
	WHEN OBSGEN_RESULT_QUAL = 'HIGH' THEN 4328749
	WHEN OBSGEN_RESULT_QUAL = 'LOW' THEN 4267416
	WHEN OBSGEN_RESULT_QUAL = 'NORMAL' THEN 4124457
	WHEN OBSGEN_RESULT_QUAL = 'ABNORMAL' THEN 4183448
	WHEN OBSGEN_RESULT_QUAL = 'UNDETERMINED' THEN 4160775
	WHEN OBSGEN_RESULT_QUAL = 'UNDETECTABLE' THEN 44814653
	WHEN OBSGEN_RESULT_QUAL = 'NI' THEN 44814650
	WHEN OBSGEN_RESULT_QUAL = 'UN' THEN 44814653
	WHEN OBSGEN_RESULT_QUAL = 'OT' THEN 44814649
	WHEN OBSGEN_RESULT_QUAL = '' THEN 44814653 END,

	CASE
	WHEN OBSGEN_RESULT_QUAL = 'POSITIVE' THEN 9191
	WHEN OBSGEN_RESULT_QUAL = 'NEGATIVE' THEN 9189
	WHEN OBSGEN_RESULT_QUAL = 'BORDERLINE' THEN 4162852
	WHEN OBSGEN_RESULT_QUAL = 'ELEVATED' THEN 4328749
	WHEN OBSGEN_RESULT_QUAL = 'HIGH' THEN 4328749
	WHEN OBSGEN_RESULT_QUAL = 'LOW' THEN 4267416
	WHEN OBSGEN_RESULT_QUAL = 'NORMAL' THEN 4124457
	WHEN OBSGEN_RESULT_QUAL = 'ABNORMAL' THEN 4183448
	WHEN OBSGEN_RESULT_QUAL = 'UNDETERMINED' THEN 4160775
	WHEN OBSGEN_RESULT_QUAL = 'UNDETECTABLE' THEN 44814653
	WHEN OBSGEN_RESULT_MODIFIER = 'EQ' THEN 4172703
	WHEN OBSGEN_RESULT_MODIFIER = 'GE' THEN 4171755
	WHEN OBSGEN_RESULT_MODIFIER = 'GT' THEN 4172704
	WHEN OBSGEN_RESULT_MODIFIER = 'LE' THEN 4171754
	WHEN OBSGEN_RESULT_MODIFIER = 'LT' THEN 4171756
	WHEN OBSGEN_RESULT_MODIFIER = 'TX' THEN 44814649
	WHEN OBSGEN_RESULT_QUAL = 'NI' THEN 44814650
	WHEN OBSGEN_RESULT_QUAL = 'UN' THEN 44814653
	WHEN OBSGEN_RESULT_QUAL = 'OT' THEN 44814649
	WHEN OBSGEN_RESULT_QUAL = '' THEN 44814653 END,

	0,

	c.provider_id,

	d.visit_occurrence_id,

	OBSGEN_CODE,

	0,

	OBSGEN_RESULT_UNIT,

	CASE 
	WHEN OBSGEN_RESULT_QUAL IS NOT NULL THEN OBSGEN_RESULT_QUAL
	WHEN OBSGEN_RESULT_MODIFIER IS NOT NULL THEN OBSGEN_RESULT_MODIFIER END,

	0

	FROM PCORnet.dbo.OBS_GEN a  
	LEFT JOIN OMOP.dbo.person b
	ON a.PATID = b.person_source_value
	LEFT JOIN OMOP.dbo.provider c
	ON a.OBSGEN_PROVIDERID = c.provider_source_value
	LEFT JOIN OMOP.dbo.ENCOUNTERID_visit_occurrence_id_mapping d
	ON a.ENCOUNTERID = d.ENCOUNTERID;



/*Fill the observation_source_concept_id value.*/
UPDATE OMOP.dbo.observation 
SET observation_source_concept_id = b.concept_id
FROM OMOP.dbo.observation a, OMOP.dbo.concept b
WHERE a.observation_source_value = b.concept_code 
and observation_source_concept_id = 0;


/*Fill the observation_concept_id value.*/
UPDATE OMOP.dbo.observation
SET observation_concept_id = b.concept_id_2
FROM OMOP.dbo.concept_relationship b
WHERE observation_source_concept_id = b.concept_id_1 and relationship_id = 'Maps to'
and observation_concept_id = 0;

/*Fill the observation value.*/
UPDATE OMOP.dbo.observation
SET unit_concept_id = 
CASE
	WHEN unit_source_value = '[APL''U]' THEN	9099
	WHEN unit_source_value = '[APL''U]/mL' THEN	9156
	WHEN unit_source_value = '[arb''U]' THEN	9260
	WHEN unit_source_value = '[arb''U]/mL' THEN	8980
	WHEN unit_source_value = '[AU]' THEN	45744811
	WHEN unit_source_value = '[bdsk''U]' THEN	9262
	WHEN unit_source_value = '[beth''U]' THEN	9161
	WHEN unit_source_value = '[CFU]' THEN	9278
	WHEN unit_source_value = '[CFU]/mL' THEN	9423
	WHEN unit_source_value = '[Ch]' THEN	9279
	WHEN unit_source_value = '[cin_i]' THEN	9283
	WHEN unit_source_value = '[degF]' THEN	9289
	WHEN unit_source_value = '[dr_av]' THEN	9295
	WHEN unit_source_value = '[drp]' THEN	9296
	WHEN unit_source_value = '[foz_us]' THEN	9304
	WHEN unit_source_value = '[ft_i]' THEN	9306
	WHEN unit_source_value = '[gal_us]' THEN	9515
	WHEN unit_source_value = '[GPL''U]' THEN	9100
	WHEN unit_source_value = '[GPL''U]/mL' THEN	9157
	WHEN unit_source_value = '[in_i''H2O]' THEN	9328
	WHEN unit_source_value = '[in_i]' THEN	9327
	WHEN unit_source_value = '[IU]' THEN	8718
	WHEN unit_source_value = '[IU]/dL' THEN	9332
	WHEN unit_source_value = '[IU]/g' THEN	9333
	WHEN unit_source_value = '[IU]/g{Hb}' THEN	9334
	WHEN unit_source_value = '[IU]/h' THEN	9687
	WHEN unit_source_value = '[IU]/kg' THEN	9335
	WHEN unit_source_value = '[IU]/L' THEN	8923
	WHEN unit_source_value = '[IU]/mL' THEN	8985
	WHEN unit_source_value = '[ka''U]' THEN	9339
	WHEN unit_source_value = '[knk''U]' THEN	9342
	WHEN unit_source_value = '[mclg''U]' THEN	9358
	WHEN unit_source_value = '[mi_i]' THEN	9362
	WHEN unit_source_value = '[MPL''U]' THEN	9101
	WHEN unit_source_value = '[MPL''U]/mL' THEN	9158
	WHEN unit_source_value = '[oz_av]' THEN	9373
	WHEN unit_source_value = '[oz_tr]' THEN	9374
	WHEN unit_source_value = '[pH]' THEN	8482
	WHEN unit_source_value = '[ppb]' THEN	8703
	WHEN unit_source_value = '[ppm]' THEN	9387
	WHEN unit_source_value = '[ppth]' THEN	9154
	WHEN unit_source_value = '[pptr]' THEN	9155
	WHEN unit_source_value = '[psi]' THEN	9389
	WHEN unit_source_value = '[pt_us]' THEN	9391
	WHEN unit_source_value = '[qt_us]' THEN	9394
	WHEN unit_source_value = '[sft_i]' THEN	9403
	WHEN unit_source_value = '[sin_i]' THEN	9404
	WHEN unit_source_value = '[syd_i]' THEN	9411
	WHEN unit_source_value = '[tb''U]' THEN	9413
	WHEN unit_source_value = '[tbs_us]' THEN	9412
	WHEN unit_source_value = '[todd''U]' THEN	9415
	WHEN unit_source_value = '[tsp_us]' THEN	9416
	WHEN unit_source_value = '[yd_i]' THEN	9420
	WHEN unit_source_value = '{CAE''U}' THEN	8998
	WHEN unit_source_value = '{cells}' THEN	45744812
	WHEN unit_source_value = '{cells}/[HPF]' THEN	8889
	WHEN unit_source_value = '{cells}/uL' THEN	8784
	WHEN unit_source_value = '{copies}/mL' THEN	8799
	WHEN unit_source_value = '{CPM}' THEN	8483
	WHEN unit_source_value = '{Ehrlich''U}' THEN	8480
	WHEN unit_source_value = '{Ehrlich''U}/100.g' THEN	9425
	WHEN unit_source_value = '{Ehrlich''U}/dL' THEN	8829
	WHEN unit_source_value = '{EIA''U}' THEN	8556
	WHEN unit_source_value = '{ISR}' THEN	8488
	WHEN unit_source_value = '{JDF''U}' THEN	8560
	WHEN unit_source_value = '{M.o.M}' THEN	8494
	WHEN unit_source_value = '{ratio}' THEN	8523
	WHEN unit_source_value = '{RBC}/uL' THEN	9428
	WHEN unit_source_value = '{s_co_ratio}' THEN	8779
	WHEN unit_source_value = '{spermatozoa}/mL' THEN	9430
	WHEN unit_source_value = '{titer}' THEN	8525
	WHEN unit_source_value = '/[arb''U]' THEN	9235
	WHEN unit_source_value = '/[HPF]' THEN	8786
	WHEN unit_source_value = '/[LPF]' THEN	8765
	WHEN unit_source_value = '/{entity}' THEN	9236
	WHEN unit_source_value = '/10*10' THEN	9238
	WHEN unit_source_value = '/10*12' THEN	9239
	WHEN unit_source_value = '/10*12{RBCs}' THEN	9240
	WHEN unit_source_value = '/10*6' THEN	9241
	WHEN unit_source_value = '/10*9' THEN	9242
	WHEN unit_source_value = '/100' THEN	9243
	WHEN unit_source_value = '/100{spermatozoa}' THEN	9244
	WHEN unit_source_value = '/100{WBCs}' THEN	9032
	WHEN unit_source_value = '/a' THEN	44777560
	WHEN unit_source_value = '/dL' THEN	9245
	WHEN unit_source_value = '/g' THEN	9246
	WHEN unit_source_value = '/g{creat}' THEN	9247
	WHEN unit_source_value = '/g{Hb}' THEN	9248
	WHEN unit_source_value = '/g{tot_nit}' THEN	9249
	WHEN unit_source_value = '/g{tot_prot}' THEN	9250
	WHEN unit_source_value = '/g{wet_tis}' THEN	9251
	WHEN unit_source_value = '/h' THEN	44777557
	WHEN unit_source_value = '/kg' THEN	9252
	WHEN unit_source_value = '/L' THEN	9254
	WHEN unit_source_value = '/m2' THEN	9255
	WHEN unit_source_value = '/m3' THEN	44777558
	WHEN unit_source_value = '/mg' THEN	9256
	WHEN unit_source_value = '/min' THEN	8541
	WHEN unit_source_value = '/mL' THEN	9257
	WHEN unit_source_value = '/mo' THEN	44777658
	WHEN unit_source_value = '/s' THEN	44777659
	WHEN unit_source_value = '/uL' THEN	8647
	WHEN unit_source_value = '/wk' THEN	44777559
	WHEN unit_source_value = '%' THEN	8554
	WHEN unit_source_value = '%{abnormal}' THEN	9216
	WHEN unit_source_value = '%{activity}' THEN	8687
	WHEN unit_source_value = '%{bacteria}' THEN	9227
	WHEN unit_source_value = '%{basal_activity}' THEN	9217
	WHEN unit_source_value = '%{baseline}' THEN	8688
	WHEN unit_source_value = '%{binding}' THEN	9218
	WHEN unit_source_value = '%{blockade}' THEN	9219
	WHEN unit_source_value = '%{bound}' THEN	9220
	WHEN unit_source_value = '%{excretion}' THEN	9223
	WHEN unit_source_value = '%{Hb}' THEN	8737
	WHEN unit_source_value = '%{hemolysis}' THEN	9226
	WHEN unit_source_value = '%{inhibition}' THEN	8738
	WHEN unit_source_value = '%{pooled_plasma}' THEN	9681
	WHEN unit_source_value = '%{positive}' THEN	9231
	WHEN unit_source_value = '%{saturation}' THEN	8728
	WHEN unit_source_value = '%{total}' THEN	8632
	WHEN unit_source_value = '%{uptake}' THEN	8649
	WHEN unit_source_value = '%{vol}' THEN	9234
	WHEN unit_source_value = '%{WBCs}' THEN	9229
	WHEN unit_source_value = '10*12/L' THEN	8734
	WHEN unit_source_value = '10*3' THEN	8566
	WHEN unit_source_value = '10*3{copies}/mL' THEN	9437
	WHEN unit_source_value = '10*3{RBCs}' THEN	44777576
	WHEN unit_source_value = '10*3{RBCs}' THEN	9434
	WHEN unit_source_value = '10*3/L' THEN	9435
	WHEN unit_source_value = '10*3/mL' THEN	9436
	WHEN unit_source_value = '10*3/uL' THEN	8848
	WHEN unit_source_value = '10*4/uL' THEN	32706
	WHEN unit_source_value = '10*5' THEN	9438
	WHEN unit_source_value = '10*6' THEN	8549
	WHEN unit_source_value = '10*6/L' THEN	9442
	WHEN unit_source_value = '10*6/mL' THEN	8816
	WHEN unit_source_value = '10*6/uL' THEN	8815
	WHEN unit_source_value = '10*8' THEN	9443
	WHEN unit_source_value = '10*9/L' THEN	9444
	WHEN unit_source_value = '10*9/mL' THEN	9445
	WHEN unit_source_value = '10*9/uL' THEN	9446
	WHEN unit_source_value = 'a' THEN	9448
	WHEN unit_source_value = 'A' THEN	8543
	WHEN unit_source_value = 'ag/{cell}' THEN	32695
	WHEN unit_source_value = 'atm' THEN	9454
	WHEN unit_source_value = 'bar' THEN	9464
	WHEN unit_source_value = 'Bq' THEN	9469
	WHEN unit_source_value = 'cal' THEN	9472
	WHEN unit_source_value = 'Cel' THEN	586323
	WHEN unit_source_value = 'cg' THEN	9479
	WHEN unit_source_value = 'cL' THEN	9482
	WHEN unit_source_value = 'cm' THEN	8582
	WHEN unit_source_value = 'cm[H2O]' THEN	44777590
	WHEN unit_source_value = 'cm2' THEN	9483
	WHEN unit_source_value = 'cP' THEN	8479
	WHEN unit_source_value = 'd' THEN	8512
	WHEN unit_source_value = 'dB' THEN	44777591
	WHEN unit_source_value = 'deg' THEN	9484
	WHEN unit_source_value = 'dg' THEN	9485
	WHEN unit_source_value = 'dL' THEN	9486
	WHEN unit_source_value = 'dm' THEN	9487
	WHEN unit_source_value = 'eq' THEN	9489
	WHEN unit_source_value = 'eq/L' THEN	9490
	WHEN unit_source_value = 'eq/mL' THEN	9491
	WHEN unit_source_value = 'eq/mmol' THEN	9492
	WHEN unit_source_value = 'eq/umol' THEN	9493
	WHEN unit_source_value = 'erg' THEN	9494
	WHEN unit_source_value = 'eV' THEN	9495
	WHEN unit_source_value = 'F' THEN	8517
	WHEN unit_source_value = 'fg' THEN	9496
	WHEN unit_source_value = 'fL' THEN	8583
	WHEN unit_source_value = 'fm' THEN	9497
	WHEN unit_source_value = 'fmol' THEN	9498
	WHEN unit_source_value = 'fmol/g' THEN	9499
	WHEN unit_source_value = 'fmol/L' THEN	8745
	WHEN unit_source_value = 'fmol/mg' THEN	9500
	WHEN unit_source_value = 'fmol/mL' THEN	9501
	WHEN unit_source_value = 'g' THEN	8504
	WHEN unit_source_value = 'g.m' THEN	9504
	WHEN unit_source_value = 'g{creat}' THEN	44777596
	WHEN unit_source_value = 'g{Hb}' THEN	44777597
	WHEN unit_source_value = 'g{total_prot}' THEN	44777599
	WHEN unit_source_value = 'g/(100.g)' THEN	9508
	WHEN unit_source_value = 'g/(12.h)' THEN	44777593
	WHEN unit_source_value = 'g/(24.h)' THEN	8807
	WHEN unit_source_value = 'g/(5.h)' THEN	8791
	WHEN unit_source_value = 'g/{total_weight}' THEN	9509
	WHEN unit_source_value = 'g/cm3' THEN	45956701
	WHEN unit_source_value = 'g/dL' THEN	8713
	WHEN unit_source_value = 'g/g' THEN	9510
	WHEN unit_source_value = 'g/g{creat}' THEN	9511
	WHEN unit_source_value = 'g/h' THEN	44777594
	WHEN unit_source_value = 'g/kg' THEN	9512
	WHEN unit_source_value = 'g/L' THEN	8636
	WHEN unit_source_value = 'g/m2' THEN	9513
	WHEN unit_source_value = 'g/mL' THEN	9514
	WHEN unit_source_value = 'g/mmol' THEN	32702
	WHEN unit_source_value = 'Gy' THEN	9519
	WHEN unit_source_value = 'h' THEN	8505
	WHEN unit_source_value = 'H' THEN	8518
	WHEN unit_source_value = 'Hz' THEN	9521
	WHEN unit_source_value = 'J' THEN	9522
	WHEN unit_source_value = 'K' THEN	9523
	WHEN unit_source_value = 'K/W' THEN	9524
	WHEN unit_source_value = 'kat' THEN	9526
	WHEN unit_source_value = 'kat/kg' THEN	9527
	WHEN unit_source_value = 'kat/L' THEN	44777601
	WHEN unit_source_value = 'kcal/[oz_av]' THEN	9528
	WHEN unit_source_value = 'kg' THEN	9529
	WHEN unit_source_value = 'kg/L' THEN	9530
	WHEN unit_source_value = 'kg/m2' THEN	9531
	WHEN unit_source_value = 'kg/m3' THEN	9532
	WHEN unit_source_value = 'kg/mol' THEN	9533
	WHEN unit_source_value = 'kL' THEN	9535
	WHEN unit_source_value = 'km' THEN	9536
	WHEN unit_source_value = 'kPa' THEN	44777602
	WHEN unit_source_value = 'ks' THEN	9537
	WHEN unit_source_value = 'L' THEN	8519
	WHEN unit_source_value = 'L/(24.h)' THEN	8857
	WHEN unit_source_value = 'L/h' THEN	44777603
	WHEN unit_source_value = 'L/kg' THEN	9542
	WHEN unit_source_value = 'L/L' THEN	44777604
	WHEN unit_source_value = 'L/min' THEN	8698
	WHEN unit_source_value = 'L/s' THEN	32700
	WHEN unit_source_value = 'lm' THEN	9543
	WHEN unit_source_value = 'm' THEN	9546
	WHEN unit_source_value = 'm/s' THEN	44777606
	WHEN unit_source_value = 'm/s2' THEN	44777607
	WHEN unit_source_value = 'm2' THEN	8617
	WHEN unit_source_value = 'meq' THEN	9551
	WHEN unit_source_value = 'meq/{specimen}' THEN	9552
	WHEN unit_source_value = 'meq/dL' THEN	9553
	WHEN unit_source_value = 'meq/g' THEN	9554
	WHEN unit_source_value = 'meq/g{creat}' THEN	9555
	WHEN unit_source_value = 'meq/kg' THEN	9556
	WHEN unit_source_value = 'meq/L' THEN	9557
	WHEN unit_source_value = 'meq/m2' THEN	9558
	WHEN unit_source_value = 'meq/mL' THEN	9559
	WHEN unit_source_value = 'mg' THEN	8576
	WHEN unit_source_value = 'mg{FEU}/L' THEN	44777663
	WHEN unit_source_value = 'mg/(12.h)' THEN	8908
	WHEN unit_source_value = 'mg/(24.h)' THEN	8909
	WHEN unit_source_value = 'mg/(72.h)' THEN	45891022
	WHEN unit_source_value = 'mg/{total_volume}' THEN	9560
	WHEN unit_source_value = 'mg/dL' THEN	8840
	WHEN unit_source_value = 'mg/g' THEN	8723
	WHEN unit_source_value = 'mg/g{creat}' THEN	9017
	WHEN unit_source_value = 'mg/h' THEN	44777610
	WHEN unit_source_value = 'mg/kg' THEN	9562
	WHEN unit_source_value = 'mg/kg/h' THEN	9691
	WHEN unit_source_value = 'mg/kg/min' THEN	9692
	WHEN unit_source_value = 'mg/L' THEN	8751
	WHEN unit_source_value = 'mg/m2' THEN	9563
	WHEN unit_source_value = 'mg/m3' THEN	9564
	WHEN unit_source_value = 'mg/mg' THEN	9565
	WHEN unit_source_value = 'mg/mg{creat}' THEN	9074
	WHEN unit_source_value = 'mg/min' THEN	44777611
	WHEN unit_source_value = 'mg/mL' THEN	8861
	WHEN unit_source_value = 'mg/mmol' THEN	44777612
	WHEN unit_source_value = 'mg/mmol{creat}' THEN	9075
	WHEN unit_source_value = 'min' THEN	8550
	WHEN unit_source_value = 'min' THEN	9211
	WHEN unit_source_value = 'mL' THEN	8587
	WHEN unit_source_value = 'mL/(12.h)' THEN	44777664
	WHEN unit_source_value = 'mL/(24.h)' THEN	8930
	WHEN unit_source_value = 'mL/{beat}' THEN	9569
	WHEN unit_source_value = 'mL/dL' THEN	9570
	WHEN unit_source_value = 'mL/h' THEN	44777613
	WHEN unit_source_value = 'mL/kg' THEN	9571
	WHEN unit_source_value = 'mL/min' THEN	8795
	WHEN unit_source_value = 'mL/min/{1.73_m2}' THEN	9117
	WHEN unit_source_value = 'mL/s' THEN	44777614
	WHEN unit_source_value = 'mm' THEN	8588
	WHEN unit_source_value = 'mm[Hg]' THEN	8876
	WHEN unit_source_value = 'mm/h' THEN	8752
	WHEN unit_source_value = 'mm2' THEN	9572
	WHEN unit_source_value = 'mmol' THEN	9573
	WHEN unit_source_value = 'mmol/(24.h)' THEN	8910
	WHEN unit_source_value = 'mmol/{specimen}' THEN	44777615
	WHEN unit_source_value = 'mmol/{total_vol}' THEN	9574
	WHEN unit_source_value = 'mmol/dL' THEN	9575
	WHEN unit_source_value = 'mmol/g' THEN	9576
	WHEN unit_source_value = 'mmol/g{creat}' THEN	9018
	WHEN unit_source_value = 'mmol/kg' THEN	9577
	WHEN unit_source_value = 'mmol/L' THEN	8753
	WHEN unit_source_value = 'mmol/m2' THEN	9578
	WHEN unit_source_value = 'mmol/mmol' THEN	44777618
	WHEN unit_source_value = 'mmol/mmol{creat}' THEN	44777619
	WHEN unit_source_value = 'mmol/mol' THEN	9579
	WHEN unit_source_value = 'mmol/mol{creat}' THEN	9019
	WHEN unit_source_value = 'mo' THEN	9580
	WHEN unit_source_value = 'mol' THEN	9584
	WHEN unit_source_value = 'mol/kg' THEN	9585
	WHEN unit_source_value = 'mol/L' THEN	9586
	WHEN unit_source_value = 'mol/m3' THEN	9587
	WHEN unit_source_value = 'mol/mL' THEN	9588
	WHEN unit_source_value = 'mol/s' THEN	44777621
	WHEN unit_source_value = 'mosm' THEN	8605
	WHEN unit_source_value = 'mosm/kg' THEN	8862
	WHEN unit_source_value = 'mosm/L' THEN	9591
	WHEN unit_source_value = 'mPa' THEN	44777623
	WHEN unit_source_value = 'mPa.s' THEN	44777622
	WHEN unit_source_value = 'ms' THEN	9593
	WHEN unit_source_value = 'Ms' THEN	9592
	WHEN unit_source_value = 'N' THEN	9599
	WHEN unit_source_value = 'ng' THEN	9600
	WHEN unit_source_value = 'ng{FEU}/mL' THEN	32707
	WHEN unit_source_value = 'ng/(24.h)' THEN	44777624
	WHEN unit_source_value = 'ng/dL' THEN	8817
	WHEN unit_source_value = 'ng/g' THEN	8701
	WHEN unit_source_value = 'ng/g{creat}' THEN	9601
	WHEN unit_source_value = 'ng/kg' THEN	9602
	WHEN unit_source_value = 'ng/L' THEN	8725
	WHEN unit_source_value = 'ng/m2' THEN	9603
	WHEN unit_source_value = 'ng/mg' THEN	8818
	WHEN unit_source_value = 'ng/mg{creat}' THEN	44777625
	WHEN unit_source_value = 'ng/mg{prot}' THEN	9604
	WHEN unit_source_value = 'ng/mL' THEN	8842
	WHEN unit_source_value = 'ng/mL{RBCs}' THEN	9113
	WHEN unit_source_value = 'ng/mL/h' THEN	9020
	WHEN unit_source_value = 'nkat' THEN	44777626
	WHEN unit_source_value = 'nL' THEN	9606
	WHEN unit_source_value = 'nm' THEN	8577
	WHEN unit_source_value = 'nmol' THEN	9607
	WHEN unit_source_value = 'nmol/(24.h)' THEN	44777627
	WHEN unit_source_value = 'nmol/dL' THEN	9608
	WHEN unit_source_value = 'nmol/g' THEN	9609
	WHEN unit_source_value = 'nmol/g{creat}' THEN	9610
	WHEN unit_source_value = 'nmol/h/L' THEN	44777630
	WHEN unit_source_value = 'nmol/L' THEN	8736
	WHEN unit_source_value = 'nmol/mg' THEN	9611
	WHEN unit_source_value = 'nmol/mg{creat}' THEN	44777634
	WHEN unit_source_value = 'nmol/min/mL' THEN	44777635
	WHEN unit_source_value = 'nmol/mL' THEN	8843
	WHEN unit_source_value = 'nmol/mmol' THEN	9612
	WHEN unit_source_value = 'nmol/mmol{creat}' THEN	9063
	WHEN unit_source_value = 'nmol/mol' THEN	9614
	WHEN unit_source_value = 'nmol/s' THEN	44777637
	WHEN unit_source_value = 'nmol/s/L' THEN	8955
	WHEN unit_source_value = 'ns' THEN	9616
	WHEN unit_source_value = 'Ohm' THEN	9618
	WHEN unit_source_value = 'osm' THEN	9619
	WHEN unit_source_value = 'osm/kg' THEN	9620
	WHEN unit_source_value = 'osm/L' THEN	9621
	WHEN unit_source_value = 'Pa' THEN	9623
	WHEN unit_source_value = 'pg' THEN	8564
	WHEN unit_source_value = 'pg/{cell}' THEN	8704
	WHEN unit_source_value = 'pg/dL' THEN	8820
	WHEN unit_source_value = 'pg/L' THEN	9625
	WHEN unit_source_value = 'pg/mL' THEN	8845
	WHEN unit_source_value = 'pg/mm' THEN	9626
	WHEN unit_source_value = 'pkat' THEN	44777639
	WHEN unit_source_value = 'pL' THEN	9628
	WHEN unit_source_value = 'pm' THEN	9629
	WHEN unit_source_value = 'pmol' THEN	9630
	WHEN unit_source_value = 'pmol/(24.h)' THEN	44777640
	WHEN unit_source_value = 'pmol/dL' THEN	9631
	WHEN unit_source_value = 'pmol/L' THEN	8729
	WHEN unit_source_value = 'pmol/mL' THEN	9632
	WHEN unit_source_value = 'pmol/umol' THEN	9633
	WHEN unit_source_value = 'ps' THEN	9634
	WHEN unit_source_value = 's' THEN	8555
	WHEN unit_source_value = 's' THEN	9212
	WHEN unit_source_value = 'S' THEN	9639
	WHEN unit_source_value = 'Sv' THEN	9645
	WHEN unit_source_value = 't' THEN	9647
	WHEN unit_source_value = 'T' THEN	9646
	WHEN unit_source_value = 'ueq' THEN	9653
	WHEN unit_source_value = 'ueq/L' THEN	8875
	WHEN unit_source_value = 'ueq/mL' THEN	9654
	WHEN unit_source_value = 'ug' THEN	9655
	WHEN unit_source_value = 'ug{FEU}/mL' THEN	8989
	WHEN unit_source_value = 'ug/(100.g)' THEN	9656
	WHEN unit_source_value = 'ug/(24.h)' THEN	8906
	WHEN unit_source_value = 'ug/{specimen}' THEN	9657
	WHEN unit_source_value = 'ug/dL' THEN	8837
	WHEN unit_source_value = 'ug/dL{RBCs}' THEN	9659
	WHEN unit_source_value = 'ug/g' THEN	8720
	WHEN unit_source_value = 'ug/g{creat}' THEN	9014
	WHEN unit_source_value = 'ug/g{Hb}' THEN	9661
	WHEN unit_source_value = 'ug/h' THEN	44777645
	WHEN unit_source_value = 'ug/kg' THEN	9662
	WHEN unit_source_value = 'ug/kg/h' THEN	9690
	WHEN unit_source_value = 'ug/kg/min' THEN	9688
	WHEN unit_source_value = 'ug/L' THEN	8748
	WHEN unit_source_value = 'ug/m2' THEN	9663
	WHEN unit_source_value = 'ug/mg' THEN	8838
	WHEN unit_source_value = 'ug/mg{creat}' THEN	9072
	WHEN unit_source_value = 'ug/min' THEN	8774
	WHEN unit_source_value = 'ug/mL' THEN	8859
	WHEN unit_source_value = 'ug/mmol' THEN	32408
	WHEN unit_source_value = 'ug/mmol{creat}' THEN	44777646
	WHEN unit_source_value = 'ug/ng' THEN	9664
	WHEN unit_source_value = 'ukat' THEN	44777647
	WHEN unit_source_value = 'uL' THEN	9665
	WHEN unit_source_value = 'um' THEN	9666
	WHEN unit_source_value = 'umol' THEN	9667
	WHEN unit_source_value = 'umol/(24.h)' THEN	8907
	WHEN unit_source_value = 'umol/dL' THEN	8839
	WHEN unit_source_value = 'umol/g' THEN	9668
	WHEN unit_source_value = 'umol/g{creat}' THEN	9015
	WHEN unit_source_value = 'umol/g{Hb}' THEN	9669
	WHEN unit_source_value = 'umol/kg' THEN	44777654
	WHEN unit_source_value = 'umol/L' THEN	8749
	WHEN unit_source_value = 'umol/mg' THEN	9670
	WHEN unit_source_value = 'umol/mg{creat}' THEN	9671
	WHEN unit_source_value = 'umol/min' THEN	44777655
	WHEN unit_source_value = 'umol/min/g' THEN	9672
	WHEN unit_source_value = 'umol/mL' THEN	9673
	WHEN unit_source_value = 'umol/mmol' THEN	44777656
	WHEN unit_source_value = 'umol/mmol{creat}' THEN	9073
	WHEN unit_source_value = 'umol/mol' THEN	9674
	WHEN unit_source_value = 'umol/mol{creat}' THEN	9675
	WHEN unit_source_value = 'umol/mol{Hb}' THEN	44777657
	WHEN unit_source_value = 'us' THEN	9676
	WHEN unit_source_value = 'V' THEN	9677
	WHEN unit_source_value = 'Wb' THEN	9679
	WHEN unit_source_value = 'wk' THEN	8511
	WHEN unit_source_value = 'inches' THEN	9330
	WHEN unit_source_value = 'pounds' THEN	8739
	WHEN unit_source_value = 'mmHg' THEN	8876
	WHEN unit_source_value = 'kg/m2' THEN	9531
	WHEN unit_source_value = 'NI' THEN 44814650
	WHEN unit_source_value = 'UN' THEN 44814653
	WHEN unit_source_value = 'OT' THEN 44814649 END
FROM OMOP.dbo.observation
WHERE unit_concept_id = 0;








	
