use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sitsense_server, SitsenseServerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :sitsense_server, SitsenseServer.Repo,
  username: "postgres",
  password: "postgres",
  database: "sitsense_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
