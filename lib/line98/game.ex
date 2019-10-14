defmodule Line98.Game do
  use GenServer

  @ballColors ["red", "green", "blue"]

  def init(_) do
    {:ok, init_game()}
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def board() do
    GenServer.call(__MODULE__, :board)
  end

  def move_ball(position) do
    GenServer.call(__MODULE__, {:move_ball, position})
  end

  def handle_call(:board, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:move_ball, position}, _from, state) do
    new_state = grow_ball(state, position)
    {:reply, new_state, new_state}
  end

  defp init_game() do
    build_cells("ball", 5)
    |> build_cells("dot", 3)
  end

  defp build_cells(board \\ [], type, times) do
    avoid_cells = board |> Enum.map(& &1.cell)

    random_cells =
      1..100
      |> Enum.reject(fn n -> Enum.member?(avoid_cells, n) end)
      |> Enum.shuffle()
      |> Enum.take(times)

    for n <- random_cells do
      %{cell: n, color: random_color(), type: type}
    end
    |> Enum.concat(board)
  end

  defp random_color() do
    @ballColors |> Enum.shuffle() |> List.first()
  end

  defp grow_ball(board, position) do
    board
    |> Enum.map(fn %{type: type} = item ->
      cond do
        type == "dot" ->
          %{item | type: "ball"}

        true ->
          item
      end
    end)
    |> build_cells("dot", 3)
  end
end
