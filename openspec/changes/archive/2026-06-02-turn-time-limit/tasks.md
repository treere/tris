## 1. GameServer — Add timer state and timeout logic

- [x] 1.1 Add `@turn_timeout 30_000` module attribute and `turn_started_at` / `timer_ref` to state init
- [x] 1.2 Add `start_timer/1` private function that starts `Process.send_after` for the current player (skip if bot)
- [x] 1.3 Add `cancel_timer/1` private function that kills the previous timer ref
- [x] 1.4 Add `handle_info({:turn_timeout, player}, state)` callback that forfeits the current player and broadcasts
- [x] 1.5 Integrate timer start/cancel into `apply_move/4` — cancel old timer, start new one for next turn (skip bot)
- [x] 1.6 Add `turn_started_at` to the state map broadcast so LiveView can compute remaining time

## 2. GameLive — Add countdown display and server synchronization

- [x] 2.1 Add `:timer_tick` `handle_info/2` that fires every second and computes remaining time from `turn_started_at`
- [x] 2.2 Compute `remaining_seconds` assign on mount and on `:game_update` — derive from `turn_started_at` + `@turn_timeout`
- [x] 2.3 Display the countdown number in the turn indicator area (only for human turns)
- [x] 2.4 Add amber urgency styling when ≤10s remaining, red pulsing styling when ≤5s remaining
- [x] 2.5 Stop timer tick on game end (when result is set)
- [x] 2.6 Show "X ran out of time!" message in result for timeout losses

## 3. Tests

- [x] 3.1 Unit test: GameServer forfeits player on timeout
- [x] 3.2 Unit test: Timer does not start for bot turns
- [x] 3.3 Unit test: Timer is cancelled when a move is made before timeout
- [x] 3.4 LiveView test: Timer countdown display renders for active player
- [x] 3.5 LiveView test: Timeout result message is shown
