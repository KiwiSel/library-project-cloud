from pydantic import BaseModel
from datetime import date

class BookCreate(BaseModel):
    title: str
    author: str


class UserCreate(BaseModel):
    username: str


class BorrowingCreate(BaseModel):
    book_id: int
    user_id: int