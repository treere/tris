## Why

Currently Tris has no turn time limit, allowing players to stall indefinitely. Adding a 30-second per-turn timer creates urgency, prevents griefing, and makes the game more engaging.

## What Changes

- A 30-second countdown timer starts when it becomes a player's turn
- The timer is displayed prominently in the UI, counting down from 30
- If the timer reaches 0, the player forfeits and the opponent wins
- Timer pauses when the game ends (win/tie)
- For bot opponents, no timer is shown (bot moves instantly via internal delay)

## Capabilities

### New Capabilities
- `turn-timer`: Per-turn countdown timer with visual display and auto-forfeit on timeout

### Modified Capabilities

- *None*

## Impact

- `Tris.GameServer` — add timer state (`timer_ref`, `turn_started_at`) and timeout handler
- `TrisWeb.GameLive` — display countdown UI, synchronize timer from server
- New spec file: `openspec/specs/turn-timer/spec.md`
