defmodule SitsenseWeb.Endpoint do
  use Plug.Router
  use Plug.Debugger, otp_app: :sitsense
  require Logger

  @port 80

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp message do
    %{
      distance: Sitsense.distance()
    }
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Plug.Cowboy.http(__MODULE__, [], port: @port)
  end
end
