## ADDED Requirements

### Requirement: Player can start a bot game from lobby
The system SHALL allow a player who has set a username to start a game against a bot opponent directly from the lobby, without entering the matchmaking queue.

#### Scenario: "Play with Bot" buttons visible after username is set
- **WHEN** the player has set a username
- **THEN** the lobby shows two buttons alongside "Ask to play": "Play with Bot (Easy)" and "Play with Bot (Hard)"

#### Scenario: Bot game starts immediately
- **WHEN** the player clicks "Play with Bot (Easy)" or "Play with Bot (Hard)"
- **THEN** the system creates a game immediately and navigates the player to the game page

### Requirement: Bot makes moves automatically with configurable difficulty
The system SHALL implement a bot player that makes moves on its turn using the selected difficulty strategy.

#### Scenario: Easy bot makes random moves
- **WHEN** the difficulty is set to `:easy`
- **THEN** the bot SHALL select a random empty cell from the available positions

#### Scenario: Hard bot is unbeatable
- **WHEN** the difficulty is set to `:hard`
- **THEN** the bot SHALL use a minimax algorithm to select the optimal move, never losing a game

#### Scenario: Bot waits before moving
- **WHEN** it becomes the bot's turn
- **THEN** the bot SHALL wait approximately 800ms before making its move

### Requirement: Bot is identified in the UI
The system SHALL display the bot opponent as "Bot" in the game UI.

#### Scenario: Bot name displayed
- **WHEN** a game is played against a bot
- **THEN** the opponent's name pill reads "Bot (Easy)" or "Bot (Hard)" depending on difficulty

#### Scenario: Turn indicator works for bot turns
- **WHEN** it is the bot's turn
- **THEN** the human player sees "Waiting for Bot..." with muted styling (same as waiting for a human opponent)

### Requirement: Bot uses the same game interface
The bot SHALL make moves through the same game state and rules as a human player.

#### Scenario: Bot moves are validated
- **WHEN** the bot attempts to make a move on an occupied cell
- **THEN** the system SHALL not apply the move (this must not happen with correct implementation)

#### Scenario: Bot cannot move out of turn
- **WHEN** it is not the bot's turn
- **THEN** the system SHALL not accept a move from the bot
