## ADDED Requirements

### Requirement: Player can change their username from the lobby

The lobby SHALL provide a way for the player to change their username after initially setting it.

#### Scenario: Change name button is visible
- **WHEN** the player has set their username and is viewing the game selection screen
- **THEN** a "Change name" button SHALL be visible on the game selection screen

#### Scenario: Change name returns to username form
- **WHEN** the player clicks "Change name"
- **THEN** the username SHALL be cleared
- **THEN** the username form SHALL be displayed again
- **THEN** the player SHALL be able to enter a new username

### Requirement: Queue is cancelled on name change

If the player is waiting in the matchmaking queue and changes their name, their queue entry SHALL be cancelled.

#### Scenario: Cancel queue on name change while waiting
- **WHEN** the player is waiting in the queue (`queue_status == :waiting`)
- **WHEN** the player clicks "Change name"
- **THEN** the queue entry SHALL be cancelled via `Matchmaker.cancel/1`
- **THEN** the `queue_status` SHALL be reset to `nil`
- **THEN** the username form SHALL be displayed
