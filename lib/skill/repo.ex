defmodule Skill.Repo do
  use Ecto.Repo,
    otp_app: :skill,
    adapter: Ecto.Adapters.SQLite3
end
