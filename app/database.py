import psycopg2
import os


def get_connection():
    connection = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host="db",
        port="5432"
    )

    return connection


if __name__ == "__main__":
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT 1;")
    result = cursor.fetchone()

    print("Database connection successful!")
    print("Result:", result)

    cursor.close()
    connection.close()