## Context

Tris is a Phoenix LiveView tic-tac-toe app with no database. State is held in GenServers. Currently when a game ends, players see a result overlay with a "Return to lobby" button. The lobby shows game selection options once a username is set, but there's no way to change the username without reloading.

## Goals / Non-Goals

**Goals:**
- Auto-redirect to lobby after game ends (with configurable delay)
- Keep existing "Return to lobby" button for instant navigation
- Add "Change name" button to the lobby's game selection screen
- Change name resets username and shows the username form again
- Cancel any active matchmaking queue when changing name

**Non-Goals:**
- No rematch/play-again feature (starts a completely new game)
- No game history or stats
- No username persistence across page reloads

## Decisions

1. **Auto-redirect via `Process.send_after`** — After setting the `@result` assign, schedule a `:redirect_to_lobby` message. When it arrives, `push_navigate` to `/`. Alternative: JS `setTimeout` — rejected because it mixes concerns; LiveView timers keep logic in Elixir.

2. **Keep "Return to lobby" button** — The auto-redirect is a convenience. The button is still useful for impatient players.

3. **"Change name" as a button that resets `@username` and `@show_form`** — Simple toggle. When clicked, go back to the username form. Cancel any active queue to avoid stale matchmaker state.

4. **Cancel queue on name change** — If the player is waiting in the queue and changes name, the old name in the queue would be stale. Cancel first, then show the form.

## Risks / Trade-offs

- **Auto-redirect timing**: Too fast and the player misses the result. 5 seconds feels right — long enough to see the result, short enough to avoid impatience. → Add a visible countdown or "Redirecting..." text so players know what's happening.
- **Name change mid-queue**: Cancel clears the player from the queue. If they were about to be matched, they miss it. → Acceptable trade-off; they chose to change their name.
