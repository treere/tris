# Tris

A real-time multiplayer Tic-Tac-Toe game built with **Phoenix LiveView** and **Elixir/OTP**. No database — all game state lives in lightweight GenServers with PubSub broadcasting for live updates.

## Features

- **Online matchmaking** — queue up and get paired with another player automatically
- **Bot opponent** — play against Easy (random) or Hard (minimax, unbeatable)
- **30-second turn timer** — auto-forfeit if you run out of time
- **Live board updates** — moves appear instantly via Phoenix PubSub
- **In-game chat** — chat with your human opponent during a match
- **Resign anytime** — concede and return to lobby with one click
- **6 curated themes** — pick your look with a persistent dropdown (Phoenix, Elixir, Forest, Ocean, Sunset, Midnight)
- **Fully anonymous** — pick a username (persisted in localStorage), no sign-up required
- **Admin dashboard** — real-time usage analytics at `/admin` (password-protected, default `admin`/`admin`, configurable via `ADMIN_PASSWORD` env var)

## Setup

```bash
git clone git@github.com:treere/tris.git
cd tris
mix setup
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000).

## Tests

```bash
mix test
mix precommit  # compile + format + test, all in one
```

## Architecture

| Layer | Technology |
|---|---|
| Web server | Bandit |
| Live views | Phoenix LiveView 1.1 |
| Game state | In-memory GenServers |
| Matchmaking | `Tris.Matchmaker` GenServer |
| Bot AI | Minimax (hard) / random (easy) |
| Real-time | Phoenix PubSub |
| User presence | Phoenix Presence |
| Styling | Tailwind CSS v4 + daisyUI |
