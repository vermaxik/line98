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
    new_state = grow_ball(state, position)
    {:reply, new_state, new_state}
  end

  defp generate_board() do
    # Enum.to_list(1..100)
    # |> Enum.reduce([], fn value, acc ->
    #  List.insert_at(acc, -1, %{cell: value, color: "empty", type: "ball"})
    # end)

    # for n <- 1..100, do: %{cell: n, color: "empty", type: "ball"}

    1..100
    |> Enum.reduce([], fn value, acc ->
      [%{cell: value, color: "empty", type: "ball"} | acc]
    end)
    |> Enum.reverse()
  end

  defp random_color() do
    @ballColors |> Enum.shuffle() |> List.first()
  end

  defp random_cell() do
    Enum.random(1..100)
  end

  defp p_init_game() do
    generate_board()
    |> update_board("ball", 5)
    |> update_board("dot", 3)
  end

  def update_board(board, type, times) do
    random_cells = 1..100 |> Enum.shuffle() |> Enum.take(times)

    board
    |> Enum.map(fn %{cell: cell} = item ->
      cond do # case https://elixir-lang.org/getting-started/case-cond-and-if.html
        Enum.member?(random_cells, cell) ->
          %{item | color: random_color(), type: type}

        true ->
          item
      end
    end)

    #
    # List.update_at(board, cell, fn _ -> %{cell: cell, color: random_color(), type: type} end)
  end

  defp grow_ball(board, position) do
    board
    |> Enum.reduce([], fn item, acc ->
      updated_item =
        if item.type == "dot", do: Map.update!(item, :type, fn _ -> "ball" end), else: item

      List.insert_at(acc, -1, updated_item)
    end)
    |> update_board("dot", 3)
  end
end
