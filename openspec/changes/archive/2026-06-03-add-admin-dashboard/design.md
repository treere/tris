## Context

Tris currently has no visibility into real-time usage. Game and user data exists in GenServers and a Registry but is not exposed through any UI. An admin dashboard needs authentication, user tracking, and a way to aggregate stats from distributed processes.

## Goals / Non-Goals

**Goals:**
- Single shared password via `ADMIN_PASSWORD` env var, HTTP Basic Auth
- Track users via Phoenix.Presence (auto-cleanup on disconnect)
- Show real-time stats: users online (lobby vs in-game), active games, bot/human split, difficulty distribution, queue depth
- Stats update every 3 seconds (snapshot polling)
- Page auto-updates via LiveView assigns

**Non-Goals:**
- No persistent storage or history
- No multi-user auth or roles
- No modifying GameServer or Matchmaker internals

## Decisions

- **Phoenix.Presence over raw Registry**: Presence gives `list/0` with metadata out of the box and cluster-ready tracking. LobbyLive and GameLive each `track()` their PID with metadata (`%{location: "lobby"}` or `%{location: "game", game_id: ..., mark: ...}`). Presence handles auto-cleanup on process exit.
- **Snapshot polling over PubSub streaming**: AdminLive uses `Process.send_after(self(), :tick, 3000)` to poll. Simpler to build and reason about. 3s resolution is real-time enough for an admin page.
- **Plug.BasicAuth over session auth**: One line in the router pipeline, no session management, no login form. Password configured via `ADMIN_PASSWORD` environment variable.
- **Admin route outside default scope**: Mounts under `/admin` with its own `pipe_through [:browser, :admin_auth]` pipeline.

## Risks / Trade-offs

- [Polling load] Querying every game PID every 3s could add latency as games grow. → Mitigation: Keep the query lightweight (GenServer call, no heavy processing). 100 games x 3s = 33 calls/sec, well within GenServer capacity.
- [Presence metadata cost] Every LiveView mount/unmount triggers Presence diff broadcast. → Negligible in practice, Presence is designed for this.
- [Admin password in env] If `ADMIN_PASSWORD` is unset, auth blocks everyone. → Startup warning or fallback to a dev default in dev mode.
