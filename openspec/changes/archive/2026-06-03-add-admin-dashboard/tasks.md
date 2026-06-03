## 1. Presence Setup

- [x] 1.1 Create `Tris.Presence` module using `Phoenix.Presence`
- [x] 1.2 Add `Tris.Presence` to the supervision tree in `application.ex`
- [x] 1.3 Track user presence in `LobbyLive` on mount (topic: "user", metadata: `%{location: "lobby"}`)
- [x] 1.4 Track user presence in `GameLive` on mount (topic: "user", metadata: `%{location: "game", game_id: game_id, mark: mark}`)

## 2. Admin Auth

- [x] 2.1 Add `Plug.BasicAuth` to the router with an `:admin_auth` pipeline
- [x] 2.2 Add `/admin` route using the admin pipeline
- [x] 2.3 Configure `ADMIN_PASSWORD` env var with dev fallback

## 3. Admin Dashboard

- [x] 3.1 Create `AdminLive` LiveView that polls stats every 3 seconds
- [x] 3.2 Implement `collect_stats/0` to gather data from Presence, DynamicSupervisor, Registry, GameServer, and Matchmaker
- [x] 3.3 Render dashboard UI with stat cards and active games list

## 4. Tests

- [x] 4.1 Add test for admin auth (authenticated vs unauthenticated access)
- [x] 4.2 Add test for admin dashboard rendering stats
