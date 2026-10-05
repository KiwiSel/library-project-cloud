import psycopg2
import os


def get_connection():
    connection = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        # host="db",
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT")
        # port="5432"
    )

    return connection

def initialize_database():
    connection = get_connection()

    with open("/app/init.sql", "r") as file:
        sql = file.read()

    with connection.cursor() as cursor:
        cursor.execute(sql)

    connection.commit()
    connection.close()

if __name__ == "__main__":
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT 1;")
    result = cursor.fetchone()

    print("Database connection successful!")
    print("Result:", result)

    cursor.close()
    connection.close()