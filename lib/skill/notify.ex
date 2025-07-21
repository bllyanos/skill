defmodule Skill.Notify do
  alias Phoenix.PubSub

  @default_pubsub_name Skill.PubSub

  def notify(target, message) do
    PubSub.broadcast(@default_pubsub_name, target, message)
  end

  def subscribe(target) do
    PubSub.subscribe(@default_pubsub_name, target)
  end

  def notify!(target, message) do
    result = notify(target, message)

    case result do
      :ok -> result
      {:error, reason} -> IO.inspect(reason, label: "notify error")
    end

    target
  end
end
