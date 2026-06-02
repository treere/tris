## Requirements

### Requirement: Theme selector UI
The system SHALL provide a visible theme selector UI that lets users browse and select from all available themes.

#### Scenario: Theme selector is visible in lobby
- **WHEN** a user visits the lobby page
- **THEN** the theme selector SHALL be visible in the top-right corner of the page

#### Scenario: Theme selector is visible in game
- **WHEN** a user is on a game page
- **THEN** the theme selector SHALL be visible in the top-right corner of the page

### Requirement: Theme selection via dropdown
The theme selector SHALL be a dropdown menu that displays each theme as a colored swatch with the theme name.

#### Scenario: Dropdown opens on click
- **WHEN** a user clicks the theme selector button
- **THEN** a dropdown SHALL open showing all available themes

#### Scenario: Dropdown shows theme swatches
- **WHEN** the theme dropdown is open
- **THEN** each theme SHALL be displayed as a colored swatch with its name

#### Scenario: Dropdown shows system option
- **WHEN** the theme dropdown is open
- **THEN** a "System" option SHALL be available that follows the OS preference

### Requirement: Theme selection persists
The system SHALL persist the user's theme choice to `localStorage`.

#### Scenario: Theme choice persists across page loads
- **WHEN** a user selects a theme
- **THEN** the theme SHALL persist across page reloads and navigation

#### Scenario: System theme follows OS preference
- **WHEN** a user selects "System"
- **THEN** the theme SHALL follow the OS-level dark/light preference
- **AND** the stored preference SHALL be removed from `localStorage`

### Requirement: Theme applies before paint
The theme SHALL be applied before the page renders to prevent flash of unstyled content.

#### Scenario: Theme applied before page render
- **WHEN** a page loads
- **THEN** the `data-theme` attribute SHALL be set on `<html>` before the page paints

### Requirement: Theme syncs across tabs
Theme changes SHALL sync across open browser tabs.

#### Scenario: Theme change syncs to other tabs
- **WHEN** a user changes the theme in one tab
- **THEN** other open tabs SHALL apply the same theme
