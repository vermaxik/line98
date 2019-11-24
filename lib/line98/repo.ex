defmodule Line98.Repo do
  use Ecto.Repo,
    otp_app: :line98,
    adapter: Ecto.Adapters.Postgres
end
