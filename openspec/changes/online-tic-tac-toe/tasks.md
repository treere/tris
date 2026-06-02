## 1. Project Setup

- [x] 1.1 Create new Phoenix project with LiveView and Tailwind
- [x] 1.2 Configure endpoint, router, and app module
- [x] 1.3 Add PubSub configuration for real-time updates

## 2. User Identity

- [x] 2.1 Create lobby LiveView with username form
- [x] 2.2 Implement username validation (non-empty, 1–20 chars, alphanumeric + underscores)
- [x] 2.3 Persist username in LiveView session assigns
- [x] 2.4 Display username in lobby header

## 3. Matchmaking System

- [x] 3.1 Implement Matchmaker GenServer with queue state
- [x] 3.2 Add `ask_to_play` / `cancel_queue` API to Matchmaker
- [x] 3.3 Integrate matchmaking buttons into lobby LiveView
- [x] 3.4 Add "Waiting for opponent..." status display with loading indicator
- [x] 3.5 Implement automatic pairing when 2+ players are queued
- [x] 3.6 Assign X to first player and O to second on match
- [x] 3.7 Redirect matched players to game LiveView

## 4. Game Play

- [x] 4.1 Implement GameServer GenServer (board state, turns, validation)
- [x] 4.2 Set up DynamicSupervisor for game processes
- [x] 4.3 Create game LiveView with 3×3 board rendering
- [x] 4.4 Handle cell clicks with turn validation
- [x] 4.5 Implement win detection (rows, columns, diagonals)
- [x] 4.6 Implement tie detection (board full, no winner)
- [x] 4.7 Highlight winning line on game end
- [x] 4.8 Display game result (win/tie) with player names
- [x] 4.9 Add "Return to lobby" button on game conclusion
- [x] 4.10 Broadcast board updates via PubSub to both players

## 5. Polish

- [x] 5.1 Style UI with Tailwind (responsive, clean design)
- [x] 5.2 Test basic flow: set name → queue → play → finish → return
