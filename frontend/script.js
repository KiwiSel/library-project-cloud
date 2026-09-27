async function loadBooks() {
    const response = await fetch("/books");
    const books = await response.json();

    const table = document.getElementById("books");
    table.innerHTML = "";

    books.forEach(book => {
        table.innerHTML += `
            <tr>
                <td>${book[0]}</td>
                <td>${book[1]}</td>
                <td>${book[2]}</td>
                <td>${book[3]}</td>
            </tr>
        `;
    });
}


async function loadUsers() {
    const response = await fetch("/users");
    const users = await response.json();

    const table = document.getElementById("users");
    table.innerHTML = "";

    users.forEach(user => {
        table.innerHTML += `
            <tr>
                <td>${user[0]}</td>
                <td>${user[1]}</td>
            </tr>
        `;
    });
}


async function loadBorrowings() {
    const response = await fetch("/borrowings");
    const borrowings = await response.json();

    const table = document.getElementById("borrowings");
    table.innerHTML = "";

    borrowings.forEach(borrowing => {
        table.innerHTML += `
            <tr>
                <td>${borrowing[0]}</td>
                <td>${borrowing[1]}</td>
                <td>${borrowing[2]}</td>
                <td>
                    <button onclick="returnBook(${borrowing[1]})">
                        Return
                    </button>
                </td>
            </tr>
        `;
    });
}


document.getElementById("book-form").addEventListener("submit", async function(event) {
    event.preventDefault();

    const title = document.getElementById("book-title").value;
    const author = document.getElementById("book-author").value;

    await fetch("/books/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            title: title,
            author: author
        })
    });

    this.reset();

    loadBooks();
});


document.getElementById("user-form").addEventListener("submit", async function(event) {
    event.preventDefault();

    const username = document.getElementById("username").value;

    await fetch("/users/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            username: username
        })
    });

    this.reset();

    loadUsers();
});


document.getElementById("borrowing-form").addEventListener("submit", async function(event) {
    event.preventDefault();

    const userId = document.getElementById("user-id").value;
    const bookId = document.getElementById("book-id").value;

    await fetch("/borrowings/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            user_id: Number(userId),
            book_id: Number(bookId)
        })
    });

    this.reset();

    loadBooks();
    loadBorrowings();
});


async function returnBook(bookId) {
    await fetch(`/borrowings/${bookId}`, {
        method: "DELETE"
    });

    loadBooks();
    loadBorrowings();
}


loadBooks();
loadUsers();
loadBorrowings();