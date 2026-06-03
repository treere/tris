## Context

The game currently has no resign mechanism. When a player wants to concede, they must either wait for the turn timer (30s) to expire (timeout results in a win for the opponent) or close the browser tab (which leaves a stale game process). Adding a deliberate resign action gives players control over ending a game early.

The existing game-over flow already handles win/tie states and broadcasts results via PubSub. The board and chat UI have clear separation between active and ended games. The confirm modal pattern is new to this codebase — no existing modals exist.

## Goals / Non-Goals

**Goals:**
- Allow a player to resign at any time during an active game (their turn or opponent's turn)
- Show a confirmation modal before executing the resign
- Display the resign result to both players via the existing game-over UI
- Use the existing GameServer GenServer pattern for the resign action

**Non-Goals:**
- Adding a modal framework beyond what's needed for this single action
- Persisting resign data (no database exists)
- Resign confirmation via chat or other indirect mechanism
- Animating/transitioning the modal (simple overlay is sufficient)

## Decisions

1. **Server-side resign as a GenServer `call` (synchronous)** — Consistent with `make_move` and `get_state`. Using `call` ensures the resign is processed atomically before the caller proceeds. A `cast` would work too but `call` matches the existing synchronous pattern and the caller gets a reply.

2. **Resign tracked via new `:resigned` atom alongside `status`** — The game state already has `status: :playing | :won | :tie`. Adding `{:resigned, mark}` as a status variant complicates pattern matching. Instead, resign sets `status: :won`, `winner: opponent_mark`, and introduces a `:resign` value on a new field `resigned_by`. This reuses the existing `:won` render path while distinguishing resignation from timeout/wins in the result message.

3. **Inline confirmation modal via HEEx conditional rendering** — No external modal library. The modal is a simple overlay div toggled by a `@show_resign_modal` boolean assign. This avoids adding dependencies and matches the project's lightweight approach (no JS framework, no daisyUI modals).

4. **Button always visible, regardless of turn** — The user explicitly requested this. The resign button sits outside the turn-dependant UI area, below the chat panel or in a footer area, styled as a secondary/danger action.

5. **Validation handled server-side** — The GameServer validates that the game is still `:playing` before processing the resign. This prevents double-resign or resign-after-game-end race conditions.

## Risks / Trade-offs

- **No undo** — Resign is final. The confirmation modal mitigates accidental clicks.
- **Modal is non-standard in this app** — This is the first modal in the codebase. A simple overlay approach is intentional: it avoids a modal framework dependency while being sufficient for this single use case. If more modals are added later, a shared component should be extracted.
- **Bot games** — Resign works identically for human vs bot games. The bot does not (and should not) resign.
- **Stale game processes** — A resigned game remains in the GameSupervisor until the server restarts. This is consistent with all other game-end states (win, tie, timeout) and is not a new risk.
