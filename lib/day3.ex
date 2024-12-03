defmodule Aoc.Day3 do
  @moduledoc """
  Solutions for Day 3.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 3

  @impl Day
  def a(file) do
    ~r/mul\((\d+),(\d+)\)/
    |> Regex.scan(file)
    |> Enum.map(&do_mul/1)
    |> Enum.sum()
  end

  @impl Day
  def b(file) do
    ~r/don't\(\).*?do\(\)/s
    |> Regex.replace(file, "")
    |> then(&Regex.scan(~r/mul\((\d+),(\d+)\)/, &1))
    |> Enum.map(&do_mul/1)
    |> Enum.sum()
  end

  @impl Day
  def parse_input() do
    with {:ok, file} <- Day.load(__MODULE__) do
      file
    end
  end

  @spec do_mul([binary]) :: integer
  defp do_mul([_ | nums]) do
    nums
    |> Enum.map(&String.to_integer/1)
    |> Enum.product()
  end
end
