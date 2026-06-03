defmodule TrisWeb.Plugs.AdminAuth do
  alias Plug.BasicAuth

  def init(opts), do: opts

  def call(conn, opts) do
    BasicAuth.basic_auth(conn, opts)
  end
end
