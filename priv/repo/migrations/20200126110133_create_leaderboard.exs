defmodule Line98.Repo.Migrations.CreateLeaderboard do
  use Ecto.Migration

  def change do
  	create table(:game_results) do
      add :nickname, :string
      add :score, :integer
      add :date, :utc_datetime
    end
  end
end
