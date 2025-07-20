defmodule Skill.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SkillWeb.Telemetry,
      Skill.Repo,
      {Registry, keys: :unique, name: Skill.Registry},
      {DynamicSupervisor, name: Skill.MatchSupervisor, strategy: :one_for_one},
      {Ecto.Migrator,
       repos: Application.fetch_env!(:skill, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:skill, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Skill.PubSub},
      # Start a worker by calling: Skill.Worker.start_link(arg)
      # {Skill.Worker, arg},
      # Start to serve requests, typically the last entry
      SkillWeb.Endpoint,
      SkillWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Skill.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SkillWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") == nil
  end
end
