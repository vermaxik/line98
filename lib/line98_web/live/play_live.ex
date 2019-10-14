defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    IO.inspect(Line98.Game.board())
    {:ok, assign(socket, board: Line98.Game.board(), selected_cell: nil)}
  end

  def handle_event("range", %{"select" => select_value}, socket) do
    select_value = select_value |> String.to_integer()
    board = Line98.Game.board()

    cond do
      able_to_next_step?(board, select_value) ->
        if false do
          {:noreply, assign(socket, board: board, selected_cell: select_value)}
        else
          {:noreply,
           assign(socket, board: Line98.Game.move_ball(select_value), selected_cell: select_value)}
        end

      true ->
        {:noreply, assign(socket, board: board, selected_cell: nil)}
    end
  end

  defp able_to_next_step?(board, cell) do
    board
    |> Enum.reject(&(&1.type == "dot"))
    |> Enum.map(& &1.cell)
    |> Enum.member?(cell)
  end
end
