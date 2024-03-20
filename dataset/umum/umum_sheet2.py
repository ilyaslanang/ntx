import pandas as pd
pd.set_option('future.no_silent_downcasting', True)

df = pd.read_excel("KELOMPOK OK - UMUM.xlsx", sheet_name=None)


sheet_2 = df['Klasifikasi Operasi']
# print(sheet_2.head())

sheet_2.columns = ["No", "Procedure ID", "Kelompok Operasi", "Tindakan Operasi"]

# Menghapus baris pertama yang merupakan header yang duplikat
sheet_2.drop(0, inplace=True)

# Melakukan forward fill pada kolom 'No'
sheet_2['No'] = sheet_2['No'].ffill()

# Menghapus baris yang memiliki nilai NaN di kolom 'No' karena sudah terisi dengan forward fill
sheet_2.dropna(subset=['No'], inplace=True)

# Mengatur ulang indeks DataFrame
sheet_2.reset_index(drop=True, inplace=True)

sheet_2.to_csv('sheet2.csv', index=False)


