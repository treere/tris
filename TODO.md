# TODO

## WARNING (Should fix)

### 1. Add GameLive tests
**No test coverage for `game_live.ex`** — board rendering, turn indicators, winning highlights, result display, `register_player` integration, and PubSub subscription are untested at the LiveView layer.

- Add `test/tris_web/live/game_live_test.exs` covering:
  - Board renders at game start
  - Cell clicks send moves
  - Result appears on win/tie
  - "Return to lobby" navigates away

### 2. Add Matchmaker tests
**No direct test coverage for `matchmaker.ex`** — pairing logic, queue management, 3+-player scenario, and cancel flow are untested.

- Add `test/tris/matchmaker_test.exs` covering:
  - First player queues and waits
  - Second player triggers match
  - Third player stays queued
  - Cancel removes from queue

### 3. Explicit prompt for username before queue
**`lobby_live.ex:131-136`** — Spec says "the system SHALL prompt them to set a username first" when clicking "Ask to play" without a username. Currently the button is simply absent until a username is set.

- Add a `handle_event` that catches "ask_to_play" without a username and shows an error, or revise the spec to match current behavior.

## SUGGESTION (Nice to fix)

### 4. Disable cells based on turn ownership
**`game_live.ex:101`** — `disabled` only checks cell occupancy and game status. A player can click empty cells when it's not their turn (server silently ignores).

- Add `|| @player_mark != @game_state.turn` to the disabled condition.

### 5. Remove redundant `send(:waiting)` in Matchmaker
**`matchmaker.ex:33`** — `send(player_pid, :waiting)` is redundant since `ask_to_play` already returns `:waiting` synchronously. The lobby's `handle_info(:waiting)` handler is dead code for the first player.

- Remove `send(player_pid, :waiting)` on `matchmaker.ex:33`.
- Remove `handle_info(:waiting, ...)` in `lobby_live.ex:74`.
