## ADDED Requirements

### Requirement: Admin page is password-protected
The system SHALL protect the `/admin` route with HTTP Basic Authentication using a shared password.

#### Scenario: Authenticated access
- **WHEN** a user visits `/admin` with correct admin credentials
- **THEN** they see the admin dashboard

#### Scenario: Unauthenticated access
- **WHEN** a user visits `/admin` without credentials or with wrong credentials
- **THEN** the browser prompts for username and password (HTTP 401)

### Requirement: Admin dashboard shows real-time stats
The system SHALL display current usage statistics, refreshed every 3 seconds.

#### Scenario: Dashboard loads
- **WHEN** a user accesses the admin dashboard
- **THEN** they see: users online (lobby vs in-game), active game count, queue depth, bot game count, human game count, bot difficulty breakdown

#### Scenario: Stats update periodically
- **WHEN** the dashboard is open
- **THEN** the displayed stats refresh every 3 seconds without a full page reload

### Requirement: Admin dashboard lists active games
The system SHALL show a list of all active games with details.

#### Scenario: Active games listed
- **WHEN** viewing the admin dashboard
- **THEN** each active game shows: game ID, player names, bot difficulty (if bot game), current turn, game status

### Requirement: Admin password is configurable
The admin password SHALL be configured via the `ADMIN_PASSWORD` environment variable.

#### Scenario: Password from env var
- **WHEN** `ADMIN_PASSWORD` is set
- **THEN** the admin auth uses that password

#### Scenario: Fallback in development
- **WHEN** `ADMIN_PASSWORD` is not set and environment is dev
- **THEN** the system uses a default password (e.g., "admin")
