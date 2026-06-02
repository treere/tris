# TODO

## WARNING (Should fix)

### 1. Add more GameLive tests
**Incomplete coverage for `game_live.ex`** — board rendering, cell click handling, winning highlights, `register_player` integration, and PubSub subscription are still untested at the LiveView layer.

Result display and return-to-lobby navigation are now covered (`game_live_test.exs:75-119`).

- Add tests for:
  - Board renders at game start
  - Cell clicks send moves
  - Winning cells highlighted
  - `register_player` integration

### 2. Add Matchmaker tests
**No direct test coverage for `matchmaker.ex`** — pairing logic, queue management, 3+-player scenario, and cancel flow are untested.

- Add `test/tris/matchmaker_test.exs` covering:
  - First player queues and waits
  - Second player triggers match
  - Third player stays queued
  - Cancel removes from queue

### 3. Explicit prompt for username before queue
**`lobby_live.ex`** — Spec says "the system SHALL prompt them to set a username first" when clicking "Ask to play" without a username. Currently the button is simply absent until a username is set.

- Add a `handle_event` that catches "ask_to_play" without a username and shows an error, or revise the spec to match current behavior.

## SUGGESTION (Nice to fix)

### 4. Disable cells based on turn ownership
**`game_live.ex:155`** — `disabled` only checks cell occupancy and game status. A player can click empty cells when it's not their turn (server silently ignores).

- Add `|| @player_mark != @game_state.turn` to the disabled condition.

### 5. Remove redundant `send(:waiting)` in Matchmaker
**`matchmaker.ex:37`** — `send(player_pid, :waiting)` is redundant since `ask_to_play` already returns `:waiting` synchronously. The lobby's `handle_info(:waiting)` handler is dead code for the first player.

- Remove `send(player_pid, :waiting)` on `matchmaker.ex:37`.
- Remove `handle_info(:waiting, ...)` in `lobby_live.ex:109`.

## Completed

### post-game-flow (June 2026)
- Auto-redirect to lobby 5s after game ends
- "Return to lobby" button preserved for instant navigation
- "Redirecting to lobby..." text shown in result overlay
- Username preserved in query param when navigating Game → Lobby
- "Change name" button in lobby to reset username
- Queue cancelled on name change
