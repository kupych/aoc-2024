defmodule Aoc.Day1 do
  @moduledoc """
  Solutions for Day 1.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 1

  @impl Day
  def a(numbers) do
    numbers |> Enum.zip() |> Enum.map(fn {a, b} -> abs(a - b) end) |> Enum.sum()
  end

  @impl Day
  def b([l, r]) do
    acc = l |> Enum.map(&{&1, 0}) |> Enum.into(%{})

    occurrences =
      Enum.reduce(r, acc, &Map.update(&2, &1, 1, fn x -> x + &1 end))

    Enum.reduce(l, 0, &(&2 + Map.get(occurrences, &1, 0)))
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_numbers/1)
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
  end

  defp parse_numbers(line) do
    line
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
