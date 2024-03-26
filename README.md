## Membuat virtual Environment:

`python -m venv .venv`

### Install Package:

`pip install mysql-connector-python pandas` 

## Jalankan Docker-compose

`docker-compose up -d`

## Ingest Database

Jalankan [ingest.py](./ingest.py)  
fungsi ini untuk memasukkan database zicare_db_test.sql

`python ingest.py` 

## Pindah ke Dataset

`cd dataset`  

jalankan [data_read.py](./dataset/data_read.py)  

`python data_read.py` 

ini akan menghasilkan dataset gabungan yang bernama [Kelompok OK](./dataset/Kelompok%20OK.xlsx)  

kemudian lanjut untuk [ekstrak data](./dataset/ekstrak.py)   

`python ekstrak.py`  
 
## Load Data  

pindah ke file [load_data](./load_data)  

`cd ../load_data`  

jalankan [load.py](./load_data/load.py)  

`python load.py`  
fungsi ini akan load data berdasarkan query yang telah dibuat
