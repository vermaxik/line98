defmodule Line98.Game do
  alias __MODULE__
  alias Line98.Ball
  alias Line98.Board
  alias Line98.Board.Solver

  @destroy_balls 5

  defstruct balls: %{}, selected_field: nil, score: 0, path: []

  def new do
    %__MODULE__{}
    |> initial_state()
  end

  defp initial_state(board) do
    balls =
      Ball.build("ball", 5)
      |> Ball.build("dot", 3)

    %Game{board | balls: balls}
  end

  def over?(board) do
    map_size(board.balls) >= 100
  end

  def select(board, coordinate) do
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

        %Game{board | selected_field: nil, balls: new_balls, path: solution}
        |> IO.inspect(label: "Game#board")
        |> calculate_scores(to)
    end
  end

  def calculate_scores(board, to) do
    board
    |> get_score_vertical(to, "red")
    |> get_score_horizontal(to, "red")
    |> get_score_vertical(to, "green")
    |> get_score_horizontal(to, "green")
    |> get_score_vertical(to, "blue")
    |> get_score_horizontal(to, "blue")
  end

  def grow_and_generate_balls(%Game{balls: balls, selected_field: selected_field} = board, to) do
    selected_ball = balls[selected_field]

    Map.delete(balls, selected_field)
    |> Map.put(to, selected_ball)
    |> Ball.grow()
    |> Ball.build("dot", 3)
  end

  def get_score_vertical(%Game{balls: balls} = board, {x, y} = to, color) do
    color_balls = Ball.group_by_color_vertical(balls, x)[color]

    color_balls
    |> Ball.vertical_ids(x)
    |> Game.sequence()
    |> Enum.filter(fn n -> length(n) >= @destroy_balls end)
    |> List.first()
    |> update_score_x(board, x)
  end


  def get_score_horizontal(%Game{balls: balls} = board, {x, y} = to, color) do
    color_balls = Ball.group_by_color_horizontal(balls, y)[color]

    color_balls
    |> Ball.horizontal_ids(y)
    |> Game.sequence()
    |> Enum.filter(fn n -> length(n) >= @destroy_balls end)
    |> List.first()
    |> update_score_y(board, y)
  end

  def sequence(ids) do
    ids
    |> Enum.reverse()
    |> Enum.reduce([], fn
      id, [head = [h | _] | tail] when id == h - 1 -> [[id | head] | tail]
      id, acc -> [[id] | acc]
    end)
    |> IO.inspect(charlists: :as_integers, label: "sequence")
  end

  def update_score_x(nil, board, _line), do: board

  def update_score_x(ids, %Game{balls: balls, score: score} = board, line) do
    balls =
      Enum.reduce(ids, balls, fn id, acc ->
        Map.delete(acc, {line, id})
      end)

    %Game{board | balls: balls, score: length(ids) * 2 + score}
  end

  def update_score_y(nil, board, _line), do: board

  def update_score_y(ids, %Game{balls: balls, score: score} = board, line) do
    balls =
      Enum.reduce(ids, balls, fn id, acc ->
        Map.delete(acc, {id, line})
      end)

    %Game{board | balls: balls, score: length(ids) * 2 + score}
  end
end
