## Purpose

Define the behavior and visual requirements for the turn indicator system in the Tic-Tac-Toe game, informing players whose turn it is and whether they are the active player.

## Requirements

### Requirement: Explicit turn messaging
The system SHALL display a clear "Your turn" indicator when it is the current player's turn, and a "Waiting for opponent..." message when it is not.

#### Scenario: Active player sees "Your turn"
- **WHEN** the game state's `turn` matches the player's mark
- **THEN** the player sees a prominent "Your turn" badge with a pulsing animation

#### Scenario: Inactive player sees "Waiting..."
- **WHEN** the game state's `turn` does not match the player's mark
- **THEN** the player sees a "Waiting for opponent..." message with muted styling

### Requirement: Self-identification labels
The system SHALL label the current player as "You (X)" or "You (O)" instead of their raw name, and the opponent by their name.

#### Scenario: Player sees themselves as "You"
- **WHEN** a player's own name pill is displayed
- **THEN** it reads "You (X)" or "You (O)" with bold styling

### Requirement: Board disabled state
The system SHALL visually disable the game board when it is not the player's turn.

#### Scenario: Board dims on opponent's turn
- **WHEN** it is the opponent's turn
- **THEN** the board cells are non-interactive and the entire board appears dimmed

#### Scenario: Board is interactive on player's turn
- **WHEN** it is the player's turn
- **THEN** all empty board cells are interactive with hover effects

### Requirement: Turn transition animation
The system SHALL animate the turn indicator when the turn changes.

#### Scenario: Pulse on active player
- **WHEN** the turn changes
- **THEN** the active player's turn indicator uses a subtle pulsing animation to draw attention

### Requirement: Layout distinction
The system SHALL stack the turn indicator vertically with the current player placed above.

#### Scenario: Active player on top
- **WHEN** the turn indicator is rendered
- **THEN** the current player's info is displayed above the opponent's info
