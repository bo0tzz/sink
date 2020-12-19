defmodule Sink.Repo do
  use Ecto.Repo,
    otp_app: :sink,
    adapter: Ecto.Adapters.Postgres
end
