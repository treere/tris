## Why

Tic-tac-toe is more engaging when human opponents can interact during the match. Currently, two human players are siloed — they see the board update but have no way to communicate. Adding a lightweight, ephemeral chat lets them exchange messages (banter, strategy, GG) in real time, making the experience feel social and alive.

## What Changes

- Add a chat panel to the game LiveView, visible only during human-vs-human matches
- Players send messages via a text input; messages are broadcast through PubSub on the game topic
- Chat history lives in the GameServer's in-memory state and is discarded when the game process terminates
- No persistence, no logging, no database — messages are purely ephemeral

## Capabilities

### New Capabilities
- `in-game-chat`: Real-time messaging between human players during an active match, scoped to the game session

### Modified Capabilities
*(none — no existing spec changes)*

## Impact

- `Tris.GameServer`: New state field for chat messages; new `send_chat_message/3` public function; broadcast chat updates via PubSub
- `TrisWeb.GameLive`: New chat UI panel; handle chat-related PubSub messages; conditionally render only for human-vs-human games
- No new dependencies, no database changes, no route changes
