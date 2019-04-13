defmodule Sitsense.DistanceSensor do
  @moduledoc """
  The application will ask HC-SR04 sensor for proximity
  """
  use GenServer

  require Logger
  alias Circuits.GPIO

  @trig_pin 4
  @echo_pin 17

  @doc """
  Start sensor and measure distance in cm as fast as possible
  The sensor works by sending short signal to trig pin to send ultrasonic wave
  and waiting on echo pin to comeback.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def current_distance() do
    GenServer.call(__MODULE__, :distance)
  end

  def init(:ok) do
    send(self(), :init)
    {:ok, %{}}
  end

  def handle_call(:distance, _from, state) do
    reply = Map.fetch(state, :distance)
    reply(reply, state)
  end

  def handle_info(:init, _state) do
    {input_gpio, output_gpio} = initialize()
    new_state = %{input_gpio: input_gpio, output_gpio: output_gpio, distance: 0}
    noreply(new_state)
  end

  def handle_info(:timeout, %{output_gpio: output_gpio} = state) do
    trigger(output_gpio)
    noreply(state, 1000)
  end

  def handle_info({:circuits_gpio, 17, start_time, 1}, state) do
    noreply(Map.put(state, :start_time, start_time), 1000)
  end

  def handle_info({:circuits_gpio, 17, end_time, 0}, state) do
    distance = calculate_distance(Map.get(state, :start_time), end_time)
    noreply(Map.put(state, :distance, distance))
  end

  defp initialize() do
    Logger.info("Starting pin #{@trig_pin} as output")
    {:ok, output_gpio} = GPIO.open(@trig_pin, :output)
    GPIO.write(output_gpio, 0)
    Process.sleep(2000)

    Logger.info("Starting pin #{@echo_pin} as input")
    {:ok, input_gpio} = GPIO.open(@echo_pin, :input)
    Process.sleep(500)

    GPIO.set_interrupts(input_gpio, :both)
    {input_gpio, output_gpio}
  end

  defp calculate_distance(start_time, end_time)
       when is_integer(start_time) and is_integer(end_time) do
    time_elapsed = end_time - start_time
    time_elapsed * 34300 / 2_000_000_000.0
  end

  defp calculate_distance(_, _) do
    :not_caculated
  end

  # set low for two seconds to give it time to breathe
  # next HC-SR04 requires 10us burst to init
  defp trigger(output_gpio) do
    GPIO.write(output_gpio, 1)
    Process.sleep(1)
    GPIO.write(output_gpio, 0)
  end

  defp reply(reply, state) do
    {:reply, reply, state, 0}
  end

  defp noreply(state, timeout \\ 0) do
    {:noreply, state, timeout}
  end
end
