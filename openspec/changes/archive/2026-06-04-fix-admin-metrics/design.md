## Context

The admin dashboard polls every 3 seconds and computes a stats map from three sources: GameRegistry (game states), Presence (user locations), and Matchmaker (queue). The current computation has several bugs:

1. **`total_users` double-counts** — Users in the matchmaker queue are still tracked in lobby presence, so `lobby_users + in_game_users + queue_depth` counts queued users twice
2. **Bot name filtering is fragile** — `Enum.reject(&String.contains?(&1, "Bot"))` filters by display-name substring instead of the semantic `bot_difficulty` field, risking false exclusion of human names containing "bot"
3. **"Active Games" includes finished games** — GameServer processes never terminate after a game ends (win/tie/resign/timeout). They stay in the Registry forever, so every finished game inflates the "Active Games" count
4. **Resign can crash the GenServer** — `Enum.find(state.players, ...)` returns `nil` if the calling PID isn't found, then the destructure `{resigning_mark, _other} = nil` raises a MatchError that crashes the GameServer process

## Goals / Non-Goals

**Goals:**
- `total_users` counts each unique user exactly once
- "Active Games" only counts games with `status: :playing`
- Bot/human distinction in metrics uses the semantic `bot_difficulty` field
- Matchmaker exposes a public `queue_length/0` API (replace raw `:sys.get_state`)
- Resign with an unrecognized PID returns `{:error, :player_not_found}` instead of crashing
- Comprehensive tests verify metric accuracy under realistic conditions including game resolution

**Non-Goals:**
- Full metric system redesign (e.g., streaming vs polling)
- Adding new metrics not already tracked
- Changing the admin UI layout or visual design
- Fixing transient double-counting during LiveView navigation
- Game process lifecycle management (cleanup after game end — out of scope, but admin should handle it regardless)

## Decisions

### Decision 1: Fix `total_users` to `lobby_users + in_game_users`

- **Chosen**: `total_users = lobby_users + in_game_users`
- **Rationale**: Queue users are a strict subset of lobby users (they haven't navigated away from the lobby). The overlap between in-game and lobby/queue is only during the brief LiveView navigation window, which is inherent to polling. This formula eliminates persistent double-counting.
- **Alternatives considered**: Using Presence as the sole source and cross-referencing `location:"game"` metas. Rejected because a user's presence may be cleaned up before their game state resolves.

### Decision 2: Semantic bot filtering via `players` map

- **Chosen**: Use the game's `players` map — a player is human if their PID is not `:bot`. Extract the human names from each game's `names` map at the same key where `players` has a real PID.
- **Rationale**: Ties classification to the source-of-truth field rather than display label conventions. Survives display label changes.
- **Alternatives considered**: Matching the exact bot name string. Fragile if labels change. Checking `bot_difficulty` alone doesn't identify WHICH player is the bot in a multi-player context.

### Decision 3: Admin filters "Active Games" by `status: :playing`

- **Chosen**: In `collect_stats/0`, count active games as only those with `status: :playing`. Also filter the games list for the table to only show active games.
- **Rationale**: GameServer processes stay alive indefinitely after a game ends. Rather than changing the game lifecycle (which would affect the player experience — they need the game process to show the result screen), the admin should correctly categorize games by their actual status.
- **Alternatives considered**: Auto-terminate GameServer after a delay. Rejected because it changes the game experience and adds complexity. Better as a separate change.

### Decision 4: Safe resign PID lookup

- **Chosen**: Replace the `Enum.find` destructure with a `case` that handles `nil`. If the PID isn't found (spectator, stale connection, or race), return `{:error, :player_not_found}`.
- **Rationale**: A GenServer crash on any unexpected input is fragile. Returning an error allows the caller (GameLive) to handle it gracefully.
- **Alternatives considered**: Ignoring and returning `{:ok, state}`. Rejected — the state shouldn't change if no matching player was found. Raising a descriptive error. Rejected — crashes are never graceful in production.

### Decision 5: Public `Matchmaker.queue_length/0`

- **Chosen**: Add `def queue_length, do: GenServer.call(__MODULE__, :queue_length)` and handle the call
- **Rationale**: `:sys.get_state` reaches into internal state and couples the admin to the GenServer's state shape. Public API encapsulates the implementation detail.
- **Alternatives considered**: Keep `:sys.get_state`. Rejected for maintainability.

## Risks / Trade-offs

- **Risk**: In-game users who've disconnected (game still running, presence gone) won't be counted in `total_users` via the formula. → Mitigation: Acceptable — the game will eventually timeout/clean up. The in-game count is already tracked separately.
- **Trade-off**: Using `players` map to identify humans requires that GameServer state has `players: %{x: pid | :bot, o: pid | :bot}`. If this structure changes, the admin still breaks — but this is more explicit than hidden string matching.
- **Trade-off**: Filtering finished games in the admin rather than terminating game processes means the games list will still contain finished games — they just won't be counted as "active." Game processes accumulate over time (memory). This is acceptable for a game like tic-tac-toe where games are short-lived, but a long-running server would accumulate stale processes. A separate process-sweep change could address this later.
- **Risk**: The resign crash fix only handles the symptom (PID not found). Root causes like a spectator accessing the game page without a valid mark could still allow a user to reach the resign button without having a registered PID. → Mitigation: Could gate the resign button on `@player_mark != nil`, but that's a separate improvement.
