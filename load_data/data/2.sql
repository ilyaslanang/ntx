INSERT INTO 
m_rate_component(procedure_component_id, procedure_id, kelas_id, component_type, component_name, doctor_id, doctor_name, since, until, meta_data, tags, hospital_id, created_date, created_by, created_by_name, modified_date, modified_by, modified_by_name)
WITH component_all AS (
  SELECT  * FROM component_rate_ok_umum
  UNION ALL 
  SELECT * FROM component_rate_ok_bpjs
), mp_data AS (
SELECT DISTINCT 
sync_ref_id, procedure_type, mp.procedure_name, jns_tarif, group_payment , jns_pelayanan_name , for_pelayanan_name
FROM component_all ca
LEFT JOIN m_procedure mp ON mp.sync_ref_id = ca.procedure_id
), second_stage AS (
SELECT DISTINCT 
mp.procedure_id, mp_data.*, ca.component_name, ca.component_type
FROM
    mp_data
LEFT JOIN m_procedure mp ON mp.sync_ref_id = mp_data.sync_ref_id
LEFT JOIN component_all ca ON mp_data.sync_ref_id = ca.procedure_id
), third_stage AS (
SELECT
second_stage.*,
 	mm.model_id AS componenet_name,
    mm.tags AS tags,
    ROW_NUMBER() OVER (PARTITION BY procedure_id ORDER BY procedure_id, component_name) AS component_sequence
FROM
second_stage
LEFT JOIN
    m_model mm ON second_stage.component_name = mm.model_name
    WHERE
        model_type = 'JNS_COMPONENT_RATE'
)
SELECT
    CONCAT(third_stage.procedure_id, '.', third_stage.component_sequence) AS procedure_component_id,
	procedure_id, 
	NULL AS kelas_id,
	component_type,
	component_name,
    NULL AS doctor_id, 
    NULL AS doctor_name, 
    NULL AS since, 
    NULL AS untill, 
    NULL AS meta_data,
    tags,
    '5271076' AS hospital_id, 
    CURRENT_TIMESTAMP AS created_date, 
    '6f7bc1e7629dce254cb333de9d4dd925' AS created_by, 
    'admin' AS created_by_name, 
    CURRENT_TIMESTAMP AS modified_date, 
    '6f7bc1e7629dce254cb333de9d4dd925' AS modified_by, 
    'admin' AS modified_by_name
FROM third_stage;


