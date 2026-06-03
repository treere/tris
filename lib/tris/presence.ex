defmodule Tris.Presence do
  use Phoenix.Presence, otp_app: :tris, pubsub_server: Tris.PubSub
end
