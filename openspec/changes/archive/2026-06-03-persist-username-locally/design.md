## Context

The username is passed through URL query parameters at every hop. Lobby reads `?username=`, game reads `?n=` and `?o=` as fallbacks, and the redirect back writes `?username=`. This works for single-session navigation but breaks on page refresh, bookmark, or any URL manipulation.

The app already persists the selected theme in `localStorage` via a colocated JS hook that reads before paint and syncs across tabs. This same pattern can be applied to usernames.

## Goals / Non-Goals

**Goals:**
- Username survives page refresh in the lobby
- Username survives browser restart
- Clean URLs with no username query params
- Game page continues to work (names from GameServer state)
- No new external dependencies

**Non-Goals:**
- User accounts or authentication
- Server-side persistence
- Cross-tab username sync (nice-to-have, not required)

## Decisions

1. **localStorage over Phoenix session** — The session cookie can't be written from a WebSocket-connected LiveView without a full HTTP round-trip. localStorage is writeable from JS at any time, matches the existing theme pattern, and is simpler.

2. **Colocated JS hook in LobbyLive** — Following the exact pattern used by the existing theme system. A `<script type={Phoenix.LiveView.ColocatedHook}>` reads the username from localStorage on mount and writes it back whenever the user sets/changes their name.

3. **Before-paint read in root.html.heex** — Like the theme, a small inline `<script>` reads `localStorage.getItem("tris_username")` and stores it on `window` before the LiveView mounts. The mount callback reads it from `window.__username`. This eliminates the flash of the username form before the LiveView initializes.

4. **GameServer state remains the primary source for game page names** — The game page already prefers `game_state.names[player_mark]` over `params["n"]`. Removing the `?n=` fallback is safe because the name is set at game creation and never changes.

5. **Remove `?username=` from redirect URLs** — The lobby no longer reads from URL params, so writing `?username=` on the way back is unnecessary. The redirect just goes to `/`.

## Risks / Trade-offs

- **localStorage cleared** — If the user clears browser data, the username is lost. This is identical to losing a cookie. Acceptable.
- **No username on first visit** — First-time visitors still see the username form (same as today). No regression.
- **Existing bookmarks with `?username=`** — Users who have bookmarked `/ ?username=Alice` will still see the form on first load, then set their name. The `?username=` param will be silently ignored. No breakage.
- **Tab sync** — Not implemented initially. If a user changes their name in one tab, other tabs won't see it unless they refresh. This is the same behavior as the current URL-based approach. A follow-up could use `storage` events like the theme system does.
