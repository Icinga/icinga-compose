# Icinga Compose

A complete Icinga monitoring stack on your machine, with a single command:

- **Icinga 2**: the monitoring core
- **Icinga DB** with Redis: moves monitoring state into a database
- **Icinga Web**: the web UI, with Director, Graphite graphs, x509
  certificate monitoring, Business Process and Cube
- **MariaDB** or **PostgreSQL**: your choice
- **Graphite**: stores performance data

Everything comes from published container images, and Director sets up
an example that monitors the stack's own containers, so there's something
to look at right away.

## Table of Contents

- [Quick Start](#quick-start)
- [Using PostgreSQL Instead](#using-postgresql-instead)
- [Changing Passwords and Versions](#changing-passwords-and-versions)
- [Starting Over](#starting-over)
- [What's Inside](#whats-inside)
- [Going Further](#going-further)
- [Under the Hood](#under-the-hood)

## Quick Start

You need Docker Compose v2.35+ on Docker Engine 28.1+, or an equally recent
Podman Compose (just type `podman compose` wherever this document says
`docker compose`).

Run all Compose commands from the repository root. The bind mounts use
your current working directory to locate the scripts and example files.

**1. Create your `.env`:**

```shell
cp .env.example .env
```

Don't skip this. It contains `COMPOSE_PROFILES=mysql`, which tells Compose
to start the database, and with it everything that needs one. Without it,
there's no web UI.

**2. Optional: pick a hostname, now or never.** The Icinga 2 master is called
`icinga2` by default. If you want a different name, set it in `.env`
*before* the first start:

```env
ICINGA_HOSTNAME=icinga-master
```

Icinga 2 issues its certificate for that name on its first start. Changing it
later means [starting over](#starting-over).

**3. Start it:**

```shell
docker compose up
```

**4. Log in** at <http://localhost:8080/> as **icingaadmin** / **icinga**.

That's it.

## Using PostgreSQL Instead

Same as above, but your `.env` needs two lines instead of one:

```env
COMPOSE_PROFILES=pgsql
DATABASE_TYPE=pgsql
```

Everything else stays the same. Both lines must agree: `COMPOSE_PROFILES`
decides which database *container* starts, `DATABASE_TYPE` tells every other
service which one to *talk to*.

Switching an existing setup from one database to the other? Run
`docker compose down -v` *first*, then change both lines and
`docker compose up` again (see [Starting Over](#starting-over)).

## Changing Passwords and Versions

Every other setting is optional and has a working default. `.env.example`
lists them all, roughly in order of how likely you are to care:

| Variable                      | Default          | What it is                         |
|-------------------------------|------------------|------------------------------------|
| `ICINGAWEB_ADMIN_PASSWORD`    | `icinga`         | Icinga Web login for `icingaadmin` |
| `ICINGA_ADMIN_PASSWORD`       | `icinga`         | Icinga 2 API password for `root`   |
| `<SERVICE>_DATABASE_PASSWORD` | e.g. `x509`      | One database password per service  |
| `ICINGADB_REDIS_PASSWORD`     | `icingadb-redis` | Redis password                     |
| `<IMAGE>_TAG`                 | mostly `latest`  | Image versions, e.g. `ICINGA_TAG`  |

The database passwords are only applied when the database is created, i.e. on
the first start. Changing them later means [starting over](#starting-over).

The database, Icinga 2 API and Redis passwords must not begin or end with
whitespace. They also end up in the generated Icinga Web configuration, whose
renderer strips leading and trailing whitespace from values, while the
database, Icinga 2 and Redis keep the original bytes. Authentication between
them would fail.

## Starting Over

Some settings only take effect on the very first start (hostname, database
type, database passwords). To apply them later, or just to get a clean slate,
throw away all data and start fresh:

```shell
docker compose down -v
docker compose up
```

## What's Inside

### Director Example

Director sets itself up on its own: it connects to Icinga 2, imports the
stack's own containers as hosts from `fileshipper/example/tcp.csv`, adds TCP,
SSL and HTTP checks for their ports (via the import sources and sync rules
in `scripts/director-basket.json`) and deploys the result. Watch them in
Icinga Web, or see how they're built under **Icinga Director > Automation**.

### Fileshipper Playground

Want to play with CSV imports without touching the example? Create a
`fileshipper/playground` directory (it's git-ignored), drop CSV files there
and add a new import source for them under **Icinga Director > Automation**.
Leave `fileshipper/example` as it is, since the Director example depends on it.

### x509 Certificate Monitoring

The x509 module is installed and its scanner is running, but there's nothing
to scan yet. Add a scan job under **Certificate Monitoring > Configuration**.

### Graphite

Icinga 2 writes performance data to Graphite, and Icinga Web shows the
graphs. Graphite's own web UI isn't published; see
[Going Further](#going-further) if you want it.

## Going Further

### Local Overrides: `compose.override.yml`

Anything not covered by `.env` goes into a `compose.override.yml` next to
`compose.yml`. Compose merges it in automatically, and it's git-ignored
(only with that exact spelling, not `.yaml`). For
example, to publish Graphite's own web UI on port 8081:

```yaml
services:
  graphite:
    ports:
      - 127.0.0.1:8081:80
```

The same way, you can set an image's own environment variables (e.g.
Graphite's `GRAPHITE_TIME_ZONE`), add health checks, or build a service from a
local checkout. Setting such variables in `.env` does nothing. Only the
variables listed in `.env.example` reach the containers.

### Sending Metrics via OpenTelemetry

Icinga 2's `otlpmetrics` feature is off by default. Turn it on via
`compose.override.yml`, where every `ICINGA_OTLPMETRICS_<ATTRIBUTE>`
becomes an attribute of the feature:

```yaml
services:
  icinga2:
    environment:
      ICINGA_OTLPMETRICS_ENABLE: 1
      ICINGA_OTLPMETRICS_HOST: otel-collector
```

`ICINGA_OTLPMETRICS_ENABLE` and the boolean attributes (`_ENABLE_HA`,
`_ENABLE_SEND_THRESHOLDS`, `_ENABLE_TLS`, `_TLS_INSECURE_NOVERIFY`) take
`1` or `0`, not `true` or `false`. Unset, they keep the feature's defaults.

The `graphite` and `icingadb` features are always on. No other Icinga 2
feature is configurable this way.

### More Icinga Web Modules

To enable additional modules shipped with the Icinga Web image, list them in
`.env`:

```env
ICINGAWEB_ENABLEDMODULES=module1,module2
```

## Under the Hood

You don't need any of this to use the stack. It's for when you want to
change it.

### Services

| Service          | Description                                                     |
|------------------|-----------------------------------------------------------------|
| `icinga2`        | Icinga 2 master                                                 |
| `graphite`       | Stores performance data written by Icinga 2                     |
| `icingadb-redis` | Exchanges state between Icinga 2, Icinga DB and Icinga DB Web   |
| `mysql`          | MariaDB (profile: `mysql`)                                      |
| `pgsql`          | PostgreSQL (profile: `pgsql`)                                   |
| `pingdb`         | Waits for the database, see below (profile: `mysql`, `pgsql`)   |
| `icingadb`       | Icinga DB daemon (profile: `mysql`, `pgsql`)                    |
| `icingaweb`      | Icinga Web UI (profile: `mysql`, `pgsql`)                       |
| `director`       | Director's config-deployment daemon (profile: `mysql`, `pgsql`) |
| `x509`           | Certificate-scanning daemon (profile: `mysql`, `pgsql`)         |

`compose.yml` itself only pulls in `services/*.yml` via the top-level
`include:` field, which is why a recent Compose is required.

### Profiles and `DATABASE_TYPE`

The `mysql` and `pgsql` services are named after their `DATABASE_TYPE`
value, so `DATABASE_TYPE` doubles as the database hostname every other service
connects to. `COMPOSE_PROFILES` only gates which containers start, and Compose
reads it from `.env` or your shell; the compose files have no fallback for
it. Activating both profiles works, but the database not matching
`DATABASE_TYPE` would just run for nothing.

### Three Icinga Web Containers

`icingaweb`, `director` and `x509` use the same `icinga/icingaweb2`
image for different purposes. `icingaweb` serves the web UI.
`director` runs the Director daemon with Fileshipper and x509 also
enabled. `x509` runs the x509 daemon.
`ICINGAWEB_ENABLEDMODULES` adds modules to all three containers.

Only `icingaweb` has a persistent `/data` volume. The Director and x509
daemons store their application state in the database and regenerate
their local Icinga Web configuration from environment variables on
every start.

### `pingdb`

`depends_on:` needs a fixed service name; it can't target "whichever of
`mysql`/`pgsql` is active." `pingdb` (`scripts/pingdb.sh` on busybox) is
present in both profiles, reads `DATABASE_TYPE` to know which host to poll,
and exits once the database accepts connections. `director` and `x509`
depend on it instead of on the database directly.

### Database Bootstrap

`scripts/mysql-init.sh` and `scripts/pgsql-init.sh` create one database and
user per service with the `<SERVICE>_DATABASE_PASSWORD`s. Like any database
image's init scripts, they only run against an empty volume, hence
[starting over](#starting-over).

The x509 schema is not part of that. Before starting the scanner, the `x509`
service runs `scripts/x509-schema.php`, which imports the schema shipped with
the Icinga Web image's x509 module unless the `x509_schema` table already
exists.

### Environment Variables

`.env` is not passed to the containers wholesale. Only variables interpolated
as `${...}` in `services/*.yml` reach a container, which is why adding
arbitrary variables to `.env` has no effect.

### Icinga 2 Features

`scripts/icinga2-features.conf` always enables `graphite` and `icingadb`,
pointed at the stack's own services, and optionally `otlpmetrics` (see
[above](#sending-metrics-via-opentelemetry)). ApiListener is managed by the
image's own entrypoint, CheckerComponent and NotificationComponent are
pre-enabled by the image, and the remaining features are deliberately left
out as deprecated, not meaningful in a container or not needed by this demo.

### Icinga Web Configuration

Environment variables prefixed `icingaweb` (see `services/icingaweb.yml`,
`director.yml`, `x509.yml`) are translated into `.ini` files by the
`icinga/icingaweb2` image's entrypoint, using the character right after
`icingaweb` as the field separator for the rest of the name, e.g.:

```env
icingaweb_modules_director_config_db_resource=director
# -> /data/etc/icingaweb2/modules/director/config.ini: [db] resource = director
```

`icingawebXconfigXglobalXconfig_resource` uses `X` as that separator instead
of `_`, because its last segment, `config_resource`, is itself the literal
`.ini` key name and must not be split further. Two variable names are
special-cased instead of mapping to a file: `icingaweb_enabledModules` (a
comma-separated module list) and `icingaweb_passwords_<backend>_<user>`
(seeds a user's password into a database authentication backend).
