defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView
  alias Line98.Game

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    board = Game.new()
    {:ok, assign(socket, board: board, selected_cell: nil)}
  end

  def handle_event("cell", %{"select-x" => x, "select-y" => y}, %{assigns: assigns} = socket) do
    coordinates = {String.to_integer(x), String.to_integer(y)}

    board =
      case assigns.board.selected_field do
        nil -> assigns.board |> Game.select(coordinates)
        _ -> assigns.board |> Game.move(coordinates)
      end

    IO.inspect(board, label: "handle_event#board")
    {:noreply, assign(socket, board: board, selected_cell: coordinates)}
  end
end
