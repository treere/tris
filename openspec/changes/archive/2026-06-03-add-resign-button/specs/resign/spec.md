## ADDED Requirements

### Requirement: Player can resign from a game
A player SHALL be able to resign from an active game at any time, regardless of whose turn it is.

#### Scenario: Player resigns during their own turn
- **WHEN** the game is in `:playing` status
- **AND** it is the player's turn
- **AND** the player clicks the "Resign" button
- **AND** the player confirms the resignation in the modal
- **THEN** the server SHALL set the game status to `:won`
- **AND** the server SHALL set the winner to the opponent
- **AND** the server SHALL record the resigning player
- **AND** both players SHALL see a result message indicating the resignation

#### Scenario: Player resigns during opponent's turn
- **WHEN** the game is in `:playing` status
- **AND** it is the opponent's turn
- **AND** the player clicks the "Resign" button
- **AND** the player confirms the resignation in the modal
- **THEN** the server SHALL process the resignation identically to resigning on own turn
- **AND** both players SHALL see the resignation result

#### Scenario: Player cancels resignation
- **WHEN** the player clicks the "Resign" button
- **AND** the confirmation modal is displayed
- **AND** the player clicks "Cancel" or the modal backdrop
- **THEN** the modal SHALL close
- **AND** the game SHALL continue unchanged

### Requirement: Resign button is visible during active gameplay
The "Resign" button SHALL be displayed at all times while the game is active, regardless of turn state.

#### Scenario: Resign button shown on own turn
- **WHEN** the game is in `:playing` status
- **AND** it is the player's turn
- **THEN** the player SHALL see a "Resign" button on the game page

#### Scenario: Resign button shown on opponent's turn
- **WHEN** the game is in `:playing` status
- **AND** it is the opponent's turn
- **THEN** the player SHALL see a "Resign" button on the game page

#### Scenario: Resign button hidden after game ends
- **WHEN** the game status is no longer `:playing` (won, tie, or resigned)
- **THEN** the "Resign" button SHALL NOT be displayed

### Requirement: Confirmation modal prevents accidental resignation
The system SHALL display a confirmation modal when the player clicks the "Resign" button, requiring explicit confirmation before the resignation is executed.

#### Scenario: Confirmation modal is displayed
- **WHEN** the player clicks the "Resign" button
- **THEN** a modal overlay SHALL appear with the text "Are you sure you want to resign?"
- **AND** the modal SHALL have a "Confirm" button to proceed
- **AND** the modal SHALL have a "Cancel" button to dismiss

#### Scenario: Modal is dismissed by clicking Cancel
- **WHEN** the confirmation modal is displayed
- **AND** the player clicks "Cancel"
- **THEN** the modal SHALL close
- **AND** no resignation SHALL occur

### Requirement: Resign result is displayed to both players
When a player resigns, the result SHALL be shown to both players via the existing game-over display.

#### Scenario: Resignation result message
- **WHEN** a player resigns
- **THEN** both players SHALL see a result message: "{player_name} resigned!"
- **AND** the game-over UI SHALL display the "Return to lobby" button
- **AND** both players SHALL be redirected to the lobby after 5 seconds

### Requirement: Server validates resign action
The server SHALL validate that the resign action is legal before processing it.

#### Scenario: Resign after game already ended
- **WHEN** the game status is not `:playing` (already won, tied, or resigned)
- **AND** a player sends a resign action
- **THEN** the server SHALL reject the action
- **AND** no state change SHALL occur

#### Scenario: Double resign
- **WHEN** a player resigns successfully
- **AND** the other player also sends a resign action
- **THEN** the server SHALL reject the second resign action because the game is no longer `:playing`
