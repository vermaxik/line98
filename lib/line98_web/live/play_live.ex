defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    balls = Line98.Game.new()
    IO.inspect(balls)
    {:ok, assign(socket, board: balls, selected_cell: nil)}
  end

  def handle_event("range", %{"select" => select_value}, %{assigns: assigns} = socket) do
    select_value = select_value |> String.to_integer()
    selected_field = assigns.board.selected_field
    IO.inspect(assigns.board)

    balls =
      cond do
        selected_field == nil ->
          assigns.board |> Line98.Game.select_field(select_value)

        true ->
          assigns.board |> Line98.Game.move(select_value)
      end

    {:noreply, assign(socket, board: balls, selected_cell: select_value)}
  end
end
