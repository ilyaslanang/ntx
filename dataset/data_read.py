import pandas as pd
pd.set_option('future.no_silent_downcasting', True)


# Load data dari file Excel
file1 = pd.ExcelFile("KELOMPOK OK - UMUM.xlsx")
file2 = pd.ExcelFile("KELOMPOK OK - BPJS.xlsx")

sheet_names = ['Klasifikasi Operasi', 'Procedure', 'component rate ok']

# Membaca data dari setiap file Excel dan menggabungkannya
with pd.ExcelWriter('Kelompok OK.xlsx') as writer:
    for sheet_name in sheet_names:
        # Membaca sheet dari kedua file
        df1 = file1.parse(sheet_name)
        df2 = file2.parse(sheet_name)

        # Menghapus baris pertama dari 'Klasifikasi Operasi'
        if sheet_name == 'Klasifikasi Operasi':
            df1 = file1.parse(sheet_name, header=1)
            df2 = file2.parse(sheet_name, header=1)
        # Mengisi nilai NaN dengan metode ffill
            df1 = df1.fillna(method='ffill')
            df2 = df2.fillna(method='ffill')
        else:
            df1 = file1.parse(sheet_name)
            df2 = file2.parse(sheet_name)

        # Menggabungkan DataFrame dari kedua file
        df_combined = pd.concat([df1, df2])

        # Menyimpan DataFrame gabungan ke sheet yang sesuai dalam file Excel
        df_combined.to_excel(writer, sheet_name=sheet_name, index=False)

print("Berhasil menyimpan data ke file Excel.")
