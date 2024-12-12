defmodule Aoc.Day12 do
  @moduledoc """
  Solutions for Day 12.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @impl Day
  def day(), do: 12

  @impl Day
  def a(field) do
    field
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.flat_map(&to_clusters/1)
    |> Enum.map(fn {_, v} -> Enum.count(v) * get_perimeter(v) end)
    |> Enum.sum()
  end

  @impl Day
  def b(field) do
    field
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.flat_map(&to_clusters/1)
    |> Enum.map(fn {k, v} -> {k, {Enum.count(v), get_unique_edges(v)}} end)
    |> Enum.map(fn {_, v} -> Tuple.product(v) end)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    Utilities.map_from_grid(file)
  end

  def get_perimeter(values) do
    values_map = MapSet.new(values)

    values
    |> Enum.map(&calculate_fence(&1, values_map))
    |> Enum.sum()
  end

  def get_unique_edges(values) do
    value_map = MapSet.new(values)

    values
    |> Enum.flat_map(&Utilities.get_adjacent(&1))
    |> Enum.uniq()
    |> Enum.reject(&MapSet.member?(value_map, &1))
    |> Enum.flat_map(&get_boundaries(&1, value_map))
    |> find_disjoint_edges()
    |> Enum.sort()
    |> Enum.count()
  end

  def calculate_fence(value, values_map) do
    value
    |> Utilities.get_adjacent()
    |> Enum.reject(&MapSet.member?(values_map, &1))
    |> Enum.count()
  end

  def to_clusters({k, v}) do
    v
    |> group_contiguous([])
    |> Enum.map(&{k, &1})
  end

  defp group_contiguous([], clusters), do: clusters

  defp group_contiguous([current | rest], clusters) do
    {cluster, remaining} = find_cluster([current], rest, [])

    group_contiguous(remaining, [cluster | clusters])
  end

  defp find_cluster([], remaining, cluster), do: {cluster, remaining}

  defp find_cluster([current | rest], remaining, cluster) do
    adjacent =
      current
      |> Utilities.get_adjacent()
      |> Enum.filter(&Enum.member?(remaining, &1))

    find_cluster(rest ++ adjacent, remaining -- adjacent, [current | cluster])
  end

  defp get_boundaries({x, y} = edge, values) do
    vertical =
      edge
      |> Utilities.get_adjacent(:vertical)
      |> Enum.filter(&MapSet.member?(values, &1))
      |> Enum.map(&{"y#{[y, elem(&1, 1)] |> Enum.join(",")}", x})

    horizontal =
      edge
      |> Utilities.get_adjacent(:horizontal)
      |> Enum.filter(&MapSet.member?(values, &1))
      |> Enum.map(&{"x#{[x, elem(&1, 0)] |> Enum.join(",")}", y})

    vertical ++ horizontal
  end

  defp find_disjoint_edges(values) do
    values
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {k, v} -> {k, count_blocks(v)} end)
    |> Enum.flat_map(fn {k, v} -> Enum.map(1..v, fn _ -> k end) end)
  end

  def count_blocks(nums) do
    nums
    |> Enum.sort()
    |> Enum.uniq()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> min(b - a - 1, 1) end)
    |> Enum.sum()
    |> Kernel.+(1)
  end
end
