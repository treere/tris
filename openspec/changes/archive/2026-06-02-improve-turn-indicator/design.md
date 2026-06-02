## Context

The game is a two-player Tic-Tac-Toe (Tris) built with Phoenix LiveView. Turn state is managed server-side in `Tris.GameServer` as the `turn` field (`:x` or `:o`), broadcast via PubSub. The current UI shows two player name pills with the active player highlighted via `bg-primary` class — no explicit messaging, no disabled board state, no animations.

## Goals / Non-Goals

**Goals:**
- Make it immediately obvious whose turn it is at a glance
- Clearly label "You" vs "Opponent" so the player doesn't have to remember their mark
- Disable board interaction when it's not the player's turn with a dimmed overlay
- Animated transition when turn switches (pulse on active player indicator)
- All changes client-side only (no GenServer or state changes)

**Non-Goals:**
- Changing the game server logic or state structure
- Adding sound effects or haptic feedback
- Adding a turn timer
- Spectator mode or multi-player beyond 2 players

## Decisions

1. **Client-only implementation** — Since `@game_state.turn` is already available in assigns. We derive `is_my_turn?` in the LiveView based on `@game_state.turn == @player_mark` and assign it explicitly. No server changes needed.

2. **Label-based indicator** — Instead of just highlighting the active pill, we'll show:
   - Active player: prominent "Your turn" badge with a pulsing dot
   - Inactive player: "Waiting..." text with muted styles
   - The player's own name always shows "You (X)" instead of their raw name, making it personally recognizable

3. **Board disabled state** — When `is_my_turn?` is false, board cells get `opacity-50 pointer-events-none` plus a subtle overlay message. This prevents accidental clicks and makes the waiting state visually clear.

4. **CSS @keyframes pulse** — Use Tailwind's `animate-pulse` on the active indicator for smooth attention-drawing animation. No JS hooks needed.

5. **Layout change** — Stack the turn indicator vertically (current player on top with indicator, opponent below) rather than side-by-side, so the active/passive distinction is more spatial.

## Risks / Trade-offs

- [Animation performance] → Pulse animation is lightweight (opacity only), already well-supported by Tailwind
- [Board too dim when not your turn] → Use `opacity-50` rather than `opacity-0` so the board is still readable
- [Over-engineering] → All changes are in a single template + CSS, minimal code changes
