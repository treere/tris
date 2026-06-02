defmodule Tris.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TrisWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tris, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tris.PubSub},
      {Registry, keys: :unique, name: Tris.GameRegistry},
      Tris.Matchmaker,
      Tris.GameSupervisor,
      TrisWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tris.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TrisWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
