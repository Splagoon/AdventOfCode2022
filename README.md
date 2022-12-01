# Advent of Code 2022

## About

[Advent of Code](https://adventofcode.com/) is an annual programming puzzle challenge oragized by [Eric Wastl](http://was.tl/). Between December 1 and December 25 (Christmas), a new programming puzzle is posted daily. This repo contains my solutions for the [2022 puzzles](https://adventofcode.com/2022). I encourage everyone to solve the puzzles on their own before looking at my solutions.

## Running the Code

Each puzzle will have its own folder in this repository, named with the day of the month the puzzle was posted. Each folder will have the input as a text file and the solution as an Elixir script. To run the solutions, you must have [Elixir 1.14+](https://elixir-lang.org/install.html) installed.

Open the repo on the command line and first install the dependencies:
```sh
mix deps.get
```
Then run a solution with:
```sh
mix run lib/XX/solution.exs
```
Where `XX` is the date of the puzzle, `01` through `25`.

All of the scripts should be platform-agnostic and run wherever Elixir is supported.