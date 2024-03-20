import pandas as pd
pd.set_option('future.no_silent_downcasting', True)

df = pd.read_excel("KELOMPOK OK - BPJS.xlsx", sheet_name=None)

sheet_2 = df['Klasifikasi Operasi']
# print(sheet_2.head())

sheet_2.columns = ["No", "Procedure ID", "Kelompok Operasi", "Tindakan Operasi"]

# Menghapus baris pertama yang merupakan header yang duplikat
sheet_2.drop(0, inplace=True)

sheet_2 = sheet_2.fillna(method='ffill')

# print(sheet_2.head(10))

sheet_2.to_csv('sheet2.csv', index=False)


