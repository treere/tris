## Why

Tris currently only supports player-vs-player matches via the matchmaking queue. Adding a bot opponent enables solo practice, faster gameplay, and a better onboarding experience without requiring another human player to be online.

## What Changes

- Add a `Tris.BotPlayer` module that plays moves automatically with configurable difficulty levels (random and unbeatable/minimax)
- Add a "Play with a bot" button in the lobby alongside the existing "Ask to play" button
- Skip matchmaking when playing against a bot — the game starts immediately with the bot as the second player
- Bot makes moves after a short configurable delay to simulate thinking
- Extend `GameServer` registration to support bot players (no PID needed for the bot)
- Add difficulty selection UI in the lobby (Easy / Hard)
- No changes to the core game flow — the bot participates as a regular player via the same `make_move` interface

## Capabilities

### New Capabilities
- `bot-opponent`: Ability to start a game against a computer-controlled opponent with selectable difficulty

### Modified Capabilities
- (none — existing spec behavior is unchanged)

## Impact

- **New module**: `Tris.BotPlayer` — bot AI logic (random and minimax strategies)
- **Modified**: `Tris.Matchmaker` — add `play_with_bot/2` function that starts a game directly with a bot opponent
- **Modified**: `TrisWeb.LobbyLive` — add "Play with a bot" button, difficulty selector, bot game flow
- **Modified**: `Tris.GameServer` — support bot registration (no PID needed for bot)
- **Modified**: `Tris.GameSupervisor` — expose `start_bot_game/1` if needed
- **Tests**: New `Tris.BotPlayer` unit tests, updated lobby and game LiveView tests
