## ADDED Requirements

### Requirement: System detects missing game
When a user navigates to a game page whose ID does not correspond to an active game process, the system SHALL detect the missing game before rendering the game board.

#### Scenario: Navigate to nonexistent game ID
- **WHEN** a user navigates to `/game/<id>` where `<id>` is not registered in `Tris.GameRegistry`
- **THEN** the system SHALL detect the missing game
- **AND** the system SHALL NOT call `GameServer.get_state/1` or attempt any game operations

### Requirement: Display "Game not found" page
When a nonexistent game is detected, the system SHALL display a "Game not found" message instead of the game board.

#### Scenario: Show fallback message
- **WHEN** a user navigates to a nonexistent game
- **THEN** the page SHALL display "Game not found" as the heading
- **AND** the page SHALL display "This game does not exist or has already ended."
- **AND** the page SHALL display "Redirecting to lobby..." to indicate the pending redirect

### Requirement: Auto-redirect to lobby
The system SHALL automatically redirect the user to the lobby after 5 seconds when a nonexistent game is detected.

#### Scenario: Redirect after 5 seconds
- **WHEN** the "Game not found" page is displayed
- **THEN** after 5 seconds the user SHALL be redirected to the lobby (`/`)
- **AND** the user's username SHALL be preserved in the redirect query parameter

### Requirement: Game rendering is unaffected for existing games
The "Game not found" handling SHALL NOT interfere with normal game page rendering for valid game IDs.

#### Scenario: Valid game renders normally
- **WHEN** a user navigates to `/game/<id>` where `<id>` is an active game
- **THEN** the game board SHALL render as normal
- **AND** no "Game not found" message SHALL appear
