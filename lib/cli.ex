defmodule Minesweeper.CLI do
  @moduledoc """
  Documentation for Minesweeper.
  """

  @params [
    dimension: :integer,
    mines: :integer,
  ]

  defmodule CellState do
    defstruct value: 0, visible: false
  end

  defmodule Cell do
    defstruct [:row, :column]
  end

  defmodule Board do
    defstruct [:dimension, :state]
  end

  def seed_mines(dimension, num_mines) do
    rows = Enum.shuffle(1..dimension)
    columns = Enum.shuffle(1..dimension)

    rows
    |> Enum.zip(columns)
    |> Enum.take_random(num_mines)
    |> Enum.map(fn {r, c} ->
      %Cell{ row: r, column: c}
    end)
    |> MapSet.new()
  end

  def render_cell(r, c, state) do
    state
    |> Map.get(cell_key({r, c}))
    |> case do
      %CellState{visible: false, value: _value} ->
        "."

      %CellState{visible: true, value: value} ->
        value
    end
    |> to_string()
    |> String.pad_trailing(4)
  end


  def print_game(%Board{state: state, dimension: dimension} = board) do
    for r <- 1..dimension do
      for c <- 1..dimension do
        render_cell(r, c, state)
      end
    end
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
    |> IO.puts()

    board
  end

  def cell_key({r, c}), do: String.to_atom("r#{r}c#{c}")
  def bounded_range(min, max, [min: min_bound, max: max_bound]) do
    new_min = if min < min_bound, do: min_bound, else: min
    new_max = if max > max_bound, do: max_bound, else: max

    new_min..new_max
  end

  def add_mine_to_state({r, c} = mine, state, dimension) do
    rows = bounded_range(r-1, r+1, min: 1, max: dimension)
    columns = bounded_range(c-1, c+1, min: 1, max: dimension)

    state_with_mine = Map.put(state, cell_key(mine), %CellState{value: :mine})
    grid = for gr <- rows, gc <- columns, do: {gr, gc}

    Enum.reduce(grid, state_with_mine, fn cell, new_state ->
      case Map.get(new_state, cell_key(cell)) do
        %CellState{value: :mine} ->
          new_state

        %CellState{value: value} ->
          Map.put(new_state, cell_key(cell), %CellState{value: value + 1})
      end
    end)
  end

  def init_state(dimension, num_mines) do
    cells = for c <- 1..dimension, r <- 1..dimension, do: {r, c}
    blank_state = Map.new(cells, fn cell -> {cell_key(cell), %CellState{}} end)

    state =
      cells
      |> Enum.take_random(num_mines)
      |> Enum.reduce(blank_state, &add_mine_to_state(&1, &2, dimension))

    %Board{
      dimension: dimension,
      state: state
    }
  end

  def update_board("quit", _board), do: nil
  def update_board(command, %Board{state: state} = board) do
    key = String.to_atom(command)
    cell = Map.get(state, key)
    updated_cell = Map.put(cell, :visible, true)

    state
    |> Map.put(key, updated_cell)
    |> fn new_state -> Map.put(board, :state, new_state) end.()
    |> print_game()
    |> init_turn()
  end

  def init_turn(board) do
    "select a square by r1c2\n"
    |> IO.gets()
    |> String.trim()
    |> update_board(board)
  end

  def start_game(dimension, num_mines) do
    dimension
    |> init_state(num_mines)
    |> print_game()
    |> init_turn()
  end

  def main(args) do
    {[dimension: dimension, mines: num_mines], _, _} = OptionParser.parse(args, strict: @params)
    start_game(dimension, num_mines)
  end
end
