## Context

Greenfield Phoenix LiveView application with no existing codebase. No database required — all game state lives in-memory using Elixir processes (GenServers, Agents, ETS). Players connect via browser, identify by username, and get matched in real-time.

## Goals / Non-Goals

**Goals:**
- Username-based identity persisted in session (no auth/passwords)
- Matchmaking queue that pairs two waiting players
- Real-time Tic-Tac-Toe gameplay via LiveView
- Win/tie/draw detection and game conclusion
- Simple, clean UI with Phoenix + Tailwind

**Non-Goals:**
- No persistent database storage
- No user authentication or passwords
- No AI/computer opponent
- No chat or spectator mode
- No game history or leaderboard

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| State management | Phoenix PubSub + Agent/GenServer | In-memory only; no DB needed for MVP. PubSub for real-time board updates across processes. |
| Matchmaking | Single GenServer (Matchmaker) | Holds a queue of waiting players. When 2+ are queued, pops a pair and starts a game. Simple, no persistence. |
| Game session | DynamicSupervisor + GameServer per match | Each active game is a GenServer supervised by a DynamicSupervisor. Scalable and isolated. |
| LiveView mounting | Single-page app with LiveView live navigation | Username form → Lobby (matchmaking) → Game board. Each section is a LiveView. |
| Board representation | 3x3 list of tuples (or map) | `{row, col} => :x \| :o \| nil` — simple to validate and render. |
| Turns | Alternating moves stored in GameServer | X always goes first. GameServer validates turn ownership and board state. |
| No database | All state in memory | Simplifies deployment. State resets on server restart — acceptable for MVP. |

## Risks / Trade-offs

- [State loss on restart] → Acceptable for MVP; add persistence later if needed
- [Race condition in matchmaking] → GenServer sequentializes all queue operations
- [No authentication] → Username spoofing is possible; acceptable for MVP
- [Scaling beyond single node] → Would need distributed Elixir or a database; out of scope
