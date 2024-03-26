from sqlalchemy import create_engine, MetaData

#  Buat Engine SQLAlchemy
engine = create_engine('mysql://user:password@localhost:3306/db')

metadata = MetaData()

connection = engine.connect()

with open('zicare_db_test.sql', 'r') as file:
    schema_sql = file.read()
    connection.execute(schema_sql)

metadata.reflect(bind=engine)


for table in metadata.sorted_tables:
    print(table.name)

connection.close()