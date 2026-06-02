## Why

After a game ends (win/loss/tie), players must manually click "Return to lobby" to play again. There's also no way to change your username without reloading the page. Both friction points slow down the play cycle and hurt the casual pick-up-and-play experience.

## What Changes

- Game automatically redirects to lobby after a short delay when the game ends
- Lobby shows a "Change name" option that lets the player go back to the username form
- "Change name" is accessible from the lobby's game selection screen without navigating away

## Capabilities

### New Capabilities
- `post-game-redirect`: Game over screen auto-navigates to lobby after a brief delay, and the "Return to lobby" button remains for instant return
- `name-change`: Allow the player to change their username from the lobby's game selection view

### Modified Capabilities

<!-- No existing capabilities are modified -->

## Impact

- `lib/tris_web/live/game_live.ex` — Add auto-redirect logic after game ends
- `lib/tris_web/live/lobby_live.ex` — Add "Change name" button and handler to reset username
- Tests for both LiveViews will be updated
