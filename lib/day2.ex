defmodule Aoc.Day2 do
  @moduledoc """
  Solutions for Day 2.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 2

  @impl Day
  def a(levels) do
    Enum.count(levels, &is_safe?/1)
  end

  @impl Day
  def b(levels) do
    Enum.count(levels, &is_safe?(&1, true))
  end

  @impl Day
  def parse_input() do
    with {:ok, file} <- Day.load(__MODULE__) do
      file
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_nums/1)
    end
  end

  @spec parse_nums(nums :: binary) :: [integer]
  defp parse_nums(nums) do
    nums
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  @spec is_safe?(levels :: [integer], damper? :: boolean) :: boolean
  defp is_safe?(levels, damper? \\ false) do
    levels
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.reduce_while(nil, &check_ramp/2)
    |> case do
      index when is_integer(index) ->
        if damper? do
          levels
          |> remove_faulty_indices(index)
          |> Enum.any?(&is_safe?/1)
        else
          false
        end

      _ ->
        true
    end
  end

  @spec check_ramp(value :: {[integer, integer], integer}, ramp :: atom) :: {atom, atom | integer}
  defp check_ramp({[a, b], _}, ramp) when b - a > 0 and b - a < 4 and ramp in [:incr, nil],
    do: {:cont, :incr}

  defp check_ramp({[a, b], _}, ramp) when b - a < 0 and b - a > -4 and ramp in [:decr, nil],
    do: {:cont, :decr}

  defp check_ramp({_, i}, _), do: {:halt, i}

  defp remove_faulty_indices(levels, index) do
    [index - 1, index, index + 1]
    |> Enum.map(&max(&1, 0))
    |> Enum.map(&min(&1, Enum.count(levels) - 1))
    |> Enum.uniq()
    |> Enum.map(&List.delete_at(levels, &1))
  end
end
