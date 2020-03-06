defmodule Line98.Leaderboard.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_results" do
    field :nickname, :string
    field :score, :integer
    field :date, :utc_datetime
  end

  def changeset(result, params \\ %{}) do
    result
    |> cast(params, [:nickname, :score, :date])
    |> validate_required([:nickname, :score])
  end
end
