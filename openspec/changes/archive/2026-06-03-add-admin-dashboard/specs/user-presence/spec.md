## ADDED Requirements

### Requirement: Users are tracked via Phoenix.Presence
The system SHALL define a `Tris.Presence` module using `Phoenix.Presence` to track user presence across the app.

#### Scenario: Presence module exists
- **WHEN** the application starts
- **THEN** `Tris.Presence` is running as a supervised process

### Requirement: Lobby users are tracked
The system SHALL register users in Presence when they are on the lobby page.

#### Scenario: User enters lobby
- **WHEN** a user navigates to `/` and the LobbyLive mounts
- **THEN** their presence is tracked in the `"lobby"` topic with metadata `%{location: "lobby"}`

#### Scenario: User leaves lobby
- **WHEN** a user navigates away from `/` or closes the tab
- **THEN** their presence entry is automatically removed

### Requirement: In-game users are tracked
The system SHALL register users in Presence when they are on a game page.

#### Scenario: User enters game
- **WHEN** a user navigates to `/game/:id` and the GameLive mounts
- **THEN** their presence is tracked in the `"game:#{game_id}"` topic with metadata `%{location: "game", game_id: game_id, mark: mark}`

#### Scenario: User leaves game
- **WHEN** a user navigates away from a game or closes the tab
- **THEN** their presence entry is automatically removed
