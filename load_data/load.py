import mysql.connector
import os 
import pathlib
from mysql.connector import Error

def path_data():
    current_path = pathlib.Path(__file__).absolute()
    join_path_to_src = current_path.parent.joinpath('./data')
    return join_path_to_src

try:
    connection = mysql.connector.connect(host='localhost',
                                         database='db',
                                         user='user',
                                         password='password')
    if connection.is_connected():
        path = path_data()
        dir_list = os.listdir(path)
        for file in dir_list:
            full_path = str(path) + '\\' + file
            sql_file = open(full_path).read()
            # print(sql_file)
            cursor = connection.cursor()
            cursor.execute(sql_file)
            record = cursor.fetchall()
            for data in record:
                print(data)
            
        # db_Info = connection.get_server_info()
        # print("Connected to MySQL Server version ", db_Info)
        cursor = connection.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        # print("You're connected to database: ", record)

except Error as e:
    raise e
finally:
    if connection.is_connected():
        # cursor.close()
        connection.close()
        # print("MySQL connection is closed")