## 1. BotPlayer Module

- [x] 1.1 Create `Tris.BotPlayer` module with `move/2` function accepting board and difficulty
- [x] 1.2 Implement random strategy (`:easy`): select a random empty cell
- [x] 1.3 Implement minimax strategy (`:hard`): unbeatable optimal move selection

## 2. GameServer Changes

- [x] 2.1 Add `:bot` flag support in GameServer state (`players`, `bot_difficulty`)
- [x] 2.2 Add `start_link` args to accept bot configuration
- [x] 2.3 Modify `make_move` to handle bot-in-progress games (skip player_pid check for internal bot calls)
- [x] 2.4 Add `:bot_move` handle_info to execute bot moves via `BotPlayer.move/2`
- [x] 2.5 Schedule bot move with `Process.send_after` after human move (800ms delay)

## 3. GameSupervisor Changes

- [x] 3.1 Add `start_bot_game/4` function accepting player_pid, player_name, difficulty

## 4. Matchmaker Changes

- [x] 4.1 Add `play_with_bot/3` function that creates a game via GameSupervisor and returns game info

## 5. LobbyLive Changes

- [x] 5.1 Add "Play with Bot (Easy)" and "Play with Bot (Hard)" buttons in the lobby
- [x] 5.2 Add `handle_event("play_with_bot", ...)` to call Matchmaker and navigate to game

## 6. GameLive Changes

- [x] 6.1 Display "Bot (Easy)" or "Bot (Hard)" as opponent name for bot games
- [x] 6.2 Show "Waiting for Bot..." during bot's turn

## 7. Tests

- [x] 7.1 Unit tests for `Tris.BotPlayer` (random and minimax strategies)
- [x] 7.2 Unit tests for GameServer bot integration (bot makes move, delay, game over detection)
- [x] 7.3 Integration tests for LobbyLive bot buttons and navigation
- [x] 7.4 Integration tests for GameLive bot display and flow
