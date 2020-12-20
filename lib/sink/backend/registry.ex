defmodule Sink.Backend.Registry do
  def start_link() do
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process({name, channel}) do
    existing_process(name) || new_process({name, channel})
  end

  defp existing_process(name) do
    Sink.Backend.Worker.whereis(name)
  end

  defp new_process(init_arg) do
    case DynamicSupervisor.start_child(__MODULE__, {Sink.Worker, init_arg}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
