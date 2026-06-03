## Context

Currently, when a user navigates to `/game/<id>` where `<id>` doesn't correspond to an active game, `GameServer.get_state/1` attempts a `GenServer.call` to a non-existent process via Registry. This raises an exit (`:noproc`) which propagates up as a 500 error / crash, resulting in a poor user experience.

The app has no database — games exist only as in-memory GenServer processes. A game ID is valid only if a process is registered under that ID in `Tris.GameRegistry`.

## Goals / Non-Goals

**Goals:**
- Show a "Game not found" page when the game ID doesn't match any active game
- Auto-redirect to the lobby after 5 seconds
- Reuse existing patterns (`:redirect_to_lobby`, `Process.send_after`)

**Non-Goals:**
- Adding a new route or error controller
- Persisting game data or adding a database
- Handling other 404-type errors beyond missing game IDs

## Decisions

1. **Registry check before GenServer call** — Use `Registry.lookup(Tris.GameRegistry, game_id)` in `handle_params` to check if the game exists before calling `GameServer.get_state/1`. If not found, set `@game_not_found` to `true` and skip all game-specific assigns. This avoids relying on exceptions for control flow and is consistent with how existing code uses `GameRegistry`.

2. **New `@game_not_found` boolean assign** — When `true`, the template renders a simple fallback message ("Game not found") and a note that the user will be redirected. When `false`, the existing game board renders normally. This keeps the change minimal — no new LiveView or route needed.

3. **Redirect via existing `:redirect_to_lobby` message** — `Process.send_after(self(), :redirect_to_lobby, 5000)` schedules the redirect, matching the existing post-game flow. The username query param is still passed so the user returns to the lobby with their name intact.

4. **No changes to GameServer module** — The detection is entirely in the LiveView layer. GameServer is not concerned with 404 handling.

## Risks / Trade-offs

- **Race condition** — A game could be created between the Registry check and the page rendering, but this is harmless: the user would see "Game not found" briefly, then be redirected. If timing matters, they can navigate back. This is an edge case with negligible impact.
- **No distinct URL** — The "/game/:id" URL stays the same, just the content differs. The user will see the game ID in the URL while on the not-found page, which could be confusing, but since we auto-redirect after 5s it's acceptable.
- **Registry.Lookup vs try/rescue** — Registry lookup was chosen over try/rescue for clarity: it's explicit about intent, doesn't use exceptions for flow, and is O(1).
