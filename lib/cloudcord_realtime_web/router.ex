defmodule CloudcordRealtimeWeb.Router do
  use CloudcordRealtimeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CloudcordRealtimeWeb do
    pipe_through :api
  end
end
