defmodule MinesweeperTest do
  use ExUnit.Case
  doctest Minesweeper

  test "greets the world" do
    assert Minesweeper.hello() == :world
  end
end
