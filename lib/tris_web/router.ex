defmodule TrisWeb.Router do
  use TrisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TrisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_auth do
    plug TrisWeb.Plugs.AdminAuth, username: "admin"
  end

  scope "/admin", TrisWeb do
    pipe_through [:browser, :admin_auth]

    live "/", AdminLive, :index
  end

  scope "/", TrisWeb do
    pipe_through :browser

    live "/", LobbyLive, :index
    live "/credits", CreditLive, :index
    live "/game/:id", GameLive, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrisWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:tris, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TrisWeb.Telemetry
    end
  end
end
