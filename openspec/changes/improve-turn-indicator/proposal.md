## Why

The current turn indicator uses subtle background color changes that don't clearly communicate whose turn it is, especially in fast-paced play. Players have to visually parse both names to determine their turn status, which is not immediately obvious. This creates friction and reduces the game's polish.

## What Changes

- Replace the passive turn indicator with explicit "Your turn" / "Waiting for opponent..." messaging
- Add a visual arrow/pulse indicator that points to the current player
- Disable the game board cells when it's not the player's turn, with a subtle visual cue
- Add smooth transitions when the turn changes
- Differentiate "you" from "opponent" with labels instead of relying on mark (X/O) alone

## Capabilities

### New Capabilities
- `turn-indicator`: Explicit, visually unambiguous turn indicator showing whose turn it is with labels, animations, and board interaction states

### Modified Capabilities

- None (no existing specs to modify)

## Impact

- `lib/tris_web/live/game_live.ex`: Major template changes to turn indicator section, board cell disabled states, and added assigns for turn status
- `assets/css/app.css`: New CSS animations and turn indicator styles
- No server-side changes needed (game logic already tracks turns correctly)
