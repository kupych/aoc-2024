defmodule Aoc.Day13 do
  @moduledoc """
  Solutions for Day 13.
  """
  @behaviour Aoc.Day

  alias Aoc.{Day, Utilities}

  @bignum 10_000_000_000_000

  @impl Day
  def day(), do: 13

  @impl Day
  def a(games) do
    games
    |> Enum.map(&play_game/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end

  @impl Day
  def b(games) do
    games
    |> Enum.map(&play_game_b/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_game/1)
  end

  defp parse_game(game) do
    game
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line("Button A: X+" <> numbers, acc) do
    Map.put(acc, :a, do_parse_coords(numbers))
  end

  defp parse_line("Button B: X+" <> numbers, acc) do
    Map.put(acc, :b, do_parse_coords(numbers))
  end

  defp parse_line("Prize: X=" <> prize, acc) do
    Map.put(acc, :prize, do_parse_coords(prize))
  end

  defp parse_line(_, acc), do: acc

  defp do_parse_coords(line) do
    [x, y] =
      line
      |> String.split(~r/\D+/)
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end

  def play_game(%{prize: {px, py}, a: {ax, ay}, b: {bx, by}} = game) do
    if rem(px, Utilities.gcd([ax, bx])) > 0 or rem(py, Utilities.gcd([ay, by])) > 0 do
      nil
    else
      max_x = ceil(px / ax)

      0..max_x
      |> Enum.map(&find_combination(&1, game))
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&score/1)
      |> case do
        [] -> nil
        scores -> Enum.min(scores)
      end
    end
  end

  def play_game_b(%{prize: {px, py}, a: {ax, ay}, b: {bx, by}}) do
    px = @bignum + px
    py = @bignum + py
    a = (px * by - py * bx) / (ax * by - ay * bx)
    b = (py * ax - px * ay) / (ax * by - ay * bx)

    if trunc(a) == a and trunc(b) == b do
      3 * trunc(a) + trunc(b)
    else
      nil
    end
  end

  defp find_combination(na, %{prize: {px, py}, a: {ax, ay}, b: {bx, by}}) do
    rem_x = px - na * ax

    with 0 <- rem(rem_x, bx),
         nb <- div(rem_x, bx),
         ^py <- na * ay + nb * by do
      {na, nb}
    else
      _ ->
        nil
    end
  end

  defp score({na, nb}), do: 3 * na + nb
end
