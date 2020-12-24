defmodule SinkWeb.VideoChannel do
  use Phoenix.Channel
  require Logger

  alias Sink.Backend.Worker

  intercept ["play"]

  def join(_topic, msg, %{topic: room_id} = socket) do
    Worker.receive_join(room_id, msg)
    {:ok, socket}
  end

  def handle_in("pong", msg, %{topic: room_id} = socket) do
    Logger.info("Received pong: #{inspect(msg)}")
    Worker.receive_pong(room_id, msg)
    {:noreply, socket}
  end

  def handle_in("pause", _, socket) do
    Logger.info "Sending out pause"
    broadcast!(socket, "pause", %{})
    {:noreply, socket}
  end

  def handle_in("play", _, %{topic: _room_id} = socket) do
    Logger.info "#{inspect socket}"
    broadcast!(socket, "play", %{})
    {:noreply, socket}
  end

  def handle_out("play", msg, socket) do
    # TODO: Latency offset calculations
    push(socket, "play", msg)
    {:noreply, socket}
  end
end
