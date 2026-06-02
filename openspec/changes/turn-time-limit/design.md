## Context

Game state lives in `Tris.GameServer` (a GenServer), one per game. Turns are tracked via `state.turn` (`:x` or `:o`). The `GameLive` subscribes to PubSub for game updates. Currently the only timer is the bot move delay (`Process.send_after` at 800ms). No turn timeout exists.

## Goals / Non-Goals

**Goals:**
- Add a 30-second per-turn timer starting when a player's turn begins
- Display a live countdown in the UI, synced from server timestamps
- Auto-forfeit the current player when the timer expires
- Show timer for both human players; no timer for bot turns

**Non-Goals:**
- Configurable time limits (hardcoded 30s for now)
- Incremental time or Fischer clock
- Persistence or audit log of timeouts

## Decisions

1. **Server-side authoritative timer** — The GenServer starts a `Process.send_after` for each turn. On timeout, the GameServer forfeits the current player. The LiveView receives the timer via PubSub pushes, not local JS timers, to prevent cheating.

2. **Timer synced via `turn_started_at`** — The GameServer stores `turn_started_at` (monotonic timestamp) in state. On each PubSub update, the LiveView computes remaining time using `System.monotonic_time()` difference. A `:timer_tick` message fires every second on the LiveView to re-render the countdown.

3. **Bot turns skip timer** — No timer started when `state.turn` belongs to a bot. The existing 800ms bot delay handles it.

4. **No new dependency** — Uses `Process.send_after` and `System.monotonic_time` which are OTP built-ins.

## Risks / Trade-offs

- [Timer drift] — `Process.send_after` isn't real-time guaranteed under heavy load, but 30s is generous enough that a few ms of jitter is negligible.
- [Network latency] — The countdown is server-authoritative. If the client lags, the displayed time may be slightly behind. Since timeout triggers server-side, the displayed countdown is the upper bound — the actual cutoff may fire before the client reaches 0. Mitigated by the fact that 30s is long enough for typical latency.
- [LiveView timer tick overhead] — A `:timer_tick` send_after on each LiveView process firing every second is lightweight.
