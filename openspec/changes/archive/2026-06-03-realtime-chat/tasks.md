## 1. GameServer — Chat state and broadcasting

- [x] 1.1 Add `:chat_messages` field (empty list) to GameServer `init/1` state
- [x] 1.2 Implement `send_message/3` public function that appends a `%{sender: name, text: text, timestamp: DateTime.t()}` map to `chat_messages` and broadcasts `{:chat_message, msg}` on the game topic
- [x] 1.3 Include `chat_messages` in the state returned by `get_state/1` (already covered since it returns full state)

## 2. GameLive — Chat event handling and UI

- [x] 2.1 Add `@chat_messages` assign (empty list) and `@is_human_game` assign in `handle_params/2`
- [x] 2.2 Add `handle_info({:chat_message, msg}, socket)` to append to `@chat_messages`
- [x] 2.3 Add `handle_event("send_chat", %{"text" => text}, socket)` that calls `GameServer.send_message/3`
- [x] 2.4 Render chat panel in template — visible only when `!@is_bot_game`, with a message list and a text input with submit button
- [x] 2.5 Style the chat panel with Tailwind to match the existing game UI (scrollable message area, compact input)

## 3. Tests

- [x] 3.1 Add GameServer test: sending a message stores it in state and broadcasts to PubSub
- [x] 3.2 Add GameLive test: chat form is present for human-vs-human games
- [x] 3.3 Add GameLive test: chat form is absent for human-vs-bot games
- [x] 3.4 Add GameLive test: submitting a chat message sends it and displays it
