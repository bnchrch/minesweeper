defmodule Minesweeper.CLI do
  @moduledoc """
  Documentation for Minesweeper.
  """

  @params [
    dimension: :integer,
    mines: :integer,
  ]

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
    |> to_string()
    |> String.pad_trailing(4)
  end


  def print_game(%Board{state: state, dimension: dimension}) do
    for c <- 1..dimension do
      for r <- 1..dimension do
        render_cell(r, c, state)
      end
    end
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
    |> IO.puts()
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

    state_with_mine = Map.put(state, cell_key(mine), :mine)
    grid = for gr <- rows, gc <- columns, do: {gr, gc}

    Enum.reduce(grid, state_with_mine, fn cell, new_state ->
      case Map.get(new_state, cell_key(cell)) do
        :mine ->
          new_state

        value ->
          Map.put(new_state, cell_key(cell), value + 1)
      end
    end)


  end

  def init_state(dimension, num_mines) do
    cells = for c <- 1..dimension, r <- 1..dimension, do: {r, c}
    blank_state = Map.new(cells, fn cell -> {cell_key(cell), 0} end)

    state =
      cells
      |> Enum.take_random(num_mines)
      |> Enum.reduce(blank_state, &add_mine_to_state(&1, &2, dimension))

    %Board{
      dimension: dimension,
      state: state
    }
  end

  def start_game(dimension, num_mines) do
    dimension
    |> init_state(num_mines)
    |> print_game()
  end

  def main(args) do
    {[dimension: dimension, mines: num_mines], _, _} = OptionParser.parse(args, strict: @params)
    IO.puts("#{dimension}#{num_mines}")
    start_game(dimension, num_mines)
  end
end
