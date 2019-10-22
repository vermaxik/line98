defmodule Maze do
  defstruct(
    width: 10,
    height: 10,
    start_point: {0, 0},
    exit_point: {0, 0},
    walls: MapSet.new()
  )

  def add_wall(maze, point) do
    %{maze | walls: MapSet.put(maze.walls, point)}
  end

  def wall?(%Maze{width: width}, {x, _}) when x < 0 or width <= x, do: true
  def wall?(%Maze{height: height}, {_, y}) when y < 0 or height <= y, do: true

  def wall?(maze, point) do
    maze.walls
    |> MapSet.member?(point)
  end
end
