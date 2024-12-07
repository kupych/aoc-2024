defmodule Aoc.Day5 do
  @moduledoc """
  Solutions for Day 5.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 5

  @impl Day
  def a(%{rules: rules, updates: updates}) do
    updates
    |> Enum.filter(&is_valid?(&1, rules))
    |> Enum.map(&get_middle_number/1)
    |> Enum.sum()
  end

  @impl Day
  def b(%{rules: rules, updates: updates}) do
    updates
    |> Enum.reject(&is_valid?(&1, rules))
    |> Enum.map(&reorder(&1, rules))
    |> Enum.map(&get_middle_number/1)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    [rules, updates] =
      file
      |> String.split("\n\n", trim: true)

    rules =
      rules
      |> String.split(~r/\D+/s, trim: true)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [a, b] -> {String.trim(a), String.trim(b)} end)

    updates =
      updates
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ","))

    %{rules: rules, updates: updates}
  end

  defp is_valid?(update, rules) do
    rules = build_update_tree(rules, update)

    update
    |> Enum.map(&in_order?(&1, update, Map.get(rules, &1)))
    |> Enum.all?()
  end

  defp get_middle_number(update) do
    update
    |> Enum.count()
    |> div(2)
    |> then(&Enum.at(update, &1))
    |> String.to_integer()
  end

  defp build_update_tree(rules, update) do
    Enum.flat_map(
      update,
      &Enum.filter(rules, fn
        {^&1, _} -> true
        {_, ^&1} -> true
        _ -> false
      end)
    )
    |> Enum.sort_by(&elem(&1, 1))
    |> build_tree()
  end

  defp build_tree(nodes, acc \\ %{})
  defp build_tree([], acc), do: acc

  defp build_tree([{pre, post} | rest], acc) do
    acc
    |> Map.update(pre, %{before: [], after: [post]}, fn %{after: a} = neighbors ->
      %{neighbors | after: [post | a]}
    end)
    |> Map.update(post, %{before: [pre], after: []}, fn %{before: b} = neighbors ->
      %{neighbors | before: [pre | b]}
    end)
    |> then(&build_tree(rest, &1))
  end

  defp in_order?(page, update, %{before: b, after: a}) do
    {pre, [_ | post]} = Enum.split_while(update, &(&1 != page))

    MapSet.disjoint?(MapSet.new(b), MapSet.new(post)) and
      MapSet.disjoint?(MapSet.new(a), MapSet.new(pre))
  end

  defp reorder(update, rules) do
    rules = build_update_tree(rules, update)

    Enum.sort(update, &compare_nodes(&1, &2, rules))
  end

  defp compare_nodes(a, b, rules) do
    %{after: after_a} = Map.get(rules, a)
    %{before: before_b} = Map.get(rules, b)

    a in before_b and b in after_a
  end
end
