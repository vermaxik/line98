defmodule Line98.Game do
  use GenServer

  @ballColors ["red", "green", "blue"]

  def init(_) do
    {:ok, p_init_game()}
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
    {:reply, grow_ball(state, position), state}
  end

  defp generate_board() do
    Enum.to_list(1..100)
      |>  Enum.reduce([], fn(value, acc) -> List.insert_at(acc, -1, %{cell: value, color: "empty", type: "ball"}) end)
  end

  defp random_color() do
    @ballColors |> Enum.shuffle |> List.first
  end

  defp random_cell() do
    Enum.to_list(1..100) |> Enum.shuffle |> List.first
  end

  defp p_init_game() do
    board = generate_board()

    update_board(board, "ball")
      |> update_board("ball")
      |> update_board("ball")
      |> update_board("ball")
      |> update_board("ball")
      |> update_board("dot")
      |> update_board("dot")
      |> update_board("dot")
  end

  defp update_board(board, type) do
    cell = random_cell()
    List.update_at(board, cell, fn _ -> %{cell: cell, color: random_color(), type: type} end)
  end

  defp grow_ball(board, position) do
    board |> Enum.reduce([], fn(item, acc) ->
      updated_item = if item.type == "dot", do: Map.update!(item, :type, fn _ -> "ball" end), else: item
      List.insert_at(acc, -1, updated_item)
    end)
  end
end
