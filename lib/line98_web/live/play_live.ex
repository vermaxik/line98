defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView
  alias Line98.Game

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :update)

    board = Game.new()
    {:ok, assign(socket, board: board, selected_cell: nil)}
  end

  def handle_event("again", _, socket) do
    board = Game.new()
    {:noreply, assign(socket, board: board, selected_cell: nil)}
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

  def handle_info(:update, socket) do
    #IO.inspect(socket.assigns.board, label: "board#update")
    case socket.assigns.board.path do
      [] -> {:noreply, assign(socket, board: socket.assigns.board)}

      _ ->
        socket.assigns.board.path |> IO.inspect(label: "path ololo")
        [head | tail] = socket.assigns.board.path
        {:noreply, assign(socket, board: %Game{socket.assigns.board | path: tail})}
    end
  end
end
