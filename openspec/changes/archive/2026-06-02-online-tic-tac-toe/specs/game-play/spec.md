## ADDED Requirements

### Requirement: Game board is displayed
The system SHALL render a 3×3 Tic-Tac-Toe board for an active game.

#### Scenario: Board rendered at game start
- **WHEN** a game starts
- **THEN** a 3×3 grid SHALL be displayed showing all cells as empty
- **THEN** the current turn (X) SHALL be indicated

#### Scenario: Board shows player marks
- **WHEN** a cell is occupied
- **THEN** it SHALL display X or O depending on which player moved there

### Requirement: Players take alternating turns
Players SHALL take turns placing their mark on the board. X goes first.

#### Scenario: Valid turn
- **WHEN** it is a player's turn and they click an empty cell
- **THEN** their mark SHALL be placed in that cell
- **THEN** the turn SHALL switch to the other player

#### Scenario: Click on occupied cell
- **WHEN** a player clicks a cell that is already occupied
- **THEN** nothing SHALL change and the turn SHALL remain the same

#### Scenario: Click out of turn
- **WHEN** a player clicks a cell when it is not their turn
- **THEN** nothing SHALL change

### Requirement: Win detection
The system SHALL detect when a player has three marks in a row (horizontal, vertical, or diagonal).

#### Scenario: Player wins with three in a row
- **WHEN** a player places a mark that completes three in a row
- **THEN** the game SHALL end
- **THEN** the winning player SHALL be announced

#### Scenario: Board shows win visually
- **WHEN** a game ends with a winner
- **THEN** the winning line SHALL be highlighted on the board

### Requirement: Tie detection
The system SHALL detect when the board is full with no winner.

#### Scenario: Board fills with no winner
- **WHEN** all 9 cells are occupied and no player has three in a row
- **THEN** the game SHALL end with a tie
- **THEN** a tie message SHALL be displayed

### Requirement: Game conclusion and return to lobby
After a game ends, players SHALL be able to return to the lobby.

#### Scenario: Game over options
- **WHEN** a game ends (win or tie)
- **THEN** both players SHALL see the result
- **THEN** a "Play again" or "Return to lobby" button SHALL be available

#### Scenario: Return to lobby
- **WHEN** a player clicks "Return to lobby"
- **THEN** they SHALL be navigated back to the lobby page
