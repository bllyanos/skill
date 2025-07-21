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

    IO.puts("player #{match_host} created match #{match_id}")

    initial_state = %{
      # waiting, playing, finishing
      state: :waiting,
      match_id: match_id,
      match_host: match_host,
      # hold all player refs
      players: [],

      # a map of player_id to the num of completed challenges
      scoreboard: %{},

      # a map of player_id to a list of invoked skills with duration in ms
      player_records: %{}
    }

    IO.puts("match #{match_id} created!")

    {:ok, initial_state, @initial_timeout}
  end

  def via_registry(match_id) do
    {:via, Registry, {Skill.Registry, match_id}}
  end

  def start_match(match_id) do
    GenServer.cast(via_registry(match_id), :start_match)
  end

  def join(match_id, player_id) do
    IO.inspect("join called")
    GenServer.cast(via_registry(match_id), {:add_player, player_id})
  end

  @doc "will be executed if the player disconnected"
  def quit(match_id, player_id) do
    IO.inspect("quit called")
    GenServer.cast(via_registry(match_id), {:remove_player, player_id})
  end

  def get_player_count(match_id) do
    IO.inspect("get players called")

    GenServer.call(via_registry(match_id), :get_player_count)
  end

  def handle_cast({:add_player, player_id}, state) do
    # initiate player's state
    state =
      state
      |> Map.update!(:players, fn players -> [player_id | players] end)
      |> Map.update(:scoreboard, %{player_id => 0}, fn scoreboard ->
        Map.put(scoreboard, player_id, 0)
      end)
      |> Map.update(:player_records, %{player_id => []}, fn player_records ->
        Map.put(player_records, player_id, [])
      end)

    match_id(state)
    |> notify!({:player_added, player_id})
    |> notify!(
      {:match_state,
       %{
         scoreboard: state.scoreboard,
         player_records: state.player_records
       }}
    )

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

  def handle_cast(_, state) do
    IO.inspect("some")
    {:noreply, state, @interval_timeout}
  end

  def handle_call(:get_player_count, _from, state) do
    {:reply, length(state.players), state, @interval_timeout}
  end

  def handle_call(_, _from, state) do
    IO.inspect("some call")
    {:reply, :ok, state, @interval_timeout}
  end

  def handle_info(:timeout, state) do
    IO.puts("match #{match_id(state)} timeout! shutting down.")
    {:stop, :normal, state}
  end

  def handle_info(_, state) do
    IO.inspect("some info")
    {:noreply, state, @interval_timeout}
  end

  defp match_id(%{match_id: match_id} = _state), do: match_id
end
