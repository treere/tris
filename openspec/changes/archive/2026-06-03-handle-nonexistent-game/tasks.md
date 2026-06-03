## 1. Detection and State

- [x] 1.1 In `handle_params/3` of `TrisWeb.GameLive`, add a `Registry.lookup(Tris.GameRegistry, game_id)` check before calling `GameServer.get_state/1`
- [x] 1.2 When game is not found, set `@game_not_found` to `true`, skip game-specific assigns, and schedule `:redirect_to_lobby` via `Process.send_after(self(), :redirect_to_lobby, 5000)`
- [x] 1.3 When game is found, set `@game_not_found` to `false` and proceed with existing logic

## 2. Fallback UI

- [x] 2.1 In the `render/1` template, when `@game_not_found` is true, display "Game not found" heading, explanatory text, and "Redirecting to lobby..." message instead of the game board

## 3. Redirect Preservation

- [x] 3.1 Ensure the `:redirect_to_lobby` handler preserves the username query param when redirecting from a not-found state

## 4. Tests

- [x] 4.1 Add test for navigating to a nonexistent game: verify "Game not found" text, verify redirect message
- [x] 4.2 Add test ensuring valid games still render normally (no false positive on existing test)
