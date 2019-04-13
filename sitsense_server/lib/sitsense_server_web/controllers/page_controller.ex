defmodule SitsenseServerWeb.PageController do
  use SitsenseServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
