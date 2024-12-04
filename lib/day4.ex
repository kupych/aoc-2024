defmodule Aoc.Day4 do
  @moduledoc """
  Solutions for Day 4.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @impl Day
  def day(), do: 4

  @impl Day
  def a(letters) do
    letters
    |> Enum.filter(fn {_, cell} -> cell == "X" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(%{grid: letters, xmases: []}, &find_xmas/2)
    |> Map.get(:xmases)
    |> Enum.count()
  end

  @impl Day
  def b(letters) do
    letters
    |> Enum.filter(fn {_, cell} -> cell == "A" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(%{grid: letters, x_mases: []}, &find_x_mas/2)
    |> Map.get(:x_mases)
    |> Enum.count()
  end

  @impl Day
  def parse_input() do
    with {:ok, file} <- Day.load(__MODULE__) do
      Utilities.map_from_grid(file)
    end
  end

  defp find_x_mas(a, %{grid: grid, x_mases: x_mases} = acc) do
    a
    |> Utilities.get_adjacent(:diagonal_only)
    |> Enum.map(&Map.get(grid, &1))
    |> case do
      ["M", "M", "S", "S"] -> %{acc | x_mases: [a | x_mases]}
      ["S", "S", "M", "M"] -> %{acc | x_mases: [a | x_mases]}
      ["M", "S", "M", "S"] -> %{acc | x_mases: [a | x_mases]}
      ["S", "M", "S", "M"] -> %{acc | x_mases: [a | x_mases]}
      _ -> acc
    end
  end

  defp find_xmas(x, %{grid: grid, xmases: xmases} = acc) do
    xmases =
      :diagonal
      |> Utilities.get_adjacent_directions()
      |> Enum.map(&[x | Utilities.travel(x, &1, 3)])
      |> Enum.reduce([], &do_find_xmas(&1, &2, grid))
      |> Kernel.++(xmases)

    %{acc | xmases: xmases}
  end

  defp do_find_xmas(points, acc, grid) do
    points
    |> Enum.map(&Map.get(grid, &1))
    |> case do
      ["X", "M", "A", "S"] -> [points | acc]
      _ -> acc
    end
  end
end
