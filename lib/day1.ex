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
    numbers
    |> unzip_zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  @impl Day
  def b(nums) do
    [l, r] =
      nums
      |> Enum.unzip()
      |> Tuple.to_list()

    acc =
      l
      |> Enum.map(&{&1, 0})
      |> Enum.into(%{})

    occurrences =
      r
      |> Enum.reduce(acc, fn num, acc ->
        Map.update(acc, num, 1, fn x -> x + num end)
      end)

    l
    |> Enum.map(&Map.get(occurrences, &1))
    |> Enum.sum()
  end

  @impl Day
  def parse_input() do
    with {:ok, file} <- Day.load(__MODULE__) do
      file
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&parse_nums/1)
    end
  end

  defp parse_nums(line) do
    line
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp unzip_zip(numbers) do
    numbers
    |> Enum.unzip()
    |> Tuple.to_list()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
  end
end
