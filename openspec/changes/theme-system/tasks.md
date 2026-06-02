## 1. Define New Themes in CSS

- [ ] 1.1 Add 2–4 new daisyUI theme palettes in `app.css` using `@plugin "../vendor/daisyui-theme"` blocks (e.g., "forest", "ocean", "sunset", "midnight")
- [ ] 1.2 Rename existing `"light"` theme to `"phoenix"` and existing `"dark"` theme to `"elixir"`
- [ ] 1.3 Set `"phoenix"` as the default theme (`default: true`) and `"elixir"` as the dark system preference (`prefersdark: true`)

## 2. Update Client-Side Theme Script

- [ ] 2.1 Update the inline script in `root.html.heex` to handle arbitrary theme names (remove hardcoded system/light/dark logic, store the raw theme name instead)
- [ ] 2.2 Ensure the script applies theme before paint and syncs across tabs via the `storage` event listener

## 3. Build Theme Selector Component

- [ ] 3.1 Replace `theme_toggle/1` in `layouts.ex` with a `theme_selector/1` component that renders a dropdown button with theme swatches
- [ ] 3.2 Add a "System" option at the bottom of the dropdown that follows OS preference
- [ ] 3.3 Wire each theme option to dispatch `phx:set-theme` with the theme name via `data-phx-theme`

## 4. Integrate Theme Selector into Layout

- [ ] 4.1 Add `theme_selector` call to the `app/1` layout in `layouts.ex`, positioned in the top-right corner of the `<main>` container
- [ ] 4.2 Remove unused `theme_toggle/1` function from `layouts.ex`

## 5. Verify and Polish

- [ ] 5.1 Run `mix compile` to ensure no compilation errors
- [ ] 5.2 Verify all themes render correctly in the browser by cycling through each option
- [ ] 5.3 Verify theme persists across page reloads and syncs across browser tabs
- [ ] 5.4 Verify first-time visitor gets the default theme and system dark mode applies the correct theme
- [ ] 5.5 Run `mix precommit` to fix any linting or formatting issues
