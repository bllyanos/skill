defmodule Skill.Game.MatchServer do
  import Skill.Notify
  use GenServer

  @initial_timeout :timer.seconds(5)
  @interval_timeout :timer.minutes(10)

  def start_link(arg) do
    match_id = Map.fetch!(arg, :match_id)
    GenServer.start_link(__MODULE__, arg, name: via_registry(match_id))
  end

  def init(%{} = arg) do
    match_id = Map.fetch!(arg, :match_id)
    match_host = Map.fetch!(arg, :match_host)

    initial_state = %{
      match_id: match_id,
      match_host: match_host,
      # hold all player refs
      players: []
    }

    IO.puts("match #{match_id} created!")

    {:ok, initial_state, @initial_timeout}
  end

  def via_registry(match_id) do
    {:via, Registry, {Skill.Registry, match_id}}
  end

  def join(match_id, player_id) do
    GenServer.cast(via_registry(match_id), {:add_player, player_id})
  end

  def quit(match_id, player_id) do
    GenServer.cast(via_registry(match_id), {:remove_player, player_id})
  end

  def get_player_count(match_id) do
    GenServer.call(via_registry(match_id), :get_player_count)
  end

  def handle_cast({:add_player, player_id}, state) do
    state = Map.update!(state, :players, fn players -> [player_id | players] end)

    match_id(state)
    |> notify({:player_added, player_id})

    {:noreply, state, @interval_timeout}
  end

  def handle_cast({:remove_player, player_id}, state) do
    state =
      Map.update!(state, :players, fn players ->
        Enum.filter(players, fn player ->
          player != player_id
        end)
      end)

    match_id(state)
    |> notify({:player_removed, player_id})

    {:noreply, state, @interval_timeout}
  end

  def handle_call(:get_player_count, _from, state) do
    {:reply, length(state.players), state, @interval_timeout}
  end

  defp match_id(%{match_id: match_id} = _state), do: match_id
end
