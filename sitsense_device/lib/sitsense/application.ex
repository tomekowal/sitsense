defmodule Sitsense.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :rest_for_one, name: Sitsense.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    common_children() ++
      [
        # Starts a worker by calling: Sitsense.Worker.start_link(arg)
        # {Sitsense.Worker, arg},
      ]
  end

  def children(_target) do
    common_children() ++
      [
        # Starts a worker by calling: Sitsense.Worker.start_link(arg)
        # {Sitsense.Worker, arg},
        {Sitsense.DistanceSensor, []}
      ]
  end

  def common_children() do
    [
      SitsenseWeb.Endpoint
    ]
  end
end
