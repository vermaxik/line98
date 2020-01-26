defmodule Line98Web.PlayLive do
  use Phoenix.LiveView
  alias Line98Web.PlayView
  alias Line98.Game
  alias Line98.Ball
  alias Line98.Leaderboard.Result

  def render(assigns) do
    PlayView.render("index.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(100, self(), :path_update)
    if connected?(socket), do: :timer.send_interval(3000, self(), :score_update)

    board = Game.new()
    results = Line98.Leaderboard.Results.leaderboard()
    {:ok, assign(socket, board: board, selected_cell: nil, results: results, hide_form_result: false)}
  end

  def handle_event("again", _, socket) do
    board = Game.new()
    {:noreply, assign(socket, board: board, selected_cell: nil, hide_form_result: false)}
  end

  def handle_event("add_result", %{"nickname" => nickname}, socket) do
    params = %{nickname: nickname,
              score: socket.assigns.board.score,
              date:  DateTime.utc_now}

    changeset = Result.changeset(%Result{}, params)

    case changeset.valid? do
      true ->
        Line98.Repo.insert(changeset)
        {:noreply,
          assign(socket,
                 results: Line98.Leaderboard.Results.leaderboard(),
                 hide_form_result: true)}
      false ->
        handle_event("again", "", socket)
    end
  end

  def handle_event("cell", %{"select-x" => x, "select-y" => y}, socket) do
    coordinates = {String.to_integer(x), String.to_integer(y)}
    board = socket.assigns.board

    new_board =
      case board.selected_field do
        nil -> Game.select(board, coordinates)
        _ -> Game.move(board, coordinates)
      end

    {:noreply, assign(socket, board: new_board, selected_cell: coordinates)}
  end

  def handle_info(:path_update, socket) do
    board = socket.assigns.board

    cond do
      length(board.path) > 1 ->
        [current_coordinate, to_coodinate | _] = board.path
        new_balls = Ball.move_ball_to_cell(board.balls, current_coordinate, to_coodinate)
        [_ | tail] = board.path

        {:noreply, assign(socket, board: %Game{board | balls: new_balls, path: tail})}

      length(board.path) == 1 ->
        new_balls = Ball.grow_and_generate_balls(board.balls)
        new_board =
          %Game{board | balls: new_balls, path: [], to: nil}
          |> Game.calculate_scores()

        {:noreply, assign(socket, board: new_board)}

      true ->
        {:noreply, assign(socket, board: board)}
    end
  end

  def handle_info(:score_update, socket) do
    board = socket.assigns.board
    {:noreply, assign(socket, board: %Game{board | score_updated: false})}
  end
end
