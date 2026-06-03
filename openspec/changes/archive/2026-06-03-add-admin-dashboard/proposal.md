## Why

There is no visibility into who is using the app in real time — how many users are online, how many games are active, how many are playing against bots vs humans. An admin dashboard provides operational insight and a fun window into the live state of the system.

## What Changes

- Add a new `/admin` route behind HTTP Basic Auth (password from `ADMIN_PASSWORD` env var)
- Define a `Tris.Presence` module using `Phoenix.Presence` to track user presence
- Track user presence from `LobbyLive` (lobby) and `GameLive` (in-game) mounts
- Create an `AdminLive` dashboard showing: users online (lobby vs in-game), active games, bot/human split, difficulty breakdown, queue depth, live game list
- Dashboard polls for stats every 3 seconds (or receives presence push updates)

## Capabilities

### New Capabilities
- `admin-dashboard`: Password-protected admin panel with real-time usage analytics
- `user-presence`: Real-time user tracking via Phoenix.Presence, used by both lobby and game LiveViews

### Modified Capabilities

None.

## Impact

- New file `lib/tris_web/presence.ex` — Phoenix.Presence module
- New file `lib/tris_web/live/admin_live.ex` — admin dashboard LiveView
- New route `/admin` in router with `Plug.BasicAuth`
- Modified `LobbyLive` — calls `Presence.track` on mount/terminate
- Modified `GameLive` — calls `Presence.track` on mount/terminate
- `Tris.Presence` registered in supervision tree
