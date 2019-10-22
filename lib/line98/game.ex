defmodule Line98.Game do
  alias __MODULE__

  defstruct balls: %{}, selected_field: nil, score: 0

  @ballColors ["red", "green", "blue"]

  def new do
    %__MODULE__{}
    |> init_fill()
  end

  defp init_fill(board) do
    %Game{board | balls: build_balls("ball", 3) |> build_balls("dot", 3)}
  end

  defp build_balls(balls \\ %{}, type, times) do
    random_cells =
      1..100
      |> Enum.reject(fn n -> avoid_cells(balls, n) end)
      |> Enum.shuffle()
      |> Enum.take(times)

    new_balls = for n <- random_cells, into: %{}, do: {n, {random_color(), type}}
    new_balls |> Map.merge(balls)

    # balls = random_cells |> Enum.reduce(%{}, fn n, acc ->
    #   Map.put(acc, n, {random_color(), type})
    # end) |> Map.merge(board)
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
    walls =
      for n <- Map.keys(balls) |> Enum.filter(&(&1 != selected_field)),
          into: MapSet.new(),
          do: to_coodinates(n)

    solution =
      %Maze{
        width: 10,
        height: 10,
        start_point: to_coodinates(selected_field),
        exit_point: to_coodinates(to),
        walls: walls
      }
      |> Maze.Solver.shortest_route()

    # IO.inspect to_coodinates(selected_field)
    # IO.inspect to_coodinates(selected_field) |> to_field_index()
    # IO.inspect(solution |> Enum.map(&to_field_index(&1)))

    cond do
      avoid_cells(balls, to) ->
        board

      is_atom(solution) && solution == :none ->
        %Game{board | selected_field: nil }

      true ->
        selected_ball = balls[selected_field]

        new_balls =
          Map.delete(balls, selected_field)
          |> Map.put(to, selected_ball)
          |> grow_balls()
          |> build_balls("dot", 3)




        %Game{board | selected_field: nil, balls: new_balls}
        |> IO.inspect(label: "Game#board")
        |> get_score(to)

    end
  end

  def get_score(%Game{balls: balls, selected_field: selected_field, score: score} = board, to) do
    {_, detect_line} = to_coodinates(to)

    str_balls = balls |> get_balls(detect_line) |> IO.inspect(label: "get_balls")

    str_regex =  String.duplicate("blue", 5) <> "|" <> String.duplicate("red", 5) <> "|" <> String.duplicate("green", 5)
    regex = ~r/#{str_regex}/
    case Regex.match?(regex, str_balls) do
      true -> %Game{board | score: score + 10}
      false -> board
    end

     #balls |>  # |> Map.keys |> Enum.map(&to_coodinates/1)
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
      _ -> number + 1
    end
  end

  def grow_balls(balls) do
    balls
    |> Map.keys()
    |> Enum.reduce(%{}, fn id, acc ->
      {color, type} = balls[id]

      cond do
        type == "dot" ->
          Map.put(acc, id, {color, "ball"})

        true ->
          Map.put(acc, id, {color, type})
      end
    end)
  end

  def get_balls(balls, line) do
    balls |> Map.to_list #|> Enum.filter(fn {index, {color, type}} -> type =="ball" end)
    |> Enum.flat_map(fn {index, {color, type}} ->
        case type =="ball" do
          # transform to integer
          true -> [{to_coodinates(index), color}]
          # skip the value
          false -> []
        end
      end)
    |> Enum.filter(fn {{_,x}, _} -> x == line end)
    |> Enum.map(fn {{_,_}, color} -> color end) |> Enum.join("")
  end

  defp random_color() do
    @ballColors |> Enum.shuffle() |> List.first()
  end

  defp avoid_cells(balls, field_index) do
    balls |> Map.keys() |> Enum.member?(field_index)
  end
end
