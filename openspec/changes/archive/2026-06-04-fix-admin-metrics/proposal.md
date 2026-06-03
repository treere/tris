## Why

The admin dashboard reports inaccurate usage metrics. `total_users` double-counts users in the matchmaker queue (they're in both lobby presence and queue depth), and the `in_game_users` filter relies on fragile string matching (`String.contains?("Bot")`) instead of the semantic `bot_difficulty` field. Additionally, "Active Games" counts finished games (won/tie/resigned) because GameServer processes never terminate — so every resignation, timeout, or win inflates the count. The resign flow itself has a potential crash path when a player PID isn't found in the game's players map. These bugs erode trust in the admin dashboard as a source of truth for operational awareness.

## What Changes

- **Fix `total_users` calculation** — subtract the overlap between lobby and queue users so each unique user is counted once
- **Fix "Active Games" count** — filter by `status: :playing` so finished games aren't counted as active. Games that have ended (won, tie, resigned, timeout) should not appear in the active count or the active games table
- **Replace string-based bot name filtering** — use `bot_difficulty` field and `players` map (`:bot` PID check) to distinguish bot vs human players
- **Fix resign crash path** — handle the case where `Enum.find` returns `nil` in the resign handler (PID not in players map) instead of crashing the GenServer
- **Add comprehensive tests** — unit tests for `collect_stats/0` metric computation and integration tests verifying correct numbers with real system state (games, presence, queue, resignation)

## Capabilities

### New Capabilities

None — this is a fix to an existing capability.

### Modified Capabilities

- `admin-dashboard`: Requirement "Admin dashboard shows real-time stats" — the metrics reported (`total_users`, `in_game_users`) must be accurate. Existing scenarios updated to specify correct counting behavior.

## Impact

- `lib/tris_web/live/admin_live.ex` — metric computation logic in `collect_stats/0` (total_users fix, active games filter, bot detection)
- `lib/tris/game_server.ex` — safe PID lookup on resign (fix crash path)
- `lib/tris/matchmaker.ex` — expose a public `queue_length/0` function (replacing raw `:sys.get_state` access)
- `test/tris_web/live/admin_live_test.exs` — new tests for metric accuracy including resign scenarios
- `openspec/specs/admin-dashboard/spec.md` — clarify counting semantics in scenarios
