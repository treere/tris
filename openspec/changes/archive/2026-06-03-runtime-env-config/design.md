## Context

The application uses HTTP Basic Authentication for the admin dashboard. The admin password is configured in `config/config.exs`:

```elixir
config :tris, admin_password: System.get_env("ADMIN_PASSWORD", "admin")
```

This is evaluated at compile time, meaning the default password `"admin"` is baked into the compiled BEAM files. In a release, changing the password requires recompilation. The configuration is accessed at runtime via `Application.compile_env/3` in the router and tests.

Elixir's recommended approach (per `config/runtime.exs` and the official docs) is to load secrets at runtime — evaluated on every boot — not at compile time.

## Goals / Non-Goals

**Goals:**
- Move `admin_password` from compile-time config to runtime config
- Ensure the password can be changed without recompilation
- Remove the compile-time default `"admin"` for security (force explicit env var in production)
- Maintain backward compatibility for development (no `.env` file required to run dev server)

**Non-Goals:**
- No changes to the admin authentication mechanism (still HTTP Basic Auth)
- No changes to other compile-time config values
- No introduction of external dependencies (dotenv libraries, etc.)

## Decisions

1. **Runtime config location: `config/runtime.exs`** — already exists and is the standard Elixir location for runtime configuration. Add the `admin_password` inside the existing `if config_env() == :prod do` block for production, and provide a sensible default for dev/test.

2. **API change: `Application.compile_env` → `Application.get_env`** — since the value will no longer be set at compile time, `compile_env` will raise a warning. Switching to `get_env` (with a fallback) correctly reads the runtime-set value.

3. **Remove compile-time default in production** — require `ADMIN_PASSWORD` env var to be explicitly set in production (raise if missing), matching the pattern already used for `SECRET_KEY_BASE`. In dev/test, default to `"admin"` for convenience.

4. **No `.env` support** — the project uses env vars directly via `System.get_env`. Adding a dotenv dependency is unnecessary complexity for this change. If desired, it can be added separately.

## Risks / Trade-offs

- **[Risk]** Existing deployments relying on the compile-time default `"admin"` will fail to boot after this change if `ADMIN_PASSWORD` is not set
  → **Mitigation**: The error message will clearly state the missing variable. Document the env var in deployment notes.
- **[Risk]** Tests that use `Application.compile_env` will break
  → **Mitigation**: Update all occurrences to `Application.get_env`. The test already has a module attribute — change it to use `Application.get_env` at runtime.
