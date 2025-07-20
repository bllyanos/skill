defmodule SkillWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :skill,
    pubsub_server: Skill.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      {key, %{metas: [meta | metas], id: meta.id, user: %{id: meta.id, name: meta.name}}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    IO.inspect(topic, label: "TOPIC")

    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Skill.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}

      Phoenix.PubSub.local_broadcast(Skill.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_users(match_id),
    do: list("match:#{match_id}") |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(match_id, name, params), do: track(self(), "match:#{match_id}", name, params)

  def subscribe(match_id), do: Phoenix.PubSub.subscribe(Skill.PubSub, "proxy:match:#{match_id}")
end
