defmodule Line98Web.PlayView do
  use Line98Web, :view

  def cell_class(board, index) do
    ball_class(board, index) <> selected_class(board, index)
  end

  def ball_class(board, index) do
    %{balls: balls} = board

    if Map.has_key?(balls, index),
      do: balls[index] |> Tuple.to_list() |> Enum.reverse() |> Enum.join("-"),
      else: ""
  end

  def selected_class(board, index) do
    %{selected_field: selected, balls: balls} = board
    if Map.has_key?(balls, index) && selected == index, do: " selected", else: ""
  end
end
