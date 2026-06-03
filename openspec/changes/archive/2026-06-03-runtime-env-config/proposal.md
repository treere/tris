## Why

The `admin_password` is currently configured at compile-time in `config/config.exs` using `System.get_env/1`. This bakes the default value into the compiled BEAM files, exposing it in the `_build` directory and release artifacts. For security, secrets and environment-specific values should be loaded at runtime via `config/runtime.exs`, which is evaluated on every boot and reads fresh environment variables from the deployment environment.

## What Changes

- Move `admin_password` configuration from `config/config.exs` (compile-time) to `config/runtime.exs` (runtime)
- Change `Application.compile_env` calls to `Application.get_env` in router and tests
- Remove the compile-time fallback default `"admin"` (will require explicit env var configuration in production)
- No functional changes to admin authentication behavior

## Capabilities

### New Capabilities

*(None — this is an internal infrastructure change with no new user-facing capabilities)*

### Modified Capabilities

*(None — admin authentication behavior is unchanged at the spec level)*

## Impact

- `config/config.exs` — remove `admin_password` entry
- `config/runtime.exs` — add `admin_password` loading from env var
- `lib/tris_web/router.ex` — change `Application.compile_env` to `Application.get_env`
- `test/tris_web/live/admin_live_test.exs` — change `Application.compile_env` to `Application.get_env`
