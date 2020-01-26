defmodule Line98.Game do
  alias __MODULE__
  alias Line98.Ball
  alias Line98.Board
  alias Line98.Board.Solver

  @init_ball_count 5
  @init_dot_count 3
  @destroy_balls 5

  defstruct balls: %{}, selected_field: nil, score: 0, score_updated: false, path: [], to: nil

  def new do
    %__MODULE__{}
    |> initial_state()
  end

  defp initial_state(board) do
    balls =
      Ball.build("ball", @init_ball_count)
      |> Ball.build("dot", @init_dot_count)

    %Game{board | balls: balls}
  end

  def over?(board) do
    map_size(board.balls) >= 20
  end

  def select(board, coordinate) do
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
        new_balls = Ball.move_ball_to_cell(board.balls, selected_field, List.first(solution))

        %Game{board | selected_field: nil, balls: new_balls, path: solution, to: to}
    end
  end

  def calculate_scores(board) do
    board
    |> get_score_horizontal()
    |> get_score_vertical()
  end

  defp get_score_horizontal(board) do
    Enum.reduce(1..10, board, fn row, acc ->
      get_score_horizontal(acc, row, "red")
      |> get_score_horizontal(row, "green")
      |> get_score_horizontal(row, "blue")
    end)
  end

  defp get_score_vertical(board) do
    Enum.reduce(1..10, board, fn col, acc ->
      get_score_vertical(acc, col, "red")
      |> get_score_vertical(col, "green")
      |> get_score_vertical(col, "blue")
    end)
  end

  defp get_score_vertical(%Game{balls: balls} = board, col, color) do
    color_balls = Ball.group_by_color_vertical(balls, col)[color]

    color_balls
    |> Ball.vertical_ids(col)
    |> sequence()
    |> Enum.filter(fn n -> length(n) >= @destroy_balls end)
    |> List.first()
    |> update_score_x(board, col)
  end

  defp get_score_horizontal(%Game{balls: balls} = board, row, color) do
    color_balls = Ball.group_by_color_horizontal(balls, row)[color]

    color_balls
    |> Ball.horizontal_ids(row)
    |> sequence()
    |> Enum.filter(fn n -> length(n) >= @destroy_balls end)
    |> List.first()
    |> update_score_y(board, row)
  end

  defp sequence(ids) do
    ids
    |> Enum.reverse()
    |> Enum.reduce([], fn
      id, [head = [h | _] | tail] when id == h - 1 -> [[id | head] | tail]
      id, acc -> [[id] | acc]
    end)
    |> IO.inspect(charlists: :as_integers, label: "sequence")
  end

  defp update_score_x(nil, board, _line), do: board
  defp update_score_x(ids, %Game{balls: balls, score: score} = board, line) do
    balls =
      Enum.reduce(ids, balls, fn id, acc ->
        Map.delete(acc, {line, id})
      end)

    %Game{board | balls: balls, score: length(ids) * 2 + score, score_updated: true}
  end

  defp update_score_y(nil, board, _line), do: board
  defp update_score_y(ids, %Game{balls: balls, score: score} = board, line) do
    balls =
      Enum.reduce(ids, balls, fn id, acc ->
        Map.delete(acc, {id, line})
      end)

    %Game{board | balls: balls, score: length(ids) * 2 + score, score_updated: true}
  end
end
