defmodule Line98.Leaderboard.Results do
  import Ecto.Query#, only: [from: 2]
  alias Line98.Repo
  alias Line98.Leaderboard.Result

  def get_result!(id), do: Repo.get!(Result, id)

  def all(), do: Repo.all(Result)

  def leaderboard(limit \\ 15) do
  	Result
  	|> where([r], r.score > 0)
  	|> order_by([r], desc: r.score)
  	|> order_by([r], desc: r.date)
  	|> limit(^limit)
  	|> Repo.all
  end

end
