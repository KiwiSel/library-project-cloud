from fastapi import FastAPI
from app.database import get_connection
from app.schemas import BookCreate, UserCreate, BorrowingCreate

app = FastAPI()
app.frontend("/", directory="frontend")

@app.get("/books")
def get_books():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, title, author, status FROM books;")
    books = cursor.fetchall()

    cursor.close()
    connection.close()

    return books

@app.get("/users")
def get_books():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, username FROM users;")
    users = cursor.fetchall()

    cursor.close()
    connection.close()

    return users

@app.get("/borrowings")
def get_books():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT user_id, book_id, borrowed_at FROM borrowings;")
    borrowings = cursor.fetchall()

    cursor.close()
    connection.close()

    return borrowings


@app.get("/books/{id}")
def get_books(id):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, title, author, status FROM books WHERE id = %s;", (id,))
    book = cursor.fetchone()

    cursor.close()
    connection.close()

    return book


@app.get("/users/{id}")
def get_books(id):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT id, username FROM users WHERE id = %s;", (id,))
    user = cursor.fetchone()

    cursor.close()
    connection.close()

    return user


@app.get("/borrowings/{book_id}")
def get_books(book_id):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT user_id, book_id, borrowed_at FROM borrowings WHERE book_id = %s;", (book_id,))
    borrowing = cursor.fetchone()

    cursor.close()
    connection.close()

    return borrowing



@app.post("/books/")
def create_book(book: BookCreate):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "INSERT INTO books (title, author) VALUES (%s, %s);",
        (book.title, book.author)
    )

    connection.commit()

    cursor.close()
    connection.close()

    return {"message": "Book created successfully"}


@app.post("/users/")
def create_user(user: UserCreate):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "INSERT INTO users (username) VALUES (%s);",
        (user.username,)
    )

    connection.commit()

    cursor.close()
    connection.close()

    return {"message": "User created successfully"}


@app.post("/borrowings/")
def create_borrowing(borrowing: BorrowingCreate):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "INSERT INTO borrowings (user_id, book_id) VALUES (%s, %s);",
        (borrowing.user_id, borrowing.book_id)
    )

    connection.commit()

    cursor.execute(
        "UPDATE books SET status='borrowed' WHERE id=%s;",
        (borrowing.book_id,)
    )

    connection.commit()

    cursor.close()
    connection.close()

    return {"message": "Borrowing created successfully"}

# @app.put("/borrowings/{id}")
# def return_book(id):
#     connection = get_connection()
#     cursor = connection.cursor()

#     cursor.execute(
#         "UPDATE borrowings SET returned_at=CURRENT_TIMESTAMP WHERE id=%s;",
#         (borrowing.book_id,)
#     )

#     cursor.close()
#     connection.close()

@app.delete("/borrowings/{book_id}")
def return_book(book_id):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "DELETE FROM borrowings WHERE book_id=%s;",
        (book_id,)
    )

    cursor.execute(
        "UPDATE books SET status='available' WHERE id=%s;",
        (book_id,)
    )

    connection.commit()

    cursor.close()
    connection.close()

    return {"message": "Book returned successfully"}