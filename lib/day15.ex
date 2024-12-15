defmodule Aoc.Day15 do
  @moduledoc """
  Solutions for Day 15.
  """
  @behaviour Aoc.Day

  alias Aoc.Day
  alias Aoc.Utilities.Grid

  @steps %{
    "<" => {-1, 0},
    "^" => {0, -1},
    ">" => {1, 0},
    "v" => {0, 1}
  }

  @impl Day
  def day(), do: 15

  @impl Day
  def a(file) do
    %{map: map, steps: steps} = start_map(file)
    new_map = Enum.reduce(steps, map, &walk(&1, &2))

    new_map
    |> Enum.filter(fn {_, v} -> v == "O" end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(fn {x, y} -> y * 100 + x end)
    |> Enum.sum()
  end

  @impl Day
  def b(file) do
    %{map: %{start: start} = map, steps: steps} = start_map(file, true)
    %{"#" => walls, "[" => boxes} = Enum.group_by(map, &elem(&1, 1), &elem(&1, 0))

    steps
    |> Enum.reduce(
      %{start: start, boxes: MapSet.new(boxes), walls: MapSet.new(walls)},
      &walk_b/2
    )
    |> Map.get(:boxes)
    |> Enum.map(fn {x, y} -> y * 100 + x end)
    |> Enum.sum()
  end

  @impl Day
  def parse_input(file), do: file

  def start_map(file, double? \\ false) do
    [map, steps] = String.split(file, "\n\n", trim: true)

    map = if double?, do: double_map(map), else: map

    steps =
      steps
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&String.codepoints/1)

    %{map: Grid.map_from_grid(map, start_char: "@"), steps: steps}
  end

  def walk(step, %{start: coords} = map) do
    dir = @steps[step]

    map =
      Stream.unfold(coords, &try_move(&1, dir, map))
      |> Enum.to_list()
      |> tl()
      |> Enum.reverse()
      |> case do
        [{:wall, _} | _] ->
          map

        [{:space, last} | rest] ->
          [new_coords | rest] = Enum.reverse([last | rest])

          map
          |> Map.put(new_coords, ".")
          |> Map.put(:start, new_coords)
          |> then(&Enum.reduce(rest, &1, fn coords, map -> Map.put(map, coords, "O") end))
      end

    map
  end

  def walk_b(step, %{start: start, boxes: boxes, walls: walls} = state) do
    new_dir = @steps[step]

    next_boxes = next_boxes(start, new_dir, boxes, walls)

    cond do
      MapSet.member?(walls, Grid.move_coords(start, new_dir)) ->
        state

      next_boxes == :blocked ->
        state

      Enum.any?(next_boxes) ->
        new = Enum.map(next_boxes, &Grid.move_coords(&1, new_dir))

        boxes =
          next_boxes
          |> Enum.reduce(boxes, &MapSet.delete(&2, &1))
          |> then(&Enum.reduce(new, &1, fn x, acc -> MapSet.put(acc, x) end))

        %{state | start: Grid.move_coords(start, new_dir), boxes: boxes}

      true ->
        %{state | start: Grid.move_coords(start, new_dir)}
    end
  end

  def try_move({x, _} = coords, dir, map) when is_integer(x) do
    new_coords = Grid.move_coords(coords, dir)

    case Map.get(map, new_coords) do
      "O" -> {coords, new_coords}
      "." -> {coords, {:space, new_coords}}
      "#" -> {coords, {:wall, new_coords}}
      _ -> {new_coords, nil}
    end
  end

  def try_move(nil, _, _), do: nil
  def try_move(value, _, _), do: {value, nil}

  def double_map("#" <> rest), do: "##" <> double_map(rest)
  def double_map("." <> rest), do: ".." <> double_map(rest)
  def double_map("O" <> rest), do: "[]" <> double_map(rest)
  def double_map("@" <> rest), do: "@." <> double_map(rest)
  def double_map("\n" <> rest), do: "\n" <> double_map(rest)
  def double_map(rest), do: rest

  def next_boxes({x, y}, dir, boxes, walls) do
    new_boxes = get_next_boxes({x, y}, dir) |> Enum.filter(&MapSet.member?(boxes, &1))
    next_boxes(new_boxes, [], dir, boxes, walls)
  end

  def next_boxes([], acc, _, _, _), do: acc

  def next_boxes([{bx, by} = box | rest], acc, dir, boxes, walls) do
    box_sides = [box, {bx + 1, by}]
    next_box_location = next_box_location(box_sides, dir)
    next = Enum.flat_map([box, {bx + 1, by}], &get_next_boxes(&1, dir)) |> Enum.uniq()

    if Enum.any?(next_box_location, &MapSet.member?(walls, &1)) do
      :blocked
    else
      next_to_push = Enum.filter(next, &MapSet.member?(boxes, &1))
      next_boxes(next_to_push ++ rest, [box | acc], dir, boxes, walls)
    end
  end

  def get_next_boxes(coords, {-1, _}), do: [Grid.move_coords(coords, {-2, 0})]
  def get_next_boxes(coords, {1, _} = d), do: [Grid.move_coords(coords, d)]

  def get_next_boxes(coords, {0, dy} = d) do
    [Grid.move_coords(coords, d), Grid.move_coords(coords, {-1, dy})]
  end

  def next_box_location([{lx, ly}, _], {-1, _}), do: [{lx - 1, ly}]
  def next_box_location([{_, _}, {rx, ry}], {1, _}), do: [{rx + 1, ry}]
  def next_box_location([{lx, y}, {rx, _}], {0, dy}), do: [{lx, y + dy}, {rx, y + dy}]
end
