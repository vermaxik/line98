defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    balls = Line98.Game.new()
    IO.inspect(balls, label: "mount#balls")
    {:ok, assign(socket, board: balls, selected_cell: nil)}
  end

  def handle_event("range", %{"select-x" => x, "select-y" => y}, %{assigns: assigns} = socket) do
    select_value = {x |> String.to_integer(), y |> String.to_integer()}
    selected_field = assigns.board.selected_field

    balls =
      case selected_field do
        nil -> assigns.board |> Line98.Game.select_field(select_value)
        _ -> assigns.board |> Line98.Game.move(select_value)
      end

    IO.inspect(balls, label: "handle_event#balls")
    {:noreply, assign(socket, board: balls, selected_cell: select_value)}
  end
end
