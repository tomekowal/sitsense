defmodule SitsenseServerWeb.SitsenseView do
  use Phoenix.LiveView
  import Calendar.Strftime
  @update_every_ms 200
  @smoothing_factor 0.3

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

    socket
    |> update_assigns
    |> ok
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @update_every_ms)

    socket
    |> update_assigns
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

  defp update_assigns(socket) do
    socket
    |> update_time
    |> update_distance
    |> update_mode
    |> update_mode_counter
    |> maybe_send_notification
  end

  defp update_time(socket) do
    time = :calendar.local_time()
    assign(socket, time: time)
  end

  defp update_distance(%{assigns: %{val: val}} = socket) do
    new_val = SitsenseServer.distance_from_device() || val

    new_val =
      if new_val > 150 do
        val
      else
        trunc((val + @smoothing_factor * new_val) / (1.0 + @smoothing_factor))
      end

    new_val = if abs(new_val - val) < 1, do: val, else: new_val

    assign(socket, val: new_val)
  end

  defp update_distance(socket) do
    assign(socket, val: 50)
  end

  defp update_mode(%{assigns: %{val: val}} = socket) do
    new_mode =
      if val > 40 && val < 60 do
        :cooling
      else
        :heating
      end

    assign(socket, mode: new_mode)
  end

  defp update_mode(socket) do
    assign(socket, mode: :cooling)
  end

  defp update_mode_counter(%{assigns: %{mode: mode, counter: _}} = socket) do
    case mode do
      :heating -> update(socket, :counter, &(&1 + 1))
      :cooling -> assign(socket, :counter, 0)
    end
  end

  defp update_mode_counter(socket) do
    assign(socket, :counter, 0)
  end

  defp maybe_send_notification(%{assigns: %{counter: counter}} = socket) do
    if counter == 10 do
      SitsenseServerWeb.Endpoint.broadcast("sitsense:notifications", "notification", %{})
    end

    socket
  end

  defp maybe_send_notification(socket) do
    socket
  end

  defp noreply(socket) do
    {:noreply, socket}
  end

  defp ok(socket) do
    {:ok, socket}
  end
end
