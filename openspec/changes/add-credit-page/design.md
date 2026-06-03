## Context

Tris has no page for crediting the technologies and resources used. The lobby is the only landing page. A credits page at `/credits` provides a natural place for attributions.

## Goals / Non-Goals

**Goals:**
- Add a route `/credits` that renders a static credits page
- Add a "Credits" link in the lobby footer area
- Page is purely informational, no interactivity needed

**Non-Goals:**
- No database or server state changes
- No authentication or permissions
- No dynamic content or API integration

## Decisions

- **LiveView over static controller**: Using a LiveView (`CreditLive`) is simpler given the app uses LiveView everywhere, and the layout (`Layouts.app`) is already a LiveView layout. A controller-based page would need a separate layout path.
- **Simple link in lobby**: The "Credits" link goes in a small footer section below the main game content, styled to match the existing muted text style.

## Risks / Trade-offs

- **Minor route addition**: Adding a new route is trivial and carries no risk. No migration or rollback needed.
