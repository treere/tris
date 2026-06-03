## Purpose

Allow two human players to exchange text messages during an active game. Chat is ephemeral (lost when the game process terminates) and only available in human-vs-human matches.

## Requirements

### Requirement: Send chat message
A player SHALL be able to send a chat message during an active human-vs-human game. The message SHALL contain the sender's display name, the message text, and a server-generated timestamp. Messages MUST NOT be persisted beyond the game session.

#### Scenario: Send message during game
- **WHEN** a player types text and submits the chat form during a human-vs-human game
- **THEN** the message appears in the chat panel for both players in real time

#### Scenario: Send message during bot game
- **WHEN** a player types text and submits the chat form during a human-vs-bot game
- **THEN** the system SHALL ignore the message and NOT display a chat UI

### Requirement: Receive chat message
A player SHALL receive opponent chat messages in real time without refreshing the page. Messages SHALL be ordered by server timestamp.

#### Scenario: Receive message from opponent
- **WHEN** the opponent sends a chat message
- **THEN** the message appears in the chat panel within the same game-tick broadcast cycle

### Requirement: Chat is ephemeral
Chat messages SHALL exist only for the lifetime of the game process. They SHALL NOT be written to a database, log file, or any persistent store.

#### Scenario: Messages lost after game ends
- **WHEN** the game process terminates (game ends or server restarts)
- **THEN** all chat messages are discarded and cannot be retrieved

### Requirement: Chat UI visibility
The chat panel SHALL be visible only during human-vs-human games. It SHALL NOT be rendered during human-vs-bot games.

#### Scenario: Hide chat in bot games
- **WHEN** a player is in a human-vs-bot game
- **THEN** the chat panel is not visible
