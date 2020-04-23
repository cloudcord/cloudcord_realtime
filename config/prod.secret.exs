# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

secret_key_base =
  "pcrCHNT2c/0F1hGQcbm/JYAimM99mcF8jzggHVh4mETi/Kg4AtHyhB3j1/uDHRQk" ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :cloudcord_realtime, CloudcordRealtimeWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base
