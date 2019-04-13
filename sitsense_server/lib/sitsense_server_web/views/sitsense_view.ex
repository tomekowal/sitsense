defmodule SitsenseServerWeb.SitsenseView do
  use Phoenix.LiveView
  import Calendar.Strftime
  @update_every_ms 200

  def render(assigns) do
    ~L"""
    <div class="spacer"></div>
    <div class="thermostat">

      <div class="bar <%= @mode %>">
        <a phx-click="toggle-mode"><%= @mode %></a>
        <span><%= strftime!(@time, "%r") %></span>
      </div>
      <div class="controls">
        <span class="reading"><%= @val %></span>
        <button phx-click="dec" class="minus">-</button>
        <button phx-click="inc" class="plus">+</button>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: Process.send_after(self(), :tick, @update_every_ms)
    val = SitsenseServer.distance_from_device()
    {:ok, assign(socket, val: val, mode: :cooling, time: :calendar.local_time())}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @update_every_ms)

    socket
    |> update_time
    |> update_distance
    |> noreply
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def handle_event("toggle-mode", _, socket) do
    {:noreply,
     update(socket, :mode, fn
       :cooling -> :heating
       :heating -> :cooling
     end)}
  end

  defp update_time(socket) do
    time = :calendar.local_time()
    assign(socket, time: time)
  end

  defp update_distance(%{assigns: %{val: val}} = socket) do
    new_val = SitsenseServer.distance_from_device()
    IO.inspect(new_val)

    new_val =
      if new_val > 2000 do
        val
      else
        trunc((val + 0.2 * new_val) / 1.2)
      end

    new_val = if abs(new_val - val) < 1, do: val, else: new_val

    mode =
      if new_val > 40 && new_val < 60 do
        :cooling
      else
        :heating
      end

    assign(socket, val: new_val, mode: mode)
  end

  defp update_distance(socket) do
    socket
  end

  defp noreply(socket) do
    {:noreply, socket}
  end
end
