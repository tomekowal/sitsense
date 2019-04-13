defmodule Sitsense do
  @moduledoc """
  The application will ask HC-SR04 sensor for proximity
  """
  alias Sitsense.DistanceSensor

  if Mix.target() != :host do
    defdelegate distance(), to: DistanceSensor, as: :current_distance
  else
    def distance(), do: 20.0
  end
end
