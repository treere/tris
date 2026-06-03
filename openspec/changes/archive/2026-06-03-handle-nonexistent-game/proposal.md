## Why

Navigating to a non-existent game page (e.g., `/game/invalid-id`) crashes the LiveView with an unhandled GenServer exit, causing a blank error page or disconnection. Instead, the user should see a friendly "Game not found" message with an automatic redirect back to the lobby.

## What Changes

- Gracefully detect when a game does not exist in `GameServer` lookups
- Render a "Game not found" page in place of the game board when the game ID is invalid
- Auto-redirect to the lobby after 5 seconds (matching the existing post-game redirect behavior)

## Capabilities

### New Capabilities
- `nonexistent-game`: Graceful handling of missing game IDs — detection in `GameLive`, fallback UI, and timed redirect to lobby

### Modified Capabilities

(none)

## Impact

- `lib/tris_web/live/game_live.ex` — `handle_params/3` needs to catch missing game, render fallback UI instead of board; new `:game_not_found` state; timer-based redirect
- No changes to `GameServer` — detection is at the LiveView layer via Registry/GenServer failure
- No new dependencies
