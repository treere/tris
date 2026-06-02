## ADDED Requirements

### Requirement: User sets username
The system SHALL allow a user to set their username before joining the matchmaking queue.

#### Scenario: User sets valid username
- **WHEN** a user enters a non-empty username (1–20 characters, alphanumeric + underscores)
- **THEN** the username is saved in the session and displayed in the lobby

#### Scenario: User submits empty username
- **WHEN** a user submits an empty or whitespace-only username
- **THEN** the system SHALL show a validation error and not proceed

#### Scenario: Username exceeds max length
- **WHEN** a user submits a username longer than 20 characters
- **THEN** the system SHALL show a validation error

### Requirement: Username is persisted in session
The system SHALL persist the chosen username across LiveView navigation within the session.

#### Scenario: Username persists across pages
- **WHEN** a user sets a username and navigates from lobby to game
- **THEN** the username SHALL remain visible and associated with the player

### Requirement: Username is displayed
The system SHALL display the current username in the lobby and on the game board.

#### Scenario: Username shown in lobby
- **WHEN** a user is in the lobby
- **THEN** their username SHALL be displayed prominently

#### Scenario: Username shown on game board
- **WHEN** a user is in an active game
- **THEN** their username SHALL be displayed alongside their mark (X or O)
