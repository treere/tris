## 1. localStorage Read at Page Load

- [x] 1.1 Add a colocated JS hook in `lobby_live.ex` that reads `localStorage.getItem("tris_username")` and pushes it to the LiveView via `this.pushEvent("restore_username", {username})`
- [x] 1.2 Add a `handle_event("restore_username", ...)` in LobbyLive that sets `@username` and hides the form when a stored username is found
- [x] 1.3 Optionally add a before-paint inline script in `root.html.heex` (like the theme) to prevent form flash
- [x] 2.1 In `handle_event("set_username", ...)` in LobbyLive, after assigning the username, push an event to the client via `push_event(socket, "save_username", %{username: username})`
- [x] 2.2 Update the colocated JS hook to handle the `"save_username"` event and write to `localStorage.setItem("tris_username", username)`
- [x] 3.1 In `lobby_live.ex`, remove `?n=#{my_name}&o=#{opponent_name}` from the `push_navigate` calls in `ask_to_play`, `play_with_bot`, and the `{:matched, ...}` handler
- [x] 3.2 In `lobby_live.ex`, also remove `?username=` from the mount clause that reads it
- [x] 4.1 In `game_live.ex`, remove the `params["n"]` and `params["o"]` fallback logic — the name is always read from `game_state.names[]`
- [x] 4.2 In `game_live.ex`, change `:redirect_to_lobby` and `return_to_lobby` to navigate to `"/"` instead of `"/?username=..."`
- [x] 5.1 Add test for lobby restoring username from localStorage (via hook event)
- [x] 5.2 Add test for game page rendering player names from server state without URL params
- [x] 5.3 Update existing tests that relied on `?n=`, `?o=`, or `?username=` URL params
