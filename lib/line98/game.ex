defmodule Line98.Game do
  alias __MODULE__
  alias Line98.Ball
  alias Line98.Board
  alias Line98.Board.Solver

  defstruct balls: %{}, selected_field: nil, score: 0

  def new do
    %__MODULE__{}
    |> init_fill()
  end

  defp init_fill(board) do
    balls = Ball.build("ball", 3) |> Ball.build("dot", 3)
    %Game{board | balls: balls}
  end

  def select_field(board, coordinate) do
    IO.inspect(coordinate)

    case board.balls[coordinate] do
      {_, "ball"} ->
        %Game{board | selected_field: coordinate}

      _ ->
        board
    end
  end

  def move(%Game{selected_field: nil} = board, _), do: board

  def move(%Game{selected_field: selected_field} = board, to) when to === selected_field,
    do: board

  def move(%Game{balls: balls, selected_field: selected_field} = board, to) do
    solution =
      %Board{
        start_point: selected_field,
        exit_point: to,
        walls: Ball.walls(balls, selected_field)
      }
      |> Solver.shortest_route()

    cond do
      Ball.avoid_cells(balls, to) ->
        board

      is_atom(solution) && solution == :none ->
        %Game{board | selected_field: nil}

      true ->
        new_balls = grow_and_generate_balls(board, to)

        %Game{board | selected_field: nil, balls: new_balls}
        |> IO.inspect(label: "Game#board")
        |> get_score(to)
    end
  end

  def grow_and_generate_balls(%Game{balls: balls, selected_field: selected_field} = board, to) do
    selected_ball = balls[selected_field]

    Map.delete(balls, selected_field)
    |> Map.put(to, selected_ball)
    |> Ball.grow()
    |> Ball.build("dot", 3)
  end

  def get_score(%Game{balls: balls, score: score} = board, {x, y} = to) do
    check_balls =
      balls
      |> Ball.get_by_vertical(x)
      |> IO.inspect(label: "get_by_vertical")

    ids = for {{^x, y}, {_, "ball"}} <- check_balls, do: y

    ids |> IO.inspect(label: "ids")

    ids
    |> Enum.reverse()
    |> Enum.reduce([], fn
      id, [head = [h | _] | tail] when id == h - 1 -> [[id | head] | tail]
      id, acc -> [[id] | acc]
    end)
    |> IO.inspect(charlists: :as_integers, label: "sequence")

    board
  end

  def update_score(%Game{balls: balls, score: score} = board, check_balls, color) do
    cond do
      check_balls[color] == nil ->
        board

      length(check_balls[color]) >= 5 ->
        %Game{board | balls: balls, score: score + 10}

      true ->
        board
    end
  end
end
