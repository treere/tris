## 1. Auto-redirect after game ends

- [x] 1.1 In `GameLive.handle_info({:game_update, ...})`, schedule a `Process.send_after(self(), :redirect_to_lobby, 5000)` when the result transitions from `nil` to a non-nil value
- [x] 1.2 Add `handle_info(:redirect_to_lobby, socket)` that calls `push_navigate(socket, to: ~p"/")`
- [x] 1.3 Update the result overlay template to show "Redirecting to lobby..." beneath the "Return to lobby" button

## 2. Change name from lobby

- [x] 2.1 Add `handle_event("change_name", ...)` in `LobbyLive` that resets `@username` to `nil`, sets `@show_form` to `true`, calls `Matchmaker.cancel/1` if queue is active, and resets `@queue_status` to `nil`
- [x] 2.2 Add a "Change name" button in the lobby template alongside the welcome message in the game selection area

## 3. Tests

- [x] 3.1 Test auto-redirect: verify redirect message is sent after game ends
- [x] 3.2 Test "Change name" button exists and resets to username form
