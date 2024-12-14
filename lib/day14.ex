defmodule Aoc.Day14 do
  @moduledoc """
  Solutions for Day 14.
  """
  @behaviour Aoc.Day

  alias Aoc.Day
  alias Aoc.Utilities.Grid

  @impl Day
  def day(), do: 14

  @impl Day
  def a(bots, max \\ {101, 103}) do
    bots
    |> Enum.map(&walk(&1, 100, max))
    |> Enum.reduce([0, 0, 0, 0], &safety_score(&1, &2, Grid.midpoint(max)))
    |> Enum.product()
  end

  @impl Day
  def b(robots, max \\ {101, 103}) do
    1..10000
    |> Enum.reduce_while({0, robots}, fn _, {step, robots} ->
      if has_lines?(robots) do
        {:halt, step}
      else
        robots = Enum.map(robots, fn [_, v] = k -> [walk(k, 1, max), v] end)

        {:cont, {step + 1, robots}}
      end
    end)
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_robot/1)
  end

  def parse_robot(line) do
    ~r/p\=(\d+),(\d+) v\=(-?\d+),(-?\d+)/
    |> Regex.run(line)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
  end

  def walk([[x, y], [vx, vy]], steps, {max_x, max_y}) do
    [Grid.wrap(x + steps * vx, max_x), Grid.wrap(y + steps * vy, max_y)]
  end

  def safety_score([x, y], [a, b, c, d], {mid_x, mid_y}) when x < mid_x and y < mid_y,
    do: [a + 1, b, c, d]

  def safety_score([x, y], [a, b, c, d], {mid_x, mid_y}) when x > mid_x and y < mid_y,
    do: [a, b + 1, c, d]

  def safety_score([x, y], [a, b, c, d], {mid_x, mid_y}) when x < mid_x and y > mid_y,
    do: [a, b, c + 1, d]

  def safety_score([x, y], [a, b, c, d], {mid_x, mid_y}) when x > mid_x and y > mid_y,
    do: [a, b, c, d + 1]

  def safety_score(_, count, _), do: count

  defp has_lines?(robots) do
    horizontal_line? =
      robots
      |> Enum.map(&hd/1)
      |> Enum.group_by(&tl/1)
      |> Enum.any?(fn {_, v} -> Enum.count(v) >= 20 end)

    vertical_line? =
      robots
      |> Enum.map(&hd/1)
      |> Enum.group_by(&hd/1)
      |> Enum.any?(fn {_, v} -> Enum.count(v) >= 20 end)

    horizontal_line? and vertical_line?
  end
end
