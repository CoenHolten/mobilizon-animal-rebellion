use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :mobilizon, MobilizonWeb.Endpoint,
  http: [
    port: System.get_env("MOBILIZON_INSTANCE_PORT") || 4000
  ],
  url: [
    host: System.get_env("MOBILIZON_INSTANCE_HOST") || "mobilizon.local",
    port: 80,
    scheme: "http"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    yarn: ["run", "dev", cd: Path.expand("../js", __DIR__)]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :mobilizon, MobilizonWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/mobilizon_web/views/.*(ex)$},
      ~r{lib/mobilizon_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n", level: :debug

config :mobilizon, Mobilizon.Service.Geospatial, service: Mobilizon.Service.Geospatial.Nominatim

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :mobilizon, Mobilizon.Mailer, adapter: Bamboo.LocalAdapter

# Configure your database
config :mobilizon, Mobilizon.Repo,
  types: Mobilizon.PostgresTypes,
  username: System.get_env("MOBILIZON_DATABASE_USERNAME") || "mobilizon",
  password: System.get_env("MOBILIZON_DATABASE_PASSWORD") || "mobilizon",
  database: System.get_env("MOBILIZON_DATABASE_DBNAME") || "mobilizon_dev",
  hostname: System.get_env("MOBILIZON_DATABASE_HOST") || "localhost",
  port: System.get_env("MOBILIZON_DATABASE_PORT") || "5432",
  pool_size: 10
