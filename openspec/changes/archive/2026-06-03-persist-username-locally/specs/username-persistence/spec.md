## ADDED Requirements

### Requirement: Username persists in localStorage
The system SHALL save the username to localStorage when the user sets it, and restore it on subsequent page loads.

#### Scenario: User sets username for the first time
- **WHEN** the user submits a valid username in the lobby form
- **THEN** the username SHALL be saved to `localStorage` under the key `tris_username`
- **AND** the user SHALL see the game selection screen without needing to re-enter the name

#### Scenario: User refreshes the lobby page
- **WHEN** the user has previously set a username
- **AND** the user refreshes the lobby page
- **THEN** the username SHALL be restored from `localStorage`
- **AND** the user SHALL see the game selection screen directly (not the username form)

#### Scenario: User returns to lobby after a game
- **WHEN** a game ends and the user is redirected to the lobby
- **THEN** the username SHALL be restored from `localStorage`
- **AND** the user SHALL see the game selection screen directly

### Requirement: Username can be changed
The system SHALL allow the user to change their username, updating localStorage.

#### Scenario: User clicks "Change name"
- **WHEN** the user clicks "Change name" in the lobby
- **AND** submits a new valid username
- **THEN** the new username SHALL be saved to `localStorage`
- **AND** the old username SHALL be overwritten

### Requirement: No username in URLs
The system SHALL NOT include the username in any URL query parameters.

#### Scenario: Navigating to a game
- **WHEN** the user joins a game
- **THEN** the game URL SHALL NOT contain `?n=` or `?o=` query params
- **AND** the game page SHALL read the player's name from the GameServer state

#### Scenario: Redirecting from game to lobby
- **WHEN** the game ends and the user is redirected to the lobby
- **THEN** the redirect URL SHALL NOT contain `?username=`
- **AND** the username SHALL be restored from `localStorage`

### Requirement: Game page reads name from server state
The game page SHALL continue to display the correct player names using the GameServer state as the source of truth.

#### Scenario: Game page with no URL username params
- **WHEN** the user navigates to a game URL without `?n=` or `?o=`
- **THEN** the page SHALL display the correct player names from the game server state
- **AND** the turn indicator, chat messages, and result messages SHALL all use the correct names
