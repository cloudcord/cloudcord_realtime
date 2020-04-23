defmodule CloudcordRealtime.RedisConnector do
  use GenServer
  @topic :redis_cx_updates

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :local_redis_client)
  end

  def init(_) do
    {:ok, conn} = Redix.PubSub.start_link(host: "redis-master", port: 6379)
    Redix.PubSub.subscribe(conn, "cc-realtime-events", self())
    Redix.PubSub.subscribe(conn, "cc-core-events", self())

    {:ok, :no_state}
  end

  def handle_info({:redix_pubsub, _pubsub, _pid, :subscribed, %{channel: channel}}, state) do
    IO.puts "Redis: subscribed to #{channel}"
    {:noreply, state}
  end

  def handle_info({:redix_pubsub, _pubsub, _pid, :unsubscribed, %{channel: channel}}, state) do
    IO.puts "Redis: unsubscribed from #{channel}"
    {:noreply, state}
  end

  def handle_info({:redix_pubsub, _pubsub, _pid, :message, %{channel: channel, payload: payload}}, state) do
    IO.puts "Redis: received message #{payload}"
    data = Poison.decode!(payload)

    handle_channel({channel, data})

    {:noreply, state}
  end

  defp handle_channel({"cc-realtime-events", data}) do
    case data["action"] do
      "disconnect_user" -> CloudcordRealtimeWeb.Endpoint.broadcast("subusers:#{data["data"]["user_id"]}", "disconnect", %{})
      "bot_config_update" -> CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_config_update", data["data"])
      "command_executed" -> CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_command_executed", data["data"])
      "bot_hello_ack" -> CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_ack", data["data"])
      "bot_process_down" -> CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_process_down", data["data"])
    end
  end

  defp handle_channel({"cc-core-events", data}) do
    with %{"creator" => creator} <- data["data"] do
      case data["action"] do
        "updateBotConfig" ->
          CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_config_update", data["data"])
        "stopBotOnNode" ->
          CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_stopping", data["data"])
        "createNewBotGS" ->
          CloudcordRealtimeWeb.Endpoint.broadcast("core_bot_updates:#{data["data"]["creator"]}", "bot_starting", data["data"])
        _ -> {:none}
      end
    end
  end
end