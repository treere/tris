## 1. Move config to runtime

- [x] 1.1 Remove `admin_password` from `config/config.exs`
- [x] 1.2 Add `admin_password` to `config/runtime.exs` with production guard and fallback for dev/test

## 2. Update application code

- [x] 2.1 Change `Application.compile_env` to `Application.get_env` in `lib/tris_web/router.ex`

## 3. Update tests

- [x] 3.1 Change `Application.compile_env` to `Application.get_env` in `test/tris_web/live/admin_live_test.exs`

## 4. Verify

- [x] 4.1 Run `mix test` to confirm all tests pass
- [x] 4.2 Run `mix compile --warnings-as-errors` to confirm no compile warnings
