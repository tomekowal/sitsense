defmodule Sitsense do
  @moduledoc """
  The application will ask HC-SR04 sensor for proximity
  """
  alias Sitsense.DistanceSensor

  defdelegate distance(), to: DistanceSensor, as: :current_distance
end
