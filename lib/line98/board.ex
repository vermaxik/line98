defmodule Line98.Board do
  alias __MODULE__

  defstruct(
    width: 10,
    height: 10,
    start_point: {1, 1},
    exit_point: {1, 1},
    walls: MapSet.new()
  )

  def add_wall(maze, point) do
    %{maze | walls: MapSet.put(maze.walls, point)}
  end

  def wall?(%Board{width: width}, {x, _}) when x < 1 or width < x, do: true
  def wall?(%Board{height: height}, {_, y}) when y < 1 or height < y, do: true

  def wall?(maze, point) do
    maze.walls
    |> MapSet.member?(point)
  end
end
