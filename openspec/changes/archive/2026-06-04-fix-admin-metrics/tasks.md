## 1. Matchmaker public API

- [x] 1.1 Add `queue_length/0` public function to `Tris.Matchmaker`
- [x] 1.2 Handle `:queue_length` call in `handle_call/3`

## 2. Fix resign crash path in GameServer

- [x] 2.1 Replace unsafe `Enum.find` destructure with a `case` that handles `nil`
- [x] 2.2 Return `{:error, :player_not_found}` when PID doesn't match any player

## 3. Fix metric computation in AdminLive

- [x] 3.1 Fix `total_users` formula to `lobby_users + in_game_users`
- [x] 3.2 Fix bot/human filtering to use `players` map (`:bot` PID check) instead of string matching on names
- [x] 3.3 Filter active games count and games list to only include `status: :playing`
- [x] 3.4 Replace `:sys.get_state(Tris.Matchmaker)` with `Tris.Matchmaker.queue_length/0`

## 4. Write tests

- [x] 4.1 Write test for metric accuracy with 0 activity (empty state)
- [x] 4.2 Write test verifying `total_users` does not double-count queued users (lobby + queue overlap)
- [x] 4.3 Write test verifying bot names are not counted as in-game users
- [x] 4.4 Write test verifying correct game type breakdown (human vs bot, difficulty split)
- [x] 4.5 Write test verifying finished games are not counted as active
- [x] 4.6 Write test verifying resign with unrecognized PID returns error (doesn't crash)

## 5. Verify

- [x] 5.1 Run `mix precommit` and fix any issues
