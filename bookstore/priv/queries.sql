-- Setup the database
-- :setup_table_books
CREATE TABLE books (
  isbn varchar(20) PRIMARY KEY,
  title varchar(256) NOT NULL,
  author varchar(256) NOT NULL,
  owned smallint DEFAULT 0,
  available smallint DEFAULT 0
);

-- Clean up the table
-- :teardown_table_books
DROP TABLE books;

-- Add a book
-- :add_book
INSERT INTO books (isbn, title, author, owned, available)
       VALUES     ($1,   $2,    $3,     $4,    $5       );

-- Add a copy of an existing book
-- :add_copy
UPDATE books SET
  owned = owned + 1,
  available = available + 1
WHERE isbn = $1;

-- Borrow a copy of a book
-- :borrow_copy
UPDATE books SET available = available - 1 WHERE isbn = $1 AND available > 0;

-- Return a copy of a book
-- :return_copy
UPDATE books SET available = available + 1 WHERE isbn = $1;

-- Find books
-- :find_by_author
SELECT * FROM books WHERE author LIKE $1;
-- :find_by_isbn
SELECT * FROM books WHERE isbn = $1;
-- :find_by_title
SELECT * FROM books WHERE title LIKE $1;
