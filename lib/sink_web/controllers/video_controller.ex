defmodule SinkWeb.VideoController do
  use SinkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
