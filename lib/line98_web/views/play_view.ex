defmodule Line98Web.PlayView do
  use Line98Web, :view

  def ball_class(board, index) do
    board
    |> Enum.map(fn %{cell: cell} = item ->
      cond do
        cell == index ->
          "#{item.type}-#{item.color}"

        true ->
          ""
      end
    end)
  end

  def selected_class(board, cell \\ 0, index) do
    cells = board |> Enum.reject(&(&1.type == "dot")) |> Enum.map(& &1.cell)
    if Enum.member?(cells, index) && cell == index, do: "selected"
  end
end
