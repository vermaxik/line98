defmodule Line98Web.PlayController do
  use Line98Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
