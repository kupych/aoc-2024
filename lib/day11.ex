defmodule Aoc.Day11 do
  @moduledoc """
  Solutions for Day 11.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 11

  @impl Day
  def a(stones) do
    :ets.new(:stones, [:named_table, {:write_concurrency, true}, {:read_concurrency, true}])

    sum =
      stones
      |> Enum.map(&blink(&1, 0, 25))
      |> Enum.sum()

    :ets.delete(:stones)
    sum
  end

  @impl Day
  def b(stones) do
    :ets.new(:stones, [:named_table, {:write_concurrency, true}, {:read_concurrency, true}])

    sum =
      stones
      |> Enum.map(&blink(&1, 0, 75))
      |> Enum.sum()
    :ets.delete(:stones)
    sum
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split(~r/\D+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def blink(stone, level, target) do
    case :ets.lookup(:stones, {stone, level}) do
      [{_, result}] ->
        result

      [] ->
        result =
          cond do
            level == target ->
              1

            stone == 0 ->
              blink(1, level + 1, target)

            even_digits?(stone) ->
              stone_string = Integer.to_string(stone)
              digits = String.length(stone_string)

              {a, b} = String.split_at("#{stone}", div(digits, 2))

              blink(String.to_integer(a), level + 1, target) +
                blink(String.to_integer(b), level + 1, target)

            true ->
              blink(stone * 2024, level + 1, target)
          end

        :ets.insert_new(:stones, {{stone, level}, result})
        result
    end
  end

  def even_digits?(1), do: false

  def even_digits?(num) do
    num
    |> Integer.to_string()
    |> String.length()
    |> rem(2)
    |> Kernel.==(0)
  end
end
