defmodule Skill.Notify do
  alias Phoenix.PubSub

  @default_pubsub_name Skill.PubSub

  def notify(target, message) do
    PubSub.broadcast(@default_pubsub_name, target, message)
  end
end
