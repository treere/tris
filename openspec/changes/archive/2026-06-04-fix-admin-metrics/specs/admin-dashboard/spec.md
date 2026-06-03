## MODIFIED Requirements

### Requirement: Admin dashboard shows real-time stats

The system SHALL display current usage statistics, refreshed every 3 seconds.

#### Scenario: Dashboard loads with no activity
- **WHEN** a user accesses the admin dashboard with no users online and no active games
- **THEN** all metrics display as 0 and the active games list shows "No active games"

#### Scenario: Dashboard shows correct user counts
- **WHEN** 3 users are in the lobby and 2 of them are in the matchmaker queue, and 4 users are in active games
- **THEN** "Users Online" displays 7 (lobby + in-game, no double-count), "In Lobby" displays 3, "In Queue" displays 2, "In Games" displays 4

#### Scenario: Dashboard shows correct game breakdown
- **WHEN** there are 2 human games and 3 bot games (2 easy, 1 hard) all with `status: :playing`
- **THEN** "Active Games" displays 5, "Human vs Human" displays 2, "Bot Games" displays 3, "Easy Bot" displays 2, "Hard Bot" displays 1

#### Scenario: Finished games are not counted as active
- **WHEN** there are 3 games with `status: :playing` and 2 games with `status: :won` (1 resigned, 1 won by normal play)
- **THEN** "Active Games" displays 3 and only the 3 playing games appear in the active games table

#### Scenario: Bot player names do not count as in-game users
- **WHEN** a bot game has 1 human player and 1 bot
- **THEN** "In Games" counts only the human player, not the bot

#### Scenario: Stats update periodically
- **WHEN** the dashboard is open
- **THEN** the displayed stats refresh every 3 seconds without a full page reload
