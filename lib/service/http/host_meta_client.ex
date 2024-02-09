defmodule Mobilizon.Service.HTTP.HostMetaClient do
  @moduledoc """
  Tesla HTTP Basic Client
  with XML middleware
  """

  use Tesla
  alias Mobilizon.Config
  import Mobilizon.Service.HTTP.Utils, only: [get_tls_config: 0]

  @default_opts [
    recv_timeout: 20_000
  ]

  adapter(Tesla.Adapter.Hackney, Keyword.merge([ssl_options: get_tls_config()], @default_opts))

  plug(Tesla.Middleware.FollowRedirects)

  plug(Tesla.Middleware.Timeout, timeout: 10_000)

  plug(Tesla.Middleware.Headers, [
    {"User-Agent", Config.instance_user_agent()},
    {"Accept", "application/xrd+xml, application/xml, text/xml"}
  ])
end
