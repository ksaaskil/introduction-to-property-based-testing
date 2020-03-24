defmodule Bookstore.Init do
  def main(_) do
    File.mkdir_p("postgres/data/")
    stdout = IO.stream(:stdio, :line)
    IO.puts("Initializing db...")
    System.cmd("initdb", ["-D", "postgres/data"], into: stdout)
    IO.puts("Starting postgres instance...")

    args = ["-D", "postgres/data", "-l", "logfile", "start"]

    case :os.type() do
      {:unix, _} -> System.cmd("pg_ctl", args, into: stdout)
    end

    System.cmd(
      "psql",
      ["-h", "localhost", "-d", "template1", "-c", "CREATE DATABASE bookstore_db;"],
      into: stdout
    )

    IO.puts("OK")
    :init.stop()
  end
end
