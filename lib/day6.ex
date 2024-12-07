defmodule Aoc.Day6 do
  @moduledoc """
  Solutions for Day 6.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @dirs %{0 => {0, -1}, 1 => {1, 0}, 2 => {0, 1}, 3 => {-1, 0}}
  @obstacle "#"
  @path "."

  @impl Day
  def day(), do: 6

  @impl Day
  def a(state) do
    state
    |> walk()
    |> Map.get(:path)
    |> Enum.uniq()
    |> Enum.count()
  end

  @impl Day
  def b(state) do
    state
    |> walk()
    |> Map.get(:path)
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
    |> Enum.uniq()
    |> Enum.map(&add_obstacle(&1, state))
    |> Enum.map(&walk/1)
    |> Enum.count(&(&1 == :loop))
  end

  @impl Day
  def parse_input(file) do
    map = Utilities.map_from_grid(file)

    start =
      map
      |> Enum.find(fn {_, v} -> v == "^" end)
      |> elem(0)

    %{map: Map.put(map, start, "."), dir: 0, path: [start], visited: MapSet.new()}
  end

  defp walk(%{dir: dir, map: map, path: [current | _] = path, visited: visited} = state) do
    if MapSet.member?(visited, {current, dir}) do
      :loop
    else
      current
      |> Utilities.move_coords(@dirs[dir])
      |> then(&Map.get(map, &1))
      |> case do
        @obstacle ->
          walk(%{state | dir: rem(dir + 1, 4)})

        @path ->
          walk(%{
            state
            | path: [Utilities.move_coords(current, @dirs[dir]) | path],
              visited: MapSet.put(visited, {current, dir})
          })

        nil ->
          state
      end
    end
  end

  defp add_obstacle(coord, %{map: map} = state) do
    %{state | map: Map.put(map, coord, @obstacle)}
  end
end
