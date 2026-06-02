## ADDED Requirements

### Requirement: Turn countdown timer
The system SHALL start a 30-second countdown timer at the beginning of each human player's turn. The timer SHALL NOT start for bot opponents' turns.

#### Scenario: Timer starts on turn change
- **WHEN** a player completes a move and the turn switches to the other human player
- **THEN** a 30-second countdown timer starts for the new active player

#### Scenario: No timer for bot turn
- **WHEN** the turn switches to a bot opponent
- **THEN** no countdown timer is started

### Requirement: Timer display
The system SHALL display a live countdown timer in the UI showing remaining seconds. The timer SHALL be synced from the server timestamp to prevent client-side manipulation.

#### Scenario: Visual countdown shown
- **WHEN** it is a human player's turn
- **THEN** the remaining seconds (30 down to 0) are displayed with a prominent visual indicator

#### Scenario: Timer resets on turn switch
- **WHEN** a move is made and the turn changes
- **THEN** the timer resets to 30 seconds for the new active player

### Requirement: Auto-forfeit on timeout
The system SHALL forfeit the current player when the timer reaches 0, awarding the win to the opponent.

#### Scenario: Active player forfeits on timeout
- **WHEN** the timer reaches 0 for the active player
- **THEN** the game ends with status `:won` and the opponent is declared the winner

#### Scenario: Timeout message shown
- **WHEN** a game ends due to timeout
- **THEN** the UI shows a message indicating the losing player ran out of time

### Requirement: Timer pauses on game end
The system SHALL stop the timer when the game ends (win, tie, or forfeit).

#### Scenario: Timer stops after game over
- **WHEN** the game ends
- **THEN** the timer is cancelled and no further timeout can trigger

### Requirement: Timer urgency styling
The system SHALL change the timer's visual styling when approaching timeout to convey urgency.

#### Scenario: Timer warning color at 10 seconds
- **WHEN** the remaining time is 10 seconds or less
- **THEN** the timer displays with an amber/warning color

#### Scenario: Timer danger color at 5 seconds
- **WHEN** the remaining time is 5 seconds or less
- **THEN** the timer displays with a red/danger color and may pulse
