# Bookstore

Example app for stateful PBT from the [PropEr testing book](https://propertesting.com/).

## Instructions

Install [Elixir](https://elixir-lang.org/install.html).

```bash
$ docker-compose up -d  # Postgres
$ mix deps.get
$ mix escript.build
$ ./bookstore  # Initialize database
```

Run commands interactively by entering the shell

```bash
$ iex -S mix
```

and importing `Bookstore.DB`:

```bash
iex> import Bookstore.DB
iex> setup()
iex> add_book("fake-isbn", "Book Name", "Book Author")
iex> find_book_by_title("Book")
```

### Access Postgres database

Access the local Postgres database with database `bookstore_db` and username `kimmo`:

```bash
$ psql -h localhost bookstore_db kimmo
```

and run queries:

```psql
bookstore_db=# SELECT * from books;
```
