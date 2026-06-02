## ADDED Requirements

### Requirement: Theme definitions in CSS
The system SHALL define all themes using the daisyUI theme plugin in `app.css`, with each theme having its own `@plugin` block with a unique `name`.

#### Scenario: All themes are defined in app.css
- **WHEN** the application compiles
- **THEN** `app.css` SHALL contain a `@plugin "../vendor/daisyui-theme"` block for each available theme

### Requirement: Minimum theme count
The system SHALL offer at least 4 curated themes for users to choose from.

#### Scenario: At least 4 themes available
- **WHEN** a user opens the theme selector dropdown
- **THEN** at least 4 theme options SHALL be displayed

### Requirement: Each theme has full daisyUI palette
Each theme SHALL define the full set of daisyUI CSS variables for consistent UI rendering.

#### Scenario: Theme has required CSS variables
- **WHEN** a theme is applied via `data-theme`
- **THEN** all daisyUI semantic color tokens (`--color-base-100` through `--color-error-content`, `--radius-*`, `--size-*`, `--border`, `--depth`, `--noise`) SHALL be defined

### Requirement: Default theme is set
One theme SHALL be marked as the default, applied when no preference is saved.

#### Scenario: Default theme on first visit
- **WHEN** a user visits the app for the first time
- **THEN** the default theme SHALL be applied

### Requirement: Dark theme follows system preference
A theme SHALL be marked with `prefersdark: true` so it applies automatically when the OS is in dark mode and the user has "System" selected.

#### Scenario: System dark mode applies dark theme
- **WHEN** a user has "System" selected and the OS is in dark mode
- **THEN** the dark-suitable theme SHALL be applied
