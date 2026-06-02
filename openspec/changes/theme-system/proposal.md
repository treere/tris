## Why

The app currently has only two themes (light/dark) with a system-following toggle, but the toggle is not even exposed to users. Players spend significant time in the lobby and game views — a selection of curated visual themes would let them personalize their experience and make the app feel more polished and engaging.

## What Changes

- Introduce a set of curated color themes (beyond just light/dark) that users can choose from
- Add a theme selector UI in the lobby and/or as a persistent UI element
- Persist theme preference to `localStorage` (matching existing pattern)
- Expose the existing theme toggle and expand it into a full theme picker
- Define each theme as a full daisyUI color palette in `app.css`

## Capabilities

### New Capabilities
- `theme-selector`: A UI component that lets users browse and select from a set of curated themes, replacing the current hidden theme toggle
- `theme-definitions`: A collection of curated daisyUI theme palettes (color schemes) defined in CSS

### Modified Capabilities
<!-- No existing specs to modify -->

## Impact

- `assets/css/app.css` — Add new daisyUI theme definitions (multiple color palettes)
- `lib/tris_web/components/layouts.ex` — Replace `theme_toggle/1` with a richer theme selector component
- `lib/tris_web/components/layouts/root.html.heex` — Update inline theme script to handle multiple themes
- `lib/tris_web/live/lobby_live.ex` — Integrate theme selector into lobby UI
- No database changes, no new dependencies, no new routes
