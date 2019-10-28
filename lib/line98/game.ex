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
    %Game{board | balls: balls }
  end


  def select_field(board, field_index) do
    case board.balls[field_index] do
      {_, "ball"} ->
        %Game{board | selected_field: field_index}

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
        width: 10,
        height: 10,
        start_point: to_coodinates(selected_field),
        exit_point: to_coodinates(to),
        walls: Ball.walls(balls, selected_field)
      }
      |> Solver.shortest_route()

    cond do
      Ball.avoid_cells(balls, to) ->
        board

      is_atom(solution) && solution == :none ->
        %Game{board | selected_field: nil }

      true ->
        selected_ball = balls[selected_field]

        new_balls =
          Map.delete(balls, selected_field)
          |> Map.put(to, selected_ball)
          |> Ball.grow()
          |> Ball.build("dot", 3)

        %Game{board | selected_field: nil, balls: new_balls}
        |> IO.inspect(label: "Game#board")
        |> get_score(to)

    end
  end

  def get_score(%Game{balls: balls, selected_field: selected_field, score: score} = board, to) do
    {_, detect_line} = to_coodinates(to)

    str_balls = balls |> Ball.get(detect_line) |> IO.inspect(label: "get_balls")

    str_regex =  String.duplicate("blue", 5) <> "|" <> String.duplicate("red", 5) <> "|" <> String.duplicate("green", 5)
    regex = ~r/#{str_regex}/
    case Regex.match?(regex, str_balls) do
      true -> %Game{board | score: score + 10}
      false -> board
    end
  end

  def to_coodinates(field_index) do
    field_index =
      field_index |> to_string |> String.graphemes() |> Enum.map(&String.to_integer(&1))

    new_list =
      if length(field_index) == 1, do: List.insert_at(field_index, 0, 0), else: field_index

    [x, y] = new_list
    y = if y == 0 && length(field_index) == 2, do: 10, else: y

    {y - 1, x}
  end

  def to_field_index(tuple) do
    number = tuple |> Tuple.to_list() |> Enum.reverse() |> Enum.join("") |> String.to_integer()
    # bug with numbers
    case rem(number + 1, 10) == 0 do
      true -> number - 9
      _    -> number + 1
    end
  end
end
