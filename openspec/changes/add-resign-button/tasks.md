## 1. Server-Side: GameServer Resign Handling

- [x] 1.1 Add `resign/2` public function to `Tris.GameServer` (takes `game_id` and `player_pid`)
- [x] 1.2 Add `handle_call({:resign, player_pid}, ...)` that validates game is `:playing`, cancels the timer, sets `status: :won`, sets `winner` to the opponent, records `resigned_by`, and broadcasts the update via PubSub
- [x] 1.3 Add `resigned_by` field to the default state map in `init/1` (default `nil`)

## 2. Client-Side: GameLive Resign Event

- [x] 2.1 Add `handle_event("resign", _, socket)` in `TrisWeb.GameLive` that calls `GameServer.resign/2` with the player's PID and toggles `@show_resign_modal` to false

## 3. Client-Side: GameLive Result Display

- [x] 3.1 Update `handle_info({:game_update, ...})` to check `game_state.resigned_by` and set result message to `"#{resignee_name} resigned!"` when present

## 4. Client-Side: Resign Button and Confirmation Modal

- [x] 4.1 Add a "Resign" button to the game template, visible when `@game_state.status == :playing`, positioned below the board/chat area
- [x] 4.2 Add `@show_resign_modal` assign (default `false`) and wire it to a `phx-click="resign"` on the button
- [x] 4.3 Create a confirmation modal overlay (absolute/fixed positioned `<div>`) with "Are you sure you want to resign?" text, a "Confirm, resign" button (triggers the actual resign via server event), and a "Cancel" button (sets `@show_resign_modal` to false)
- [x] 4.4 Style the resign button as a subtle/danger action (e.g., `btn-outline btn-error btn-sm`) and the modal with a centered overlay + card

## 5. Tests

- [x] 5.1 Add `describe "resign/2"` tests in `test/tris/game_server_test.exs`: resign on own turn, resign on opponent's turn, reject resign after game ended, verify state has `resigned_by` and `status: :won`
- [x] 5.2 Add resign test coverage in `test/tris_web/live/game_live_test.exs`: verify button presence, verify modal shows/hides, verify resign result message
