defmodule SkillWeb.MatchLive do
  alias Skill.Game.Invoker
  use SkillWeb, :live_view

  def mount(%{"match_id" => match_id, "player_name" => player_name}, _session, socket) do
    session_code = create_session_code()
    player_id = Enum.join([player_name, session_code], ":")

    socket =
      if connected?(socket) do
        SkillWeb.Presence.track_user(match_id, player_id, %{id: player_id, name: player_name})
        SkillWeb.Presence.subscribe(match_id)
        players = SkillWeb.Presence.list_online_users(match_id)
        IO.inspect(players)
        stream(socket, :players, players)
      else
        stream(socket, :players, [])
      end

    {:ok,
     socket
     |> assign(:match_id, match_id)
     |> assign(:player_name, player_name)
     |> assign(:player_id, player_id)
     |> assign(:session_code, session_code)
     |> assign(:invoked_skill, :error)
     |> assign(:stage, [])}
  end

  def handle_event("on-skill-box", %{"key" => key}, socket) do
    IO.puts("skill: #{key}")

    socket =
      case check_key(key) do
        {:stage, key} ->
          socket |> update(:stage, &put_key_to_stage(&1, key))

        {:invoke, _} ->
          IO.inspect(socket.assigns.stage, label: "stage")
          skill = Invoker.invoke(socket.assigns.stage)
          IO.inspect(skill, label: "skill")
          socket |> assign(:invoked_skill, skill)

        {:error, _} ->
          socket
      end

    {:noreply, socket}
  end

  defp create_session_code() do
    alias Ecto.UUID

    UUID.bingenerate()
    |> UUID.load!()
    |> ShortUUID.encode!()
  end

  defp check_key(key) do
    result =
      case key do
        "q" -> :stage
        "w" -> :stage
        "e" -> :stage
        "r" -> :invoke
        _ -> :error
      end

    {result, key}
  end

  defp put_key_to_stage(stage, key) do
    case stage do
      [] -> [key]
      [first] -> [first, key]
      [first, second] -> [first, second, key]
      [_, second, third] -> [second, third, key]
    end
  end

  defp render_skill_box(assigns) do
    ~H"""
    <div
      phx-click="on-skill-box"
      phx-value-key={@key |> String.downcase()}
      class={"px-6 rounded aspect-square #{key_color(@key)} text-white font-bold flex items-center"}
    >
      {@key}
    </div>
    """
  end

  defp render_skill_stage(assigns) do
    ~H"""
    <div class={"px-3 rounded aspect-square #{key_color(@key)} text-white text-sm font-bold flex items-center"}>
      {@key}
    </div>
    """
  end

  defp key_color("Q"), do: "bg-blue-700"
  defp key_color("W"), do: "bg-purple-700"
  defp key_color("E"), do: "bg-red-700"
  defp key_color("R"), do: "bg-gray-700"

  def handle_info({SkillWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :players, presence)}
  end

  def handle_info({SkillWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :players, presence)}
    else
      {:noreply, stream_insert(socket, :players, presence)}
    end
  end
end
