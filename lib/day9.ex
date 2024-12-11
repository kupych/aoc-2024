defmodule Aoc.Day9 do
  @moduledoc """
  Solutions for Day 9.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 9

  @impl Day
  def a(structure) do
    structure
    |> get_blocks()
    |> Enum.reduce_while(structure, &compact/2)
    |> checksum()
  end

  @impl Day
  def b(structure) do
    structure
    |> get_grouped_blocks()
    |> Enum.reduce(structure, &defrag/2)
    |> checksum()
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
    |> process_input(%{pointer: 0, current: 0, spaces: [], space_blocks: %{}})
  end

  defp process_input([], structure), do: structure
  defp process_input([a], structure), do: process_input([a, 0], structure)

  defp process_input(
         [a, b | rest],
         %{current: c, pointer: p, spaces: s, space_blocks: sb} = structure
       ) do
    data = 1..a |> Enum.map(fn _ -> c end) |> Enum.with_index(p)

    free_space =
      if b > 0 do
        1..b |> Enum.map(fn _ -> nil end) |> Enum.with_index(p + a)
      else
        []
      end

    new_spaces = Enum.map(free_space, &elem(&1, 1))

    data
    |> Enum.concat(free_space)
    |> Enum.reduce(structure, fn {v, k}, acc -> Map.put(acc, k, v) end)
    |> Map.put(:current, c + 1)
    |> Map.put(:pointer, p + a + b)
    |> Map.put(:spaces, s ++ new_spaces)
    |> Map.put(:space_blocks, Map.put(sb, p + a, b))
    |> then(&process_input(rest, &1))
  end

  defp compact(_, %{spaces: []} = structure), do: {:halt, structure}
  defp compact({i, _}, %{spaces: [s | _]} = structure) when s >= i, do: {:halt, structure}

  defp compact({i, b}, %{spaces: [s | spaces]} = structure) do
    {:cont, %{structure | :spaces => spaces, i => nil, s => b}}
  end

  defp defrag({{v, l}, vals}, %{space_blocks: space_blocks} = structure) do
    [{start, _} | _] = vals

    case leftmost_free(structure, l, start) do
      {fk, fl} ->
        structure =
          vals
          |> Enum.reduce(structure, fn {k, _}, acc -> Map.put(acc, k, nil) end)
          |> then(&Enum.reduce(fk..(fk + l - 1), &1, fn nk, acc -> Map.put(acc, nk, v) end))

        space_blocks =
          space_blocks
          |> Map.delete(fk)
          |> Map.put(fk + l, fl - l)

        %{structure | space_blocks: space_blocks}

      _ ->
        structure
    end
  end

  defp checksum(structure) do
    structure
    |> Map.drop([:pointer, :current, :spaces, :space_blocks])
    |> Enum.reduce(0, fn
      {_, nil}, acc -> acc
      {k, v}, acc -> acc + k * v
    end)
  end

  defp get_blocks(%{} = structure) do
    structure
    |> Enum.filter(fn {k, v} -> is_integer(v) and is_integer(k) end)
    |> Enum.sort_by(fn {k, _} -> k end, :desc)
  end

  defp get_grouped_blocks(%{} = structure) do
    structure
    |> Enum.filter(fn {k, v} -> is_integer(v) and is_integer(k) end)
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.map(fn {k, v} -> {{k, Enum.count(v)}, Enum.sort_by(v, &elem(&1, 0))} end)
    |> Enum.sort_by(&elem(&1, 0), :desc)
  end

  defp leftmost_free(%{space_blocks: sb}, length, index) do
    sb
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.find(fn {k, v} -> v >= length and k < index end)
  end

  def print_structure(structure) do
    structure
    |> Enum.filter(fn {k, _} -> is_integer(k) end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn
      {_, nil} -> "."
      {_, v} -> "#{v}"
    end)
    |> Enum.join()
  end
end
