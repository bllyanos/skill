defmodule SkillWeb.Hooks.SessionCodeGenerator do
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    session_code = create_session_code()
    player_name = session["name"]
    player_id = Enum.join([player_name, session_code], ":")

    socket =
      socket
      |> assign(:player_id, player_id)
      |> assign(:player_name, player_name)
      |> assign(:session_code, session_code)

    {:cont, socket}
  end

  defp create_session_code() do
    alias Ecto.UUID

    UUID.bingenerate()
    |> UUID.load!()
    |> ShortUUID.encode!()
  end
end
