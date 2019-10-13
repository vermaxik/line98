defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, assign(socket, board: Line98.Game.board(), selected_item: nil) }
  end

  def handle_event("range", %{"select" => select_value}, socket) do
    IO.inspect select_value
    {:noreply, assign(socket, board: Line98.Game.move_ball(select_value |> String.to_integer), selected_item: select_value )}
  end

end
