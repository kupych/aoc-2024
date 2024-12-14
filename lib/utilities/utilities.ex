defmodule Aoc.Utilities do
  @moduledoc """
  Generic utilities for Advent of Code puzzles.
  """

  @doc """
  `binary_to_digits/1` takes a string of 
  numbers and converts it to a tuple of
  integers representing the digits.
  """
  def binary_to_digits(string) do
    string
    |> binary_to_digit_enum()
    |> List.to_tuple()
  end

  def binary_to_digit_enum(string) do
    string
    |> String.codepoints()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Calculates the greatest common divisor (GCD) of a list of integers.
  """
  def gcd([number | numbers]) do
    Enum.reduce(numbers, number, &do_gcd/2)
  end

  defp do_gcd(a, 0), do: a
  defp do_gcd(a, b), do: do_gcd(b, rem(a, b))

  @doc """
  Calculates the least common multiple (LCM) of a list of integers.
  """
  def lcm([number | numbers]) do
    Enum.reduce(numbers, number, &do_lcm/2)
  end

  defp do_lcm(a, b), do: trunc(a * b / do_gcd(a, b))
end
