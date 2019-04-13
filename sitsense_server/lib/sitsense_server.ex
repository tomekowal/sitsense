defmodule SitsenseServer do
  @moduledoc """
  SitsenseServer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @device_location "http://sitsense.home/"
  def distance_from_device do
    case HTTPoison.get(@device_location, [timeout: 500], []) do
      {:ok, %{body: body}} ->
        %{"distance" => distance} = Jason.decode!(body)
        Kernel.trunc(distance)

      _ ->
        :rand.uniform(30) + 60
    end
  end
end
