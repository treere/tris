defmodule TrisWeb.Plugs.AdminAuth do
  alias Plug.BasicAuth

  def init(opts), do: opts

  def call(conn, opts) do
    password = Application.get_env(:tris, :admin_password, "admin")
    BasicAuth.basic_auth(conn, Keyword.put(opts, :password, password))
  end
end
