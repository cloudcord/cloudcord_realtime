defmodule CloudcordRealtimeWeb.UserSocket do
  use Phoenix.Socket

  # Replace below with your JWT secret in the "k" field
  @jwk %{
    "k" => "",
    "kty" => "oct"
  }

  channel "core_bot_updates:*", CloudcordRealtimeWeb.BotUpdatesChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    case JOSE.JWT.verify_strict(@jwk, ["HS256"], token) do
      {true, %JOSE.JWT{fields: %{"data" => %{"user_id" => cc_user_id}}}, _} ->
        {:ok, assign(socket, :user_id, cc_user_id)}
      {false, _, _} ->
        :error
    end
  end

  def id(socket), do: "subusers:#{socket.assigns.user_id}"
end
