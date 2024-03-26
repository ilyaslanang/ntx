-- INSERT INTO m_model (model_type, hospital_id, model_id, model_name, additional1, additional2, description, ordering, tags, meta_data, is_active,acl, parent_id , modified_date, modified_by, modified_by_name)
WITH mp_data AS (
SELECT DISTINCT 
procedure_name, for_pelayanan_name, sync_ref_id, ref_code
FROM klasifikasi_operasi ka
LEFT JOIN m_procedure mp ON ka.procedure_id = mp.sync_ref_id
) , first_stage AS (
SELECT DISTINCT 
mp_data.*, ka.procedure_id, ka.kelompok_operasi
FROM mp_data
LEFT JOIN klasifikasi_operasi ka ON mp_data.sync_ref_id = ka.procedure_id
)
, model_row AS(
SELECT
first_stage.*, ref_code as parent_id, tindakan_operasi,
ROW_NUMBER() OVER (PARTITION BY kelompok_operasi ORDER BY tindakan_operasi) AS ordering_sequence
FROM
first_stage
LEFT JOIN klasifikasi_operasi ka ON first_stage.procedure_id = ka.procedure_id
)
,last_stage AS (
SELECT
        model_row.*,
        CONCAT(model_row.parent_id, '.', model_row.ordering_sequence) AS model_id
    FROM
        model_row
)
SELECT
    'KELOMPOK_OPERASI' AS model_type,
    '5271076' AS hospital_id,
    last_stage.model_id,   
    last_stage.tindakan_operasi as model_name,
    NULL AS additional1,
    NULL AS additional2,
    NULL AS description,
    last_stage.ordering_sequence as ordering,
    last_stage.procedure_name AS tags,
    NULL AS meta_data,
    NULL AS acl,
    '1' AS is_active,
    last_stage.parent_id,
    CURRENT_TIMESTAMP AS modified_date,
    '6f7bc1e7629dce254cb333de9d4dd925' AS modified_by,
    'admin' AS modified_by_name
 FROM last_stage;