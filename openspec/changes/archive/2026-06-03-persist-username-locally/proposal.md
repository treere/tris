## Why

The username is currently passed through URL query parameters (`?username=`, `?n=`, `?o=`) everywhere. This is fragile — if the param is dropped during navigation, bookmarked, or the page is refreshed, the user loses their identity and must re-enter their name. Usernames also leak in shared URLs. The app already has a working localStorage pattern for the theme system.

## What Changes

- Persist the username in `localStorage` so it survives page refreshes, bookmarks, and browser restarts
- Remove all username-related query params from URLs (`?username=` on lobby, `?n=` and `?o=` on game)
- Game page reads the player's name from `GameServer` state (already the primary source) — the URL fallback becomes unnecessary
- Lobby reads the username from `localStorage` on mount via a colocated JS hook (matching the theme pattern)
- Remove the `?username=` param from game-to-lobby redirects — the lobby reads from `localStorage` instead

## Capabilities

### New Capabilities
- `username-persistence`: localStorage-based username storage — save on set, read on mount, survive across sessions

### Modified Capabilities

(none)

## Impact

- `lib/tris_web/live/lobby_live.ex` — `mount/3` no longer reads `?username=` from params; reads from `localStorage` instead; `handle_event("set_username")` saves to `localStorage`; no username in game navigation URLs
- `lib/tris_web/live/game_live.ex` — Remove `?n=` and `?o=` query param handling; remove `?username=` from redirect URLs; game already reads names from `game_state.names[]` as primary source
- New: A colocated JS hook in LobbyLive for `localStorage` read/write of the username
- No new dependencies
