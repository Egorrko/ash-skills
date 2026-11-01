# Native runtime: a release outside a container

Read when analysis §12 names a runtime other than the Swarm default, typically a
`systemd --user` service on the machine the product controls. Every item below
was hit on a real bootstrap; each is a configuration step, not an installer
defect.

## Release files

`mix phx.gen.release` without `--docker`. It writes `rel/overlays/bin/server`,
`bin/migrate` and `lib/<app>/release.ex`.

## Plain HTTP on a LAN

A phx.new production config assumes HTTPS behind a proxy. For a service that
devices reach as `http://<host-ip>:<port>/`:

- `config/prod.exs`: remove `force_ssl`. It redirects every request to https,
  which nothing serves.
- `config/runtime.exs`: `url: [host: host, port: <PORT>, scheme: "http"]`, and
  `check_origin: :conn`. The default origin check compares the socket origin
  with `url.host`, so a device that opened the page by IP gets a page whose
  LiveView socket is refused: it renders, then never connects.
- The dev endpoint binds `{0, 0, 0, 0}` when §9 names a client on another
  device; phx.new binds loopback.
- Check the chosen port is free on the owner's machine (`ss -ltnp`) and record
  the taken ones in the analysis metadata.

## The unit

- `Environment=PHX_SERVER=true`: without it the release starts with no HTTP
  listener.
- `EnvironmentFile=` takes everything after `=` as the value, comments
  included. `.env.example` keeps comments on their own lines, since it is
  copied to the environment file.
- Required variables have no defaults in the unit; `config/runtime.exs` raises
  on a missing `DATABASE_URL` or `SECRET_KEY_BASE`, which is the loud failure.
- A desktop-integrated unit uses `After=graphical-session.target`,
  `PartOf=graphical-session.target` and `WantedBy=graphical-session.target`,
  so the process inherits `WAYLAND_DISPLAY` and `DBUS_SESSION_BUS_ADDRESS`.

## Static assets

`MIX_ENV=prod mix assets.deploy` runs `phx.digest`, which writes digested and
gzipped copies next to the sources in `priv/static/` (favicon, robots, images).
Add them to `.gitignore`:

```gitignore
/priv/static/**/*-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f].*
/priv/static/**/*.gz
```

## Verification without installing anything

The owner's real unit is theirs to enable. The bootstrap proves the release
boots under the same mechanism with a transient unit and a scratch database,
then removes both:

1. `MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release --overwrite`.
2. Create a scratch database (`<app>_bootstrap_check`) and an env file in the
   scratchpad with `DATABASE_URL`, a fresh `SECRET_KEY_BASE`, a free `PORT`
   and `PHX_SERVER=true`.
3. `bin/migrate` with that environment.
4. `systemd-run --user --unit=<app>-bootstrap-check --property=Type=exec
   --property=EnvironmentFile=<env file> <release>/bin/<app> start`.
5. `curl` `/health` and `/` from loopback, and `/health` from the LAN address
   when §9 names a client on another device.
6. `systemctl --user stop <app>-bootstrap-check`, drop the scratch database.

The handoff row records all of it, and states that the unit file in `deploy/`
was written but not enabled.
