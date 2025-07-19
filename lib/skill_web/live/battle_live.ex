defmodule SkillWeb.BattleLive do
  use SkillWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:name, "Battle")
     |> assign(:challenge, "Tornado")
     |> assign(:stash, [])
     |> assign(:remaining_time, 15)}
  end

  def handle_event("on-skill-box", %{"key" => key}, socket) do
    {:noreply, socket |> update(:stash, &put_key_to_stash(&1, check_key(key)))}
  end

  defp check_key(key) do
    result =
      case key do
        "q" -> :stash
        "w" -> :stash
        "e" -> :stash
        "r" -> :invoke
        _ -> :error
      end

    {result, key}
  end

  defp put_key_to_stash(stash, {:stash, key}) do
    case stash do
      [] -> [key]
      [first] -> [first, key]
      [first, second] -> [first, second, key]
      [_, second, third] -> [second, third, key]
    end
  end

  defp put_key_to_stash(stash, _), do: stash

  defp render_skill_box(assigns) do
    ~H"""
    <div
      phx-click="on-skill-box"
      phx-value-key={@key |> String.downcase()}
      class={"px-6 aspect-square #{@color} text-white font-bold flex items-center"}
    >
      {@key}
    </div>
    """
  end
end
