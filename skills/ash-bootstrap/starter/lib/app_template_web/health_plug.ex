defmodule AppTemplateWeb.HealthPlug do
  @moduledoc """
  Answers `GET /health` with 200 ahead of the whole endpoint stack, without touching
  the database: the systemd unit, `up` and the bootstrap check read it to know the
  release is up.
  """
  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{method: "GET", path_info: ["health"]} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
