## Context

Tris is an in-memory Phoenix LiveView game with no database. Real-time communication uses `Phoenix.PubSub` on game-scoped topics (`"game:#{game_id}"`). Game state lives in `Tris.GameServer` GenServers. The game LiveView (`TrisWeb.GameLive`) subscribes to PubSub on mount and handles `{:game_update, state}` messages. Human-vs-human is distinguished by `bot_difficulty == nil`.

Chat must be ephemeral (discarded when the game process terminates), real-time, and only available in human-vs-human matches.

## Goals / Non-Goals

**Goals:**
- Allow two human players to exchange text messages during an active match
- Messages appear instantly on both clients via PubSub
- Chat UI is rendered only in human-vs-human games
- Chat history is stored in the GameServer process state (lost when process dies)
- Messages include the sender's display name and timestamp

**Non-Goals:**
- No persistence, no logging, no database
- No chat for bot games (no AI to talk to)
- No message editing or deletion
- No rate limiting (acceptable for in-memory game with 2 players)
- No chat history surviving past the game session

## Decisions

1. **Store chat in GameServer state** — A new `:chat_messages` field holds a list of `%{sender: name, text: text, timestamp: DateTime.t()}` maps. The GameServer exposes a `send_message/3` public function. This keeps chat as ephemeral as the game itself.

2. **Broadcast chat via PubSub on existing game topic** — Use the same `"game:#{game_id}"` topic but with a dedicated `{:chat_message, message}` tag, separate from `{:game_update, state}`. This avoids sending the full game state on every chat message and lets the LiveView handle chat independently.

3. **Separate LiveView event for sending** — A `"send_chat"` event in GameLive calls `GameServer.send_message/3`. On the receiving end, `handle_info({:chat_message, msg}, socket)` appends to a `@chat_messages` assign (a list).

4. **Conditional render with `@is_bot_game`** — The existing `@is_bot_game` assign (set in `handle_params`) already indicates human-vs-human vs bot. Chat UI renders only when `@is_bot_game == false`. No additional flag needed.

5. **No new dependencies** — All infrastructure (PubSub, GenServer, LiveView) is already in place.

## Risks / Trade-offs

- [Chat messages accumulate in memory] → Acceptable: games are short (max 9 turns), each message is small. Process dies after game ends.
- [No rate limiting] → Acceptable for 2-player games; malicious behavior unlikely in current anonymous context.
- [No scroll-to-bottom behaviour] → Acceptable for MVP; chat is short-lived and low volume.
