defmodule SitsenseServer do
  @moduledoc """
  SitsenseServer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require Logger

  @device_location "http://sitsense.local/"
  def distance_from_device do
    if System.get_env("MIX_TARGET") == "rpi0" do
      {:ok, %{body: body}} = HTTPoison.get(@device_location, [], [])
      %{"distance" => distance} = Jason.decode!(body)
      Logger.info("Distance from device = #{distance}")
      distance = distance_to_int(distance)
    else
      :rand.uniform(30) + 60
    end
  end

  defp distance_to_int("not_calculated"), do: nil
  defp distance_to_int(float), do: Kernel.trunc(float)
end
