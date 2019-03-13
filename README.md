# Minesweeper
A simple minesweeper built with elixir
```
▶ ./minesweeper --dimension 7 --mines 6
0    0    0    0    1    1    1
0    0    1    .    2    . 1
0    0    1    mine 4    3    2
0    0    1    2    .    .    1
0    0    0    2    3    3    1
1    1    1    1    .    1    0
1    .    1    1    1    1    0
```
## Building
```bash
mix deps.get
mix escript.build
```

## Running
```bash
./minesweeper --dimension 7 --mines 6
```

## Commands
`r1c3` -> select cell at row 1 column 3

`quit` -> end game

