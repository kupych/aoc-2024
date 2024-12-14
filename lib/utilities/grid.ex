defmodule Aoc.Utilities.Grid do
  @moduledoc """
  Utilities specific to 2d array maps.
  """

  @doc """
  `transpose/1` transposes a 2d-array, i.e. 
  converts rows to columns and vice versa.
  """
  def transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc """
  `get_adjacent/2` takes a coordinate formatted like {x, y}
  and returns a list of all adjacent coordinates. If the optional
  `diagonal` parameter is set to `true`, diagonal coordinates
  are included as well
  """
  def get_adjacent(coords, diagonal \\ false)

  def get_adjacent({x, y}, :vertical), do: [{x, y - 1}, {x, y + 1}]
  def get_adjacent({x, y}, :horizontal), do: [{x - 1, y}, {x + 1, y}]

  def get_adjacent({x, y}, :diagonal) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  def get_adjacent({x, y}, :diagonal_only) do
    [
      {x - 1, y - 1},
      {x + 1, y - 1},
      {x - 1, y + 1},
      {x + 1, y + 1}
    ]
  end

  def get_adjacent({x, y}, _) do
    [{x, y - 1}, {x - 1, y}, {x + 1, y}, {x, y + 1}]
  end

  def get_adjacent_directions(:diagonal) do
    [
      {0, -1},
      {-1, 0},
      {1, 0},
      {0, 1},
      {-1, -1},
      {1, -1},
      {-1, 1},
      {1, 1}
    ]
  end

  def distance({ax, ay}, {bx, by}) do
    {bx - ax, by - ay}
  end

  def bounds(%{} = grid) do
    {xs, ys} =
      grid
      |> Map.keys()
      |> Enum.unzip()

    {Enum.max(xs), Enum.max(ys)}
  end

  def in_bounds?({x, y}, _) when x < 0 or y < 0, do: false
  def in_bounds?({x, y}, {max_x, max_y}), do: x <= max_x and y <= max_y

  def manhattan_distance({ax, ay}, {bx, by}) do
    abs(bx - ax) + abs(by - ay)
  end

  def move_coords({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def map_from_grid(string, func \\ false) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, "", trim: true) |> Enum.with_index()))
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> Enum.map(fn {cell, x} ->
        {{x, y},
         if func do
           apply(func, [cell])
         else
           cell
         end}
      end)
    end)
    |> Enum.into(%{})
  end

  def travel({_, _} = init, {dx, dy}, distance) do
    1..distance
    |> Enum.map(&{dx * &1, dy * &1})
    |> Enum.map(&move_coords(init, &1))
  end

  def manhattan_circle({x, y}, r) do
    for dx <- -r..r, dy <- -r..r, abs(dx) + abs(dy) <= r do
      {x + dx, y + dy}
    end
  end

  def midpoint({max_x, max_y}) do
    {div(max_x, 2), div(max_y, 2)}
  end

  def wrap(coord, max) when is_integer(coord) and is_integer(max) do
    coord
    |> rem(max)
    |> Kernel.+(max)
    |> rem(max)
  end

  def wrap({x, y}, {max_x, max_y}) do
    {wrap(x, max_x), wrap(y, max_y)}
  end

  def wrap(coord, max) when is_integer(coord) and is_integer(max) do
    coord
    |> rem(max)
    |> Kernel.+(max)
    |> rem(max)
  end
end
