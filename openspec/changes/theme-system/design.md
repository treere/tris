## Context

The app currently defines two daisyUI themes (light, dark) in `app.css` and a 3-position toggle (system/light/dark) in `layouts.ex` that is not wired into any page. Theme state is managed entirely client-side via `localStorage` and an inline script in `root.html.heex`. The toggle dispatches a `phx:set-theme` DOM event that the script catches to apply the `data-theme` attribute on `<html>`.

The goal is to expand this into a proper theme system with multiple curated palettes and a visible selector UI.

## Goals / Non-Goals

**Goals:**
- Provide 4–6 curated daisyUI themes (color palettes) users can choose from
- Replace `theme_toggle/1` with a theme selector component (dropdown or palette grid)
- Persist the user's choice to `localStorage` and apply it before paint (matching the existing pattern)
- Place the theme selector in the app layout so it's accessible from every page
- Keep all theme logic client-side (no LiveView state needed for theme management)

**Non-Goals:**
- No per-user server-side theme persistence (no DB, no accounts)
- No real-time theme sync across LiveView sockets (themes are cosmetic only, not game state)
- No custom theme builder or user-created themes
- No animation/transition system for theme changes

## Decisions

1. **Theme definition approach**: Use the existing `@plugin "../vendor/daisyui-theme"` pattern in `app.css` for all new themes. Each theme gets its own `@plugin` block with a unique `name`. This keeps things consistent with the existing code and leverages daisyUI's built-in theme switching via `data-theme`.

2. **Theme names**: Use descriptive, evocative names like `"phoenix"` (existing light), `"elixir"` (existing dark), `"forest"`, `"ocean"`, `"sunset"`, `"midnight"`. The `data-theme` attribute will use these names directly. A `default` theme must be marked (keep `phoenix` as default).

3. **Theme selector UI**: Replace the 3-button toggle with a dropdown menu showing theme preview swatches (small colored squares showing the primary and base-100 colors). Below the swatches, add "System" as a persistent option. The dropdown avoids taking too much layout space while allowing easy expansion to more themes.

4. **Client-side theme script**: Update the inline script in `root.html.heex` to handle arbitrary theme names (not just system/light/dark). The mechanism stays the same — `phx:set-theme` DOM event with the theme name in `data-phx-theme`. The localStorage key remains `phx:theme`.

5. **Theme selector placement**: Add the selector to the `app/1` layout function in `layouts.ex`, positioned in the top-right corner of the `<main>` container. This makes it visible from lobby and game pages without being intrusive.

6. **No LiveView involvement**: Theme selection is purely client-side JS. The `<.link>` dispatch approach (`JS.dispatch("phx:set-theme")`) continues to work. No `handle_event` callbacks needed.

7. **Theme palette sources**: Use daisyUI's theme generator (https://daisyui.com/theme-generator/) to generate well-tested, accessible color palettes. Each theme defines the full set of daisyUI CSS variables (`--color-base-100` through `--color-error-content`, plus radius/size/border/depth/noise).

## Risks / Trade-offs

- **Risk**: 4–6 themes increase `app.css` size. **Mitigation**: Each theme block is ~20 lines; 6 themes add ~120 lines. Negligible for a CSS file.
- **Trade-off**: Client-side only means no theme sync across tabs automatically (window-level storage event is already handled). Multi-tab sync is already implemented via the `storage` event listener.
- **Risk**: Theme names could collide with future daisyUI built-in theme names. **Mitigation**: Use unique, app-specific theme names.
- **Risk**: Users might not notice the theme selector in the top-right corner. **Mitigation**: Use a subtle pulsing indicator or tooltip on first visit (via localStorage flag "first visit").
