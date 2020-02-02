defmodule Line98.Leaderboard.Results do
  import Ecto.Query
  alias Line98.Repo
  alias Line98.Leaderboard.Result

  def get_result!(id), do: Repo.get!(Result, id)

  def all(), do: Repo.all(Result)

  def today(limit \\ 3, date \\ Date.utc_today) do
    Result
    |> where([r], fragment("?::date", r.date) == ^date)
    |> where([r], r.score > 0)
    |> order_by([r], desc: r.score)
    |> order_by([r], desc: r.date)
    |> limit(^limit)
    |> Repo.all
  end

  def general(limit \\ 10) do
  	Result
  	|> where([r], r.score > 0)
  	|> order_by([r], desc: r.score)
  	|> order_by([r], desc: r.date)
  	|> limit(^limit)
  	|> Repo.all
  end

end
