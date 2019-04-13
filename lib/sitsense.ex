defmodule Sitsense do
  @moduledoc """
  The application will ask HC-SR04 sensor for proximity
  """
  use Application

  require Logger

  alias Circuits.GPIO

  @trig_pin 4
  @echo_pin 17

  @doc """
  Start sensor and try measuring stuff with it.
  The sensor works by sending short signal to trig to send ultrasonic wave
  and waiting on echo pin to comeback.
  """
  def start(_type, _args) do
    {input_gpio, output_gpio} = initialize()
    spawn(fn -> measure_distance(input_gpio, output_gpio) end)
    {:ok, self()}
  end

  defp initialize() do
    Logger.info("Starting pin #{@trig_pin} as output")
    {:ok, output_gpio} = GPIO.open(@trig_pin, :output)
    GPIO.write(output_gpio, 0)
    Process.sleep(2000)

    Logger.info("Starting pin #{@echo_pin} as input")
    {:ok, input_gpio} = GPIO.open(@echo_pin, :input)
    Process.sleep(500)

    {input_gpio, output_gpio}
  end

  def measure_distance(input_gpio, output_gpio) do
    GPIO.set_interrupts(input_gpio, :both)
    measure_distance_loop(input_gpio, output_gpio)
  end

  def measure_distance_loop(input_gpio, output_gpio) do
    Logger.info("Starting measurment")
    trigger(output_gpio)

    start_time =
      receive do
        {:circuits_gpio, 17, timestamp, 1} ->
          timestamp
      after
        1000 -> Logger.info("timedout 1")
      end

    end_time =
      receive do
        {:circuits_gpio, 17, timestamp, 0} ->
          timestamp
      after
        1000 -> Logger.info("timedout 2")
      end

    report_distance(start_time, end_time)

    measure_distance_loop(input_gpio, output_gpio)
  end

  defp report_distance(start_time, end_time)
       when is_integer(start_time) and is_integer(end_time) do
    time_elapsed = end_time - start_time
    distance = time_elapsed * 34300 / 2_000_000_000.0

    Logger.info("Distance #{distance} cm")
  end

  defp report_distance(_, _) do
    Logger.info("Could not calc time")
  end

  # set low for two seconds to give it time to breathe
  # next HC-SR04 requires 10us burst to init
  defp trigger(output_gpio) do
    GPIO.write(output_gpio, 1)
    Process.sleep(1)
    GPIO.write(output_gpio, 0)
  end
end
