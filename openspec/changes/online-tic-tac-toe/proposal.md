## Why

Build a real-time multiplayer Tic-Tac-Toe game where users can set a username, request to play, and get matched with another waiting player. This provides a foundation for learning and demonstrating Elixir LiveView and Phoenix PubSub capabilities.

## What Changes

- Add user identity with configurable username
- Add matchmaking system: "ask to play" queues a player, pairs with another queued player
- Add real-time game board with LiveView updates
- Add win/tie detection and game state management
- Build all as a Phoenix LiveView application

## Capabilities

### New Capabilities
- `user-identity`: Username selection and session management
- `matchmaking`: Player queueing and pairing system
- `game-play`: Real-time Tic-Tac-Toe game board, turns, and win/tie detection

### Modified Capabilities

*None*

## Impact

New Phoenix LiveView application with:
- Phoenix web server with LiveView
- Ecto or Agent-based in-memory state for matchmaking queue and game sessions
- PubSub for real-time game updates
- No database required initially (in-memory state is sufficient)
