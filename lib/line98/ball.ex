defmodule Line98.Ball do
  @ballColors ["red", "green", "blue"]

  def build(balls \\ %{}, type, times) do
    new_balls = for n <- random_cells(balls, times), into: %{},
                    do: {n, {random_color(), type}}
    new_balls |> Map.merge(balls)
  end

  defp random_cells(balls, times) do
    1..100
    |> Enum.reject(fn n -> avoid_cells(balls, n) end)
    |> Enum.shuffle()
    |> Enum.take(times)
  end

  def grow(balls) do
    balls
    |> Map.keys()
    |> Enum.reduce(%{}, fn id, acc ->
      {color, type} = balls[id]

      case type == "dot" do
        true -> Map.put(acc, id, {color, "ball"})
         _   -> Map.put(acc, id, {color, type})
      end
    end)
  end

  def get(balls, line) do
    balls
    |> Map.to_list
    |> Enum.flat_map(fn {index, {color, type}} ->
        case type =="ball" do
          # transform to integer
          true -> [{Line98.Game.to_coodinates(index), color}]
          # skip the value
          false -> []
        end
      end)
    |> Enum.filter(fn {{_,x}, _} -> x == line end)
    |> Enum.map(fn {{_,_}, color} -> color end) |> Enum.join("")
  end

  def walls(balls, selected_field) do
    for n <- Map.keys(balls) |> Enum.filter(&(&1 != selected_field)),
          into: MapSet.new(),
          do: Line98.Game.to_coodinates(n)
  end

  def avoid_cells(balls, field_index) do
    balls
    |> Map.keys()
    |> Enum.member?(field_index)
  end

  defp random_color() do
    @ballColors
    |> Enum.shuffle()
    |> List.first()
  end

end
