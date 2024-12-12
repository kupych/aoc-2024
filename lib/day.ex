defmodule Aoc.Day do
  @moduledoc """
  Generic module for a puzzle day.
  """

  @doc """
  Returns the solution for part A of the problem.
  """
  @callback a(term) :: String.t()

  @doc """
  Returns the solution for part B of the problem.
  """
  @callback b(term) :: String.t()
  @doc """
  Returns the day number.
  """
  @callback day() :: integer

  @doc """
  Parses the file input for the problem.
  """
  @callback parse_input(binary) :: term

  @doc """
  Loads the file input for the problem if available.

  ## Examples
      iex> load(Aoc.Day1)
      {:ok, "......."}
  """
  def load(module), do: File.read("files/#{module.day()}")

  @doc """
  Returns the solution for parts A and B of the problem.

  ## Examples
      iex> solve(Aoc.Day1)
      "The solution to 1a is: 12345"
      "The solution to 1b is: 12345"
  """
  def solve(module) when is_atom(module) do
    :code.ensure_loaded(module)

    with true <- function_exported?(module, :parse_input, 1),
         {:ok, file} <- load(module) do
      data = module.parse_input(file)
      IO.puts("The solution to #{module.day()}a is: #{module.a(data)}")
      IO.puts("The solution to #{module.day()}b is: #{module.b(data)}")
    else
      false -> IO.puts("Invalid module")
      _ -> IO.puts("File not found")
    end
  end

  def solve(day) when is_integer(day) do
    module = :"Elixir.Aoc.Day#{day}"
    solve(module)
  end

  def solve(_), do: IO.puts("Invalid day or module")

  def solve() do
    for day <- 1..25 do
      solve(day)
    end

    :ok
  end
end
