import psycopg2


def get_connection():
    connection = psycopg2.connect(
        dbname="library_db",
        user=os.getenv("DB_USER"),
        host="localhost",
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