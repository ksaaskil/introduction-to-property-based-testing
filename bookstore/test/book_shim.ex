defmodule BookShim do
  def add_book_existing(isbn, title, author, owned, avail) do
    Bookstore.DB.add_book(isbn, title, author, owned, avail)
  end

  def add_book_new(isbn, title, author, owned, avail) do
    Bookstore.DB.add_book(isbn, title, author, owned, avail)
  end

  def find_book_by_title_matching(title) do
    Bookstore.DB.find_book_by_title(title)
  end

  def find_book_by_title_unknown(title) do
    Bookstore.DB.find_book_by_title(title)
  end
end
