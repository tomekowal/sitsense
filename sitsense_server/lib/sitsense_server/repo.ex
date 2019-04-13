defmodule SitsenseServer.Repo do
  use Ecto.Repo,
    otp_app: :sitsense_server,
    adapter: Ecto.Adapters.Postgres
end
