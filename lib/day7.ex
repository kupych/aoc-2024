defmodule Aoc.Day7 do
  @moduledoc """
  Solutions for Day 7.
  """
  @behaviour Aoc.Day

  alias Aoc.Day

  @impl Day
  def day(), do: 7

  @impl Day
  def a(values) do
    values
    |> Enum.map(&find_valid_combinations/1)
    |> Enum.filter(& &1.valid?)
    |> Enum.reduce(0, &(&2 + &1.value))
  end

  @impl Day
  def b(values) do
    values = Enum.map(values, &find_valid_combinations/1)

    {valid, invalid} = Enum.split_with(values, & &1.valid?)

    new_valid =
      invalid
      |> Enum.map(&find_valid_combinations(&1, 3))
      |> Enum.filter(& &1.valid?)
      |> Enum.map(& &1.value)

    valid
    |> Enum.map(& &1.value)
    |> Enum.concat(new_valid)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file) do
    file
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [value | operands] =
      line
      |> String.split(~r/\D+/, trim: true)
      |> Enum.map(&String.to_integer/1)

    %{value: value, operands: operands}
  end

  defp find_valid_combinations(%{value: value, operands: operands} = calc, options \\ 2) do
    spaces = Enum.count(operands) - 1
    permutations = options ** spaces - 1

    calculations =
      0..permutations
      |> Enum.map(&Integer.to_string(&1, options))
      |> Enum.map(&String.pad_leading(&1, spaces, "0"))
      |> Enum.map(&String.codepoints/1)
      |> Enum.reduce_while(false, &evaluate(&1, &2, operands, value))

    Map.put(calc, :valid?, calculations)
  end

  defp evaluate(operators, _, [first | operands], value) do
    evaluate(%{operators: operators, operands: operands, result: first}, value)
  end

  defp evaluate(%{operators: [], operands: [], result: result}, value) do
    if result == value do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  # Concatenation operator (||) : e.g. 12 || 345 = 12345
  defp evaluate(%{operators: ["2" | ops], operands: [b | operands], result: a}, value) do
    digits = b |> :math.log10() |> trunc() |> Kernel.+(1)
    evaluate(%{operators: ops, operands: operands, result: a * 10 ** digits + b}, value)
  end

  # Multiplication
  defp evaluate(%{operators: ["1" | ops], operands: [b | operands], result: a}, value) do
    evaluate(%{operators: ops, operands: operands, result: a * b}, value)
  end

  # Addition
  defp evaluate(%{operators: ["0" | ops], operands: [b | operands], result: a}, value) do
    evaluate(%{operators: ops, operands: operands, result: a + b}, value)
  end
end
