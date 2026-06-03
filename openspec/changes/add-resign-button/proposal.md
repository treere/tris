## Why

There is currently no way for a player to gracefully end a game early. The only options are waiting for the turn timer to expire, disconnecting (closing the browser tab), or playing to completion. A resign button is a standard game feature that gives players an exit when the outcome is clear, improving the overall experience.

## What Changes

- Add a "Resign" button to the game page, always visible during active gameplay regardless of whose turn it is
- Clicking the button opens a confirmation modal asking "Do you want to resign?"
- Confirming the modal sends a resign action to the game server, which marks the player as resigned and awards the win to the opponent
- The result is displayed to both players via the existing game-over UI
- The resigning player forfeits; the opponent wins regardless of board state

## Capabilities

### New Capabilities
- `resign`: The resign action — server-side handling of resignation (validation, state change, broadcast) and client-side UI (button, confirmation modal, result display)

### Modified Capabilities

(none)

## Impact

- `lib/tris/game_server.ex` — New `:resign` public API function and `handle_call` clause; new `:resigned` status handling; broadcast updated state
- `lib/tris_web/live/game_live.ex` — New `"resign"` event handler; update result display logic to handle resignation messages
- `lib/tris_web/live/game_live.ex` (render) — Add Resign button and confirmation modal overlay in the template
- No new dependencies; no API changes
