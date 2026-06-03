## ADDED Requirements

### Requirement: Credits page renders at /credits
The system SHALL serve a static credits page at `/credits` accessible to any visitor.

#### Scenario: Visit credits page
- **WHEN** a user navigates to `/credits`
- **THEN** the page displays a heading "Credits"
- **AND** lists attributions for technologies and resources used

#### Scenario: Credits link in lobby
- **WHEN** a user is on the lobby page
- **THEN** they see a "Credits" link that navigates to `/credits`
