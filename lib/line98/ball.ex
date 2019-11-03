defmodule Line98.Ball do
  @ballColors ["red", "green", "blue"]

  def build(balls \\ %{}, type, times) do
    new_balls = for n <- random_cells(balls, times), into: %{}, do: {n, {random_color(), type}}
    new_balls |> Map.merge(balls)
  end

  defp random_cells(balls, times) do
    1..times
    |> Enum.reduce([], fn _, acc ->
        List.insert_at(acc, 0, {:rand.uniform(10), :rand.uniform(10)})
      end)
  end

  def grow(balls) do
    balls
    |> Map.keys()
    |> Enum.reduce(%{}, fn id, acc ->
      {color, type} = balls[id]

      case type == "dot" do
        true -> Map.put(acc, id, {color, "ball"})
        _ -> Map.put(acc, id, {color, type})
      end
    end)
  end

  def get_by_line(balls, line) do
    balls
    |> Map.to_list
    |> Enum.filter(fn {_, {_, type}} -> type == "ball" end)
    |> Enum.filter(fn {{_, y}, _} -> y == line end)


    # |> Map.to_list()
    # |> Enum.flat_map(fn {index, {color, type}} ->
    #     case type == "ball" do
    #       true -> [{index, color}]
    #       false -> []
    #     end
    #   end)
    # |> Enum.filter(fn {{_, x}, _} -> x == line end)
    # |> Enum.map(fn {{_, _}, color} -> color end)
    # |> Enum.join("")
  end

  def walls(balls, selected_field) do
    for n <- Map.keys(balls) |> Enum.filter(&(&1 != selected_field)),
        into: MapSet.new(),
        do: n
  end

  def avoid_cells(balls, coordinate) do
    balls
    |> Map.keys()
    |> Enum.member?(coordinate)
  end

  defp random_color() do
    @ballColors
    |> Enum.shuffle()
    |> List.first()
  end
end
