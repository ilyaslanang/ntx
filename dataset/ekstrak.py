import pandas as pd
import mysql.connector
from mysql.connector import Error

file_excel = pd.ExcelFile('Kelompok OK.xlsx')

sheet1 = file_excel.parse(file_excel.sheet_names[0])
sheet2 = file_excel.parse(file_excel.sheet_names[1])
sheet3 = file_excel.parse(file_excel.sheet_names[2])


# Lakukan transformasi data sesuai kebutuhan Anda
sheet1 = sheet1.rename(columns={'No': 'no',
                                'Procedure ID': 'procedure_id',
                                'Kelompok Operasi': 'kelompok_operasi',
                                'Tindakan Operasi': 'tindakan_operasi'})

sheet2 = sheet2.rename(columns={'Procedure ID': 'procedure_id',
                                'Procedure Name': 'procedure_name',
                                'Procedure Type': 'procedure_type',
                                'Jenis Tarif': 'jenis_tarif',
                                'Group Payment': 'group_payment',
                                'Jenis Pelayanan Name': 'jenis_pelayanan_name',
                                'For Pelayanan Name': 'for_pelayanan_name',
                                'Poli': 'poli',
                                'Dokter': 'dokter',
                                'KELAS 1': 'kelas_1',
                                'KELAS 2': 'kelas_2',
                                'KELAS 3': 'kelas_3',
                                'VIP': 'vip',
                                'VVIP': 'vvip',
                                'PAVILIUN': 'paviliun',
                                'UTAMA': 'utama'
                                })

sheet3 = sheet3.rename(columns={'Component Rate ID': 'component_rate_id',
                                'Procedure ID': 'procedure_id',
                                'Procedure Name': 'procedure_name',
                                'Kelas': 'kelas',
                                'Component Type': 'component_type',
                                'Component Name': 'component_name',
                                'Component Rate': 'component_rate'
                                })

sheet1 = sheet1.fillna('')


# Koneksi ke MySQL
try:
    connection = mysql.connector.connect(
        host="localhost",
        user="user",
        password="password",
        database="db"
    )

    cursor = connection.cursor()

    # Buat tabel baru di MySQL sesuai dengan struktur dataframe
    cursor.execute("CREATE TABLE IF NOT EXISTS klasifikasi_operasi (no int, procedure_id text, kelompok_operasi text, tindakan_operasi text)")
    
    cursor.execute("CREATE TABLE IF NOT EXISTS procedure_all (procedure_id text, procedure_name text, procedure_type text, jenis_tarif text, group_payment text, jenis_pelayanan_name text, for_pelayanan_name text, poli text, dokter text, kelas_1 int, kelas_2 int, kelas_3 int, vip int, vvip int, paviliun int, utama int)")
        
    cursor.execute("CREATE TABLE IF NOT EXISTS component_rate_ok (component_rate_id text, procedure_id text, procedure_name text, kelas text, component_type text, component_name text, component_rate float)")

    # Masukkan data dari dataframe ke tabel MySQL
    for index, row in sheet1.iterrows():
        cursor.execute("INSERT INTO klasifikasi_operasi (no, procedure_id, kelompok_operasi, tindakan_operasi) VALUES (%s, %s, %s, %s)", (row['no'], row['procedure_id'], row['kelompok_operasi'], row['tindakan_operasi']))

    for index, row in sheet2.iterrows():
        cursor.execute("INSERT INTO procedure_all (procedure_id, procedure_name, procedure_type, jenis_tarif, group_payment, jenis_pelayanan_name, for_pelayanan_name, kelas_1, kelas_2, kelas_3, vip, vvip, paviliun, utama) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", (row['procedure_id'], row['procedure_name'], row['procedure_type'], row['jenis_tarif'], row['group_payment'], row['jenis_pelayanan_name'], row['for_pelayanan_name'], row['kelas_1'], row['kelas_2'], row['kelas_3'], row['vip'], row['vvip'], row['paviliun'], row['utama']))

    for index, row in sheet3.iterrows():
        cursor.execute("INSERT INTO component_rate_ok (component_rate_id, procedure_id, procedure_name, kelas, component_type, component_name, component_rate) VALUES (%s, %s, %s, %s, %s, %s, %s)", (row['component_rate_id'], row['procedure_id'], row['procedure_name'], row['kelas'], row['component_type'], row['component_name'], row['component_rate']))

    # Komit perubahan data
    connection.commit()

except Error as e:
    print(f"Terjadi kesalahan saat koneksi ke MySQL: {e}")

finally:
    if connection.is_connected():
        cursor.close()
        connection.close()
        print("Koneksi ke MySQL ditutup")