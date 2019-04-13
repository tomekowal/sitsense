defmodule SitsenseServerWeb.PageController do
  use SitsenseServerWeb, :controller
  import Phoenix.LiveView.Controller, only: [live_render: 3]

  def index(conn, _params) do
    conn
    |> live_render(SitsenseServerWeb.SitsenseView, session: %{})
  end
end
