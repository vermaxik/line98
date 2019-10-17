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
    cond do
      avoid_cells(balls, to) ->
        board

      true ->
        selected_ball = balls[selected_field]

        new_balls =
          Map.delete(balls, selected_field)
          |> Map.put(to, selected_ball)
          |> grow_balls()
          |> build_balls("dot", 3)

        %Game{board | selected_field: nil, balls: new_balls}
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

  defp random_color() do
    @ballColors |> Enum.shuffle() |> List.first()
  end

  defp avoid_cells(balls, field_index) do
    balls |> Map.keys() |> Enum.member?(field_index)
  end
end
