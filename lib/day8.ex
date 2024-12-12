defmodule Aoc.Day8 do
  @moduledoc """
  Solutions for Day 8.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @impl Day
  def day(), do: 8

  @impl Day
  def a(grid) do
    nodes =
      grid
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
      |> Enum.reject(fn {k, _} -> k == "." end)

    grid
    |> Enum.map(fn
      {k, "."} -> {k, %{node: nil, antinodes: []}}
      {k, v} -> {k, %{node: v, antinodes: []}}
    end)
    |> Enum.into(%{})
    |> Map.put(:max, nil)
    |> then(&Enum.reduce(nodes, &1, fn n, acc -> find_antinodes(n, acc) end))
    |> Enum.count(fn {_, v} -> is_map(v) and !Enum.empty?(v.antinodes) end)
  end

  @impl Day
  def b(grid) do
    nodes =
      grid
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
      |> Enum.reject(fn {k, _} -> k == "." end)

    max =
      grid
      |> Map.keys()
      |> Enum.sort(:desc)
      |> hd()

    grid
    |> Enum.map(fn
      {k, "."} -> {k, %{node: nil, antinodes: []}}
      {k, v} -> {k, %{node: v, antinodes: []}}
    end)
    |> Enum.into(%{})
    |> Map.put(:max, max)
    |> then(&Enum.reduce(nodes, &1, fn n, acc -> find_antinodes(n, acc) end))
    |> Enum.count(fn {_, v} -> is_map(v) and !Enum.empty?(v.antinodes) end)
  end

  @impl Day
  def parse_input(file) do
    Utilities.map_from_grid(file)
  end

  defp find_antinodes({node, coords}, grid) do
    combos =
      for x <- coords, y <- coords, x != y do
        {x, y}
      end

    points =
      combos
      |> Enum.reduce([], &do_find_antinodes(&1, &2, grid.max))
      |> Enum.uniq()

    Enum.reduce(points, grid, fn coord, acc ->
      Map.update(acc, coord, nil, fn
        %{antinodes: a} = n -> %{n | antinodes: [node | a]}
        nil -> nil
      end)
    end)
  end

  defp do_find_antinodes({{ax, ay} = a, {bx, by} = b}, acc, nil) do
    {dx, dy} = Utilities.distance(a, b)

    [{ax - dx, ay - dy}, {bx + dx, by + dy} | acc]
  end

  defp do_find_antinodes({a, b}, acc, {max_x, max_y}) do
    {dx, dy} = Utilities.distance(a, b)

    points_from_a =
      Stream.unfold(a, fn
        {x, y} when x > max_x or y > max_y or x < 0 or y < 0 -> nil
        {x, y} -> {{x, y}, {x - dx, y - dy}}
      end)
      |> Enum.to_list()

    points_from_b =
      Stream.unfold(b, fn
        {x, y} when x > max_x or y > max_y or x < 0 or y < 0 -> nil
        {x, y} -> {{x, y}, {x + dx, y + dy}}
      end)
      |> Enum.to_list()

    points_from_a ++ points_from_b ++ acc
  end
end
