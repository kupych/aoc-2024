defmodule Aoc.Day13 do
  @moduledoc """
  Solutions for Day 13.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 13

  @impl Day
  def a(_) do
    :not_solved
  end

  @impl Day
  def b(_) do
    :not_solved
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split("\n", trim: true)
  end
end
