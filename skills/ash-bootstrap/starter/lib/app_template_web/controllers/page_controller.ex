defmodule AppTemplateWeb.PageController do
  use AppTemplateWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
