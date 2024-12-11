defmodule Aoc.Day10 do
  @moduledoc """
  Solutions for Day 10.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @impl Day
  def day(), do: 10

  @impl Day
  def a(map) do
    map
    |> Enum.filter(fn {_, v} -> v == 0 end)
    |> Enum.flat_map(&walk_trail([&1], map))
    |> Enum.filter(&(Enum.count(&1) == 10))
    |> Enum.group_by(&(Enum.reverse(&1) |> hd()))
    |> Enum.map(fn {_, v} -> Enum.uniq_by(v, &hd/1) |> Enum.count() end)
    |> Enum.sum()
  end

  @impl Day
  def b(map) do
    map
    |> Enum.filter(fn {_, v} -> v == 0 end)
    |> Enum.flat_map(&walk_trail([&1], map))
    |> Enum.filter(&(Enum.count(&1) == 10))
    |> Enum.group_by(&(Enum.reverse(&1) |> hd()))
    |> Enum.map(fn {_, v} -> Enum.count(v) end)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    Utilities.map_from_grid(file, &String.to_integer/1)
  end

  def walk_trail([{_, 9} | _] = steps, _, _) do
    [steps]
  end

  def walk_trail([{coords, level} | _] = steps, map) do
    coords
    |> Utilities.get_adjacent()
    |> Enum.filter(fn x -> Map.get(map, x) == level + 1 end)
    |> case do
      [] ->
        [steps]

      coords ->
        Enum.flat_map(coords, &walk_trail([{&1, level + 1} | steps], map))
    end
  end
end
