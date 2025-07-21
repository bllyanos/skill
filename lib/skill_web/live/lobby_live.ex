defmodule SkillWeb.LobbyLive do
  alias Skill.Game.MatchServer
  use SkillWeb, :live_view

  def mount(_params, session, socket) do
    name = session["name"]

    socket =
      socket
      |> assign(:join_room_form, to_form(%{"room_id" => ""}))
      |> assign(:set_name_form, to_form(%{"name" => name}))

    {:ok, socket}
  end

  def handle_event("join_room", %{"room_id" => _room_id}, socket) do
    # start the match server
    # navigate to the match page

    {:noreply, socket}
  end

  def handle_event("set_name", %{"name" => name}, socket) do
    {:noreply, socket |> push_event("set_name", %{"name" => name})}
  end

  def handle_event("validate_join_room", %{"room_id" => room_id}, socket) do
    {:noreply, socket |> assign(:join_room_form, to_form(%{"room_id" => room_id}))}
  end

  def handle_event("create_room", _params, socket) do
    code = "100"

    {:ok, pid} =
      MatchServer.start_link(%{
        match_id: code,
        match_host: socket.assigns.player_id
      })

    IO.inspect(pid, label: "pid")

    # {:noreply, socket}
    {:noreply,
     socket |> push_navigate(to: "/match/#{code}?player_name=#{socket.assigns.player_name}")}
  end
end
