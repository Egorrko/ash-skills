defmodule AppTemplate.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, top_level?: true, deps: [AppTemplate, AppTemplateWeb]

  @impl true
  def start(_type, _args) do
    children = [
      AppTemplateWeb.Telemetry,
      AppTemplate.Repo,
      {Oban,
       AshOban.config(
         Application.fetch_env!(:app_template, :ash_domains),
         Application.fetch_env!(:app_template, Oban)
       )},
      # Start a worker by calling: AppTemplate.Worker.start_link(arg)
      # {AppTemplate.Worker, arg},
      # Start to serve requests, typically the last entry
      {DNSCluster, query: Application.get_env(:app_template, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AppTemplate.PubSub},
      AppTemplateWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AppTemplate.Supervisor]

    children =
      children ++
        if(Application.get_env(:live_vue, :ssr_module) == LiveVue.SSR.QuickBEAM,
          do: [LiveVue.SSR.QuickBEAM],
          else: []
        )

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AppTemplateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
