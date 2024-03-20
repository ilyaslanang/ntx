INSERT INTO m_procedure (procedure_id,procedure_name, procedure_key,description, jns_pelayanan_id, jns_pelayanan_name,
for_pelayanan_id, for_pelayanan_name, grp_id, grp_ids,
poli_id, poli_name, doctor_id, doctor_name, procedure_type,
jns_tarif, group_payment, since, until,
company_id, company_name, company_percentage_cover,  company_fix_cover, publish_at, publish_start, publish_end,
meta_data, table_ref, column_ref, ref_id, sync_ref_id, ref_code, procedure_id_ris, inhealth_id,
tags, penunjang_tags, hospital_id, rate_a,rate_b, rate_c, rate_d, rate_e, rate_f, rate_g, rate_h, rate_i, rate_j, is_active, created_date,
created_by, created_by_name, modified_date, modified_by, modified_by_name)
WITH procedure_all AS (
  SELECT * FROM procedure_umum
  UNION ALL 
  SELECT * FROM procedure_bpjs
), union_procedure AS (
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    kelas_1 AS rate,
    'kelas 1' as kelas_tarif
  FROM procedure_all 
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    kelas_2 AS rate,
    'kelas 2' as kelas_tarif
  FROM procedure_all
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    kelas_3 AS rate,
    'kelas 3' as kelas_tarif
  FROM procedure_all
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    vip AS rate,
    'vip' as kelas_tarif
  FROM procedure_all
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    vvip AS rate,
    'vvip' as kelas_tarif
  FROM procedure_all
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    paviliun AS rate,
    'paviliun' as kelas_tarif
  FROM procedure_all
  UNION
  SELECT 
    procedure_id AS sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    utama AS rate,
    'utama' as kelas_tarif
  FROM procedure_all
), first_stage AS (
  SELECT 
    ROW_NUMBER() OVER (PARTITION BY sync_ref_id ORDER BY kelas_tarif) as row_num_refcode, 
    sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter ,
    rate,
    ROW_NUMBER() OVER (PARTITION BY procedure_type ORDER BY sync_ref_id) as row_num_procedureid,
    CASE
        WHEN kelas_tarif LIKE 'kelas%' THEN UPPER(REPLACE(kelas_tarif, 'kelas ', ''))
        WHEN kelas_tarif LIKE 'paviliun' THEN 'PAV'
        ELSE UPPER(kelas_tarif)
    END AS kelas_tarif
  FROM union_procedure
), stg_1 AS (
  SELECT 
    REGEXP_REPLACE(procedure_name, '[^0-9a-zA-Z]', '-') as procedure_key,
    CONCAT('OK', LPAD(fs.row_num_refcode, 6, '0')) AS ref_code,
    CONCAT(UPPER(fs.procedure_type), '.', LPAD(fs.row_num_procedureid, 6, '0')) as procedure_id,
    sync_ref_id, 
    procedure_name, 
    procedure_type , 
    jenis_tarif , 
    group_payment , 
    jenis_pelayanan_name , 
    for_pelayanan_name , 
    poli , 
    dokter , 
    rate, 
    kelas_tarif
  FROM first_stage fs
), kelompok_rr AS (
  SELECT
    kelas_rr_id,
    rr_code,
    GROUP_CONCAT(CONCAT(rr_code, kelas_rr_id) SEPARATOR ',') AS grp_ids
  FROM m_ruang_rawat
  GROUP BY
    rr_code, kelas_rr_id
), kompani_id AS (
  SELECT 
    pa.procedure_id,
    CASE 
        WHEN pa.procedure_id LIKE  'UMUM%' THEN NULL
        ELSE mc.company_id
    END company_id
  FROM procedure_all pa
  LEFT JOIN m_company mc ON mc.jns_company = 'A'
), kompani_name AS (
  SELECT 
    pa.procedure_id,
    CASE
        WHEN pa.procedure_id LIKE  'UMUM%' THEN NULL
        ELSE mc.company_name
    END company_name
  FROM procedure_all pa
  LEFT JOIN m_company mc ON mc.jns_company = 'A'
)
SELECT 
    stg_1.procedure_id, 
    stg_1.procedure_name, 
    stg_1.procedure_key, 
    NULL AS description, 
    NULL AS jns_pelayanan_id, 
    stg_1.jenis_pelayanan_name AS jns_pelayanan_name, 
    NULL AS for_pelayanan_id, 
    stg_1.for_pelayanan_name AS for_pelayanan_name,
    NULL AS grp_id, 
    sub_rr.grp_ids, 
    NULL AS poli_id, 
    NULL AS poli_name, 
    NULL AS doctor_id, 
    NULL AS doctor_name, 
    stg_1.procedure_type AS procedure_type, 
    stg_1.jenis_tarif AS jns_tarif, 
    stg_1.group_payment AS group_payment, 
    NULL AS since, 
    NULL AS until, 
    ki.company_id, 
    kn.company_name, 
    NULL AS company_percentage_cover, 
    NULL AS company_fix_cover, 
    NULL AS publish_at, 
    NULL AS publish_start, 
    NULL AS publish_end, 
    NULL AS meta_data, 
    NULL AS table_ref, 
    NULL AS column_ref, 
    NULL AS ref_id, 
    sync_ref_id, 
    stg_1.ref_code, 
    NULL AS procedure_id_ris, 
    NULL AS inhealth_id,
    'Pelayanan Kamar Bedah,Tindakan Operasi' AS tags, 
    'group-service' AS penunjang_tags, 
    '5271076' AS hospital_id, 
    0 AS rate_a, 
    0 AS rate_b, 
    0 AS rate_c, 
    0 AS rate_d, 
    0 AS rate_e, 
    0 AS rate_f, 
    0 AS rate_g, 
    0 AS rate_h, 
    0 AS rate_i, 
    0 AS rate_j, 
    1 AS is_active, 
    CURRENT_TIMESTAMP AS created_date, 
    '6f7bc1e7629dce254cb333de9d4dd925' AS created_by, 
    'admin' AS created_by_name, 
    CURRENT_TIMESTAMP AS modified_date, 
    '6f7bc1e7629dce254cb333de9d4dd925' AS modified_by, 
    'admin' AS modified_by_name
FROM stg_1
LEFT JOIN (
	SELECT stg_1.procedure_id, GROUP_CONCAT(CONCAT(grp_ids) SEPARATOR ',') AS grp_ids
	FROM stg_1
	LEFT JOIN kelompok_rr kr ON stg_1.kelas_tarif = kr.kelas_rr_id
	GROUP BY 1
) sub_rr ON stg_1.procedure_id = sub_rr.procedure_id
LEFT JOIN kompani_id ki ON stg_1.sync_ref_id = ki.procedure_id
LEFT JOIN kompani_name kn ON stg_1.sync_ref_id = kn.procedure_id
LEFT JOIN m_jns_pelayanan mjp ON stg_1.jenis_pelayanan_name = mjp.jns_pelayanan_name
LEFT JOIN m_model mm ON stg_1.for_pelayanan_name = mm.model_name
WHERE
  mm.model_type = 'FOR_PELAYANAN';