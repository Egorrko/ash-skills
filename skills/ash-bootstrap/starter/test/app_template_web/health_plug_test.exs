defmodule AppTemplateWeb.HealthPlugTest do
  use AppTemplateWeb.ConnCase, async: true

  test "GET /health answers 200 without the router", %{conn: conn} do
    conn = get(conn, "/health")
    assert conn.status == 200
    assert conn.resp_body == "ok"
    assert conn.halted
  end
end
