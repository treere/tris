## ADDED Requirements

### Requirement: Player can ask to play
The system SHALL allow a user with a set username to enter the matchmaking queue by clicking "Ask to play".

#### Scenario: Player joins queue
- **WHEN** a user with a valid username clicks "Ask to play"
- **THEN** they SHALL be added to the matchmaking queue and see a "Waiting for opponent..." status

#### Scenario: Player without username cannot queue
- **WHEN** a user without a set username clicks "Ask to play"
- **THEN** the system SHALL prompt them to set a username first

### Requirement: Player can cancel queue
The system SHALL allow a queued player to leave the matchmaking queue before being matched.

#### Scenario: Player cancels queue
- **WHEN** a queued player clicks "Cancel"
- **THEN** they SHALL be removed from the queue and return to lobby

### Requirement: Two players are matched
When two or more players are in the queue, the system SHALL pair them and start a game.

#### Scenario: Two players matched
- **WHEN** a second player joins the queue while one player is waiting
- **THEN** both players SHALL be removed from the queue and redirected to a new game
- **THEN** the first player SHALL be assigned X and the second player SHALL be assigned O

#### Scenario: Three or more players queue
- **WHEN** three players are in the queue
- **THEN** the first two SHALL be matched immediately
- **THEN** the third SHALL remain waiting

### Requirement: Player sees matchmaking status
The system SHALL display real-time status updates while in the queue.

#### Scenario: Waiting for opponent
- **WHEN** a player is alone in the queue
- **THEN** they SHALL see "Waiting for opponent..." with a loading indicator

#### Scenario: Match found
- **WHEN** a match is made
- **THEN** both players SHALL be notified and navigated to the game board
