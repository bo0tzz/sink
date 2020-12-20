defmodule Sink.Backend.Worker do
  use GenServer
  import SinkWeb.Endpoint, [:broadcast/3]

  def init({name, channel}) do
    :timer.send_interval(5000, :do_ping)
    state = %{
      name: name,
      channel: channel
    }
    {:ok, state}
  end

  def handle_info(:do_ping, %{channel: channel} = state) do
    msg = %{serverTime: System.monotonic_time(:millisecond)}
    broadcast(channel, "ping", msg)
    {:noreply, state}
  end

  def start_link({name, channel}) do
    GenServer.start_link(Sink.Worker, {name, channel}, name: global_name(name))
  end

  def global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
    :undefined -> nil
    pid -> pid
    end
  end
end
