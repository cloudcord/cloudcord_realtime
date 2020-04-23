defmodule CloudcordRealtimeWeb.BotUpdatesChannel do
  use Phoenix.Channel

  def join("core_bot_updates:" <> user_id, _message, socket) do
    if socket.assigns.user_id == user_id do
      {:ok, socket}
    else
      {:error, %{"reason": "unauthorized"}}
    end
  end

  def handle_in("bot_config_update", msg, socket) do
    push(socket, "bot_config_update", msg)
    {:noreply, socket}
  end
end
