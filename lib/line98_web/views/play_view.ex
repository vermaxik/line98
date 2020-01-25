defmodule Line98Web.PlayView do
  use Line98Web, :view

  def cell_class(board, coordinate) do
    ball_class(board, coordinate) <> selected_class(board, coordinate)
  end

  def ball_class(board, coordinate) do
    %{balls: balls} = board

    if Map.has_key?(balls, coordinate),
      do: balls[coordinate] |> Tuple.to_list() |> Enum.reverse() |> Enum.join("-"),
      else: ""
  end

  def selected_class(board, coordinate) do
    %{selected_field: selected, balls: balls} = board
    if Map.has_key?(balls, coordinate) && selected == coordinate, do: " selected ", else: ""
  end

  def move_class(board, coordinate) do
    head = List.first(board.path)

    case board.path do
      [^coordinate | _] -> " move"
      nil -> ""
      _ -> ""
    end
  end
end
