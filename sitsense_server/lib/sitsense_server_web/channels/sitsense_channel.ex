defmodule SitsenseServerWeb.SitsenseChannel do
  use Phoenix.Channel

  def join("sitsense:notifications", _message, socket) do
    {:ok, socket}
  end
end
