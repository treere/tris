## 1. Add `is_my_turn?` assign to GameLive

- [x] 1.1 Add `:is_my_turn` assign derived from `@game_state.turn == @player_mark` in `handle_params`
- [x] 1.2 Re-derive `:is_my_turn` in `handle_info({:game_update, ...})` on each board update

## 2. Update turn indicator template

- [x] 2.1 Replace side-by-side pill layout with vertical stacked layout (active player on top)
- [x] 2.2 Add "Your turn" badge with `animate-pulse` for the active player when `is_my_turn?`
- [x] 2.3 Add "Waiting for opponent..." text with muted styling for the inactive player
- [x] 2.4 Show "You (X)" / "You (O)" as the player's own label instead of `@my_name`

## 3. Add board disabled state

- [x] 3.1 Add dimmed overlay or `opacity-50 pointer-events-none` class on board when not player's turn
- [x] 3.2 Keep board fully interactive with hover effects when it is player's turn

## 4. Verify with tests

- [x] 4.1 Write GameLive test for turn indicator presence
- [x] 4.2 Write GameLive test for board disabled state
- [x] 4.3 Run `mix test` to confirm nothing broken
