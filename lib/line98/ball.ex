defmodule Line98.Ball do
  @colors ["red", "green", "blue"]

  def colors, do: @colors

  def build(balls \\ %{}, type, times) do
    new_balls =
      for n <- random_coordinates([], times, balls),
          into: %{},
          do: {n, {random_color(balls), type}}

    new_balls |> Map.merge(balls)
  end

  def random_coordinates(coordinates \\ [], times, balls) do
    cond do
      length(coordinates) == times ->
        coordinates

      true ->
        coordinate = {:rand.uniform(10), :rand.uniform(10)}

        case Enum.member?(Map.keys(balls), coordinate) do
          true ->
            random_coordinates(coordinates, times, balls)

          _ ->
            List.insert_at(coordinates, 0, coordinate)
            |> random_coordinates(times, balls)
        end
    end
  end

  def grow(balls) do
    dot_balls = for {coordinate, {_, "dot"}} <- balls, do: coordinate

    dot_balls
    |> Enum.reduce(balls, fn coordinate, acc ->
      {color, _} = acc[coordinate]
      Map.put(acc, coordinate, {color, "ball"})
    end)
  end

  def get_by_horizontal(balls, line) do
    for {{_, ^line}, {_, "ball"}} = ball <- balls, do: ball
  end

  def get_by_vertical(balls, line) do
    for {{^line, _}, {_, "ball"}} = ball <- balls, do: ball
  end

  def group_by_color_vertical(balls, line) do
    balls
    |> get_by_vertical(line)
    |> group_by_color()
    |> IO.inspect(label: "group_by_color_vertical")
  end

  def group_by_color_horizontal(balls, line) do
    balls
    |> get_by_horizontal(line)
    |> group_by_color()
    |> IO.inspect(label: "group_by_color_horizontal")
  end

  def vertical_ids(nil, _line), do: []

  def vertical_ids(balls, line) do
    ids = for {{^line, y}, {_, "ball"}} <- balls, do: y
    Enum.sort(ids)
  end

  def horizontal_ids_new(balls) do
    for line <- 1..10, into: %{} do
      {line, for({{x, ^line}, {_, "ball"}} <- balls, do: x)}
    end
  end

  def horizontal_ids(nil, _line), do: []

  def horizontal_ids(balls, line) do
    ids = for {{x, ^line}, {_, "ball"}} <- balls, do: x
    Enum.sort(ids)
  end

  def group_by_color(balls) do
    balls
    |> Enum.group_by(fn {{x, y}, {color, type}} -> color end)
  end

  def walls(balls, selected_field) do
    coordinates =
      Map.keys(balls)
      |> Enum.filter(&(&1 != selected_field))

    for n <- coordinates, into: MapSet.new(), do: n
  end

  def avoid_cells(balls, coordinate) do
    balls
    |> Map.keys()
    |> Enum.member?(coordinate)
  end

  defp random_color(balls \\ %{}) do
    cond do
      map_size(balls) > 9 ->
        colors()
        |> Enum.reject(&(&1 == detect_popular_color(balls)))

      true ->
        colors()
    end
    |> Enum.shuffle()
    |> List.first()
  end

  defp detect_popular_color(balls) do
    popular_color =
      balls
      |> group_by_color()
      |> Enum.to_list()
      |> Enum.sort(fn {_, v1}, {_, v2} -> length(v1) > length(v2) end)
      |> List.first()

    {color, _} = popular_color
    color
  end
end
