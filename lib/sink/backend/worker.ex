defmodule Sink.Backend.Worker do
  use GenServer
  import SinkWeb.Endpoint, [:broadcast/3]
  require Logger
  alias Sink.Backend.Registry, as: Reg

  @ping_interval 10 * 1000  # 10 seconds

  def init(room_id) do
    Logger.info("Starting server for room #{room_id}")
    :timer.send_interval(@ping_interval, :do_ping)
    state = %{
      room_id: room_id,
      player_state: :pause,
      clients: %{}
    }
    {:ok, state}
  end

  def receive_pong(room_id, msg) do
    room_id
    |> Reg.server_process()
    |> GenServer.cast({:pong, msg})
  end

  def handle_cast({:join, %{"id" => client_id}}, %{clients: clients} = state) do
    {
      :noreply,
      %{state | clients: Map.put(clients, client_id, %{offset: 0})}
    }
  end

  def handle_cast({:pong, %{"id" => client_id, "serverTime" => send_time, "clientTime" => client_time}}, %{clients: clients} = state) do
    now = System.monotonic_time(:millisecond)
    offset = ((2 * client_time) - now - send_time) / 2
    {:noreply, %{state | clients: Map.put(clients, client_id, %{offset: offset})}}
  end

  def receive_join(room_id, msg) do
    room_id
    |> Reg.server_process()
    |> GenServer.cast({:join, msg})
  end

  def handle_info(:do_ping, %{room_id: room_id} = state) do
    msg = %{serverTime: System.monotonic_time(:millisecond)}
    broadcast(room_id, "ping", msg)
    {:noreply, state}
  end

  def start_link(room_id) do
    GenServer.start_link(Sink.Backend.Worker, room_id, name: global_name(room_id))
  end

  def global_name(room_id) do
    {:global, {__MODULE__, room_id}}
  end

  def whereis(room_id) do
    case :global.whereis_name({__MODULE__, room_id}) do
    :undefined -> nil
    pid -> pid
    end
  end
end
