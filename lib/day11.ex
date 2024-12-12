defmodule Aoc.Day11 do
  @moduledoc """
  Solutions for Day 11.
  """
  @behaviour Aoc.Day

  use Nebulex.Caching

  alias Aoc.{Day, LocalCache}

  @impl Day
  def day(), do: 11

  @impl Day
  def a(stones) do
    sum =
      stones
      |> Enum.map(&blink(&1, 0, 25))
      |> Enum.sum()

    sum
  end

  @impl Day
  def b(stones) do
    stones
    |> Enum.map(&blink(&1, 0, 75))
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split(~r/\D+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @decorate cacheable(
              cache: LocalCache,
              key: {__MODULE__, :stone, stone, level, target}
            )
  def blink(stone, level, target) do
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
