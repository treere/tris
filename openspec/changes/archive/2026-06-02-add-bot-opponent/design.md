## Context

Tris is a real-time multiplayer Tic-Tac-Toe game built with Phoenix LiveView. Games are managed by `Tris.GameServer` (GenServer, one per game), players are matched via `Tris.Matchmaker` (GenServer queue), and the UI is handled by `TrisWeb.LobbyLive` and `TrisWeb.GameLive`. Currently only human-vs-human play is supported — both players must be in the matchmaking queue.

There is no database; all state lives in process memory. Communication between processes uses `Phoenix.PubSub` on `game:<id>` topics.

## Goals / Non-Goals

**Goals:**
- Allow a player to start a game against a bot opponent directly from the lobby
- Provide two difficulty levels: Easy (random moves) and Hard (unbeatable minimax)
- Bot responds automatically after a short delay simulating thinking
- Bot uses the same `make_move` interface as human players
- No changes to game rules, win detection, or turn mechanics

**Non-Goals:**
- No persistent bot state or learning
- No networked/remote bot play
- No bot-vs-bot spectator mode
- No changes to how human-vs-human matchmaking works

## Decisions

### 1. Bot AI as a pure module (no GenServer)

`Tris.BotPlayer` is a stateless module exposing `move/2` that takes a board map and difficulty atom and returns `{row, col}`. No supervision tree entry needed.

**Why**: The bot has no mutable state and no lifecycle. A pure function is simpler to test, compose, and reason about than a GenServer.

**Alternatives considered**: Bot GenServer subscribed to PubSub — more complex, no benefit for a synchronous turn-based game.

### 2. Bot moves scheduled via `Process.send_after` inside GameServer

After a human makes a move and the game is not over, `GameServer` checks if the next player is a bot (`players[ next_turn ] == :bot`). If yes, it sends itself a `:bot_move` message after a configurable delay (800ms). The `:bot_move` handler calls `BotPlayer.move/2` and executes the move through the normal `make_move` path.

**Why**: Keeps game flow synchronous and atomic within the GameServer process. The bot move is indistinguishable from a human move from the game logic perspective. No extra processes, no race conditions, no PubSub indirection.

**Alternatives considered**: Separate BotSupervisor process subscribed to PubSub — race condition risk (bot could move before UI updates), extra complexity. Task-based — unnecessary for synchronous computation.

### 3. Bot represented as `:bot` atom in player maps

GameServer's `players` map uses `:bot` (not a pid) for the bot player slot. The `register_player` flow is unchanged for human players. A new `:bot_player?` flag in GameServer state distinguishes bot games.

**Why**: Avoids inventing dummy pids or special-casing pid checks throughout. The only check in make_move becomes `state.players[state.turn] != player_pid and not is_bot_game?` (the bot's moves come from the internal `:bot_move` message, not external calls).

### 4. Matchmaker gains `play_with_bot/2`

New function in `Tris.Matchmaker`: `play_with_bot(player_pid, player_name, difficulty)` starts a game immediately with a bot opponent. Returns `{:ok, game_id, mark, my_name}`.

**Why**: Keeps game creation logic centralized. Reuses GameSupervisor's `start_game` with `:bot` as the second player pid. No queue interaction needed.

### 5. Difficulty selector in lobby

Two buttons in LobbyLive: "Play with Bot (Easy)" and "Play with Bot (Hard)". The chosen difficulty is passed to `Matchmaker.play_with_bot/3`.

### 6. GameServer initialization with bot flag

New function `start_bot_game/5` on GameSupervisor accepts `player_pid, player_name, difficulty`. GameServer init sets `players: %{x: player_pid, o: :bot}` and `bot_difficulty: difficulty`.

## Risks / Trade-offs

- **Bot moves in GenServer**: If `BotPlayer.move/2` becomes slow (unlikely for minimax on 3x3), it blocks GameServer's message queue. → Mitigation: minimax on 3x3 is trivial (~9! = 362k states worst case, <1ms).
- **Delay is per-GameServer**: The `Process.send_after` only fires once per bot turn. If the GameServer crashes before the timer fires, the bot never moves. → Mitigation: the human player sees the game in a stuck state and can leave via the lobby. Acceptable for a simple game.
- **No bot cancellation**: If a human plays a bot and leaves, the bot game stays in memory until the GameServer exits normally. → Acceptable; orphaned games are reclaimed on server restart.
