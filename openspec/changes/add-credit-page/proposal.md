## Why

The app has no attribution page for the technologies and resources used to build it. A credit page gives proper recognition and provides a natural landing for curious users.

## What Changes

- Add a new `/credits` route with a static LiveView page
- Add a subtle "Credits" link in the lobby footer
- Page lists technologies, libraries, and design resources used

## Capabilities

### New Capabilities
- `credit-page`: Static page displaying attributions for technologies, libraries, and design resources used by Tris

### Modified Capabilities

None.

## Impact

- New LiveView file at `lib/tris_web/live/credit_live.ex`
- New route in the router: `live "/credits", CreditLive, :index`
- LobbyLive template updated with a credits link
