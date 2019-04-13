defmodule SitsenseServer do
  @moduledoc """
  SitsenseServer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @device_location "http://sitsense.local/"
  def distance_from_device do
    {:ok, %{body: body}} = HTTPoison.get(@device_location, [], [])
    %{"distance" => distance} = Jason.decode!(body)
    Kernel.trunc(distance)
  end
end
