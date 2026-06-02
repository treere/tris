## ADDED Requirements

### Requirement: Game auto-redirects to lobby

When a game ends (win, loss, or tie), the game screen SHALL automatically navigate to the lobby after a delay.

#### Scenario: Game ends with a winner
- **WHEN** the game status becomes `:won`
- **THEN** the game SHALL display the result message and "Return to lobby" button
- **THEN** after 5 seconds, the page SHALL automatically navigate to `/`

#### Scenario: Game ends in a tie
- **WHEN** the game status becomes `:tie`
- **THEN** the game SHALL display "It's a tie!" and "Return to lobby" button
- **THEN** after 5 seconds, the page SHALL automatically navigate to `/`

#### Scenario: Player returns immediately
- **WHEN** the player clicks "Return to lobby" button during the auto-redirect countdown
- **THEN** the page SHALL immediately navigate to `/`

### Requirement: Redirect is displayed to the player

The game screen SHALL show a "Return to lobby" button and countdown indicator while the auto-redirect is pending.

#### Scenario: Result overlay shows redirect info
- **WHEN** a game result is displayed
- **THEN** the result overlay SHALL include the "Return to lobby" button
- **THEN** the result overlay SHALL include a "Redirecting..." note with the countdown
