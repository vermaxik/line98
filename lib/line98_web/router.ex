defmodule Line98Web.Router do
  use Line98Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Line98Web do
    pipe_through :browser

    live "/", PlayLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", Line98Web do
  #   pipe_through :api
  # end
end
