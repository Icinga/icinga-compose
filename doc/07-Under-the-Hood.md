# Under the Hood

You don't need any of this to use the stack. It's for when you want to
change it.

## Services

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

## Profiles and `DATABASE_TYPE`

The `mysql` and `pgsql` services are named after their `DATABASE_TYPE`
value, so `DATABASE_TYPE` doubles as the database hostname every other service
connects to. `COMPOSE_PROFILES` only gates which containers start, and Compose
reads it from `.env` or your shell; the compose files have no fallback for
it. Activating both profiles works, but the database not matching
`DATABASE_TYPE` would just run for nothing.

## Three Icinga Web Containers

`icingaweb`, `director` and `x509` use the same `icinga/icingaweb2`
image for different purposes. `icingaweb` serves the web UI.
`director` runs the Director daemon with Fileshipper and x509 also
enabled. `x509` runs the x509 daemon.
`ICINGAWEB_ENABLEDMODULES` adds modules to all three containers.

Only `icingaweb` has a persistent `/data` volume. The Director and x509
daemons store their application state in the database and regenerate
their local Icinga Web configuration from environment variables on
every start.

## `pingdb`

`depends_on:` needs a fixed service name; it can't target "whichever of
`mysql`/`pgsql` is active." `pingdb` (`scripts/pingdb.sh` on busybox) is
present in both profiles, reads `DATABASE_TYPE` to know which host to poll,
and exits once the database accepts connections. `director` and `x509`
depend on it instead of on the database directly.

## Database Bootstrap

`scripts/mysql-init.sh` and `scripts/pgsql-init.sh` create one database and
user per service with the `<SERVICE>_DATABASE_PASSWORD`s. Like any database
image's init scripts, they only run against an empty volume, hence
[starting over](04-Starting-Over.md).

The x509 schema is not part of that. Before starting the scanner, the `x509`
service runs `scripts/x509-schema.php`, which imports the schema shipped with
the Icinga Web image's x509 module unless the `x509_schema` table already
exists.

## Environment Variables

`.env` is not passed to the containers wholesale. Only variables interpolated
as `${...}` in `services/*.yml` reach a container, which is why adding
arbitrary variables to `.env` has no effect.

## Icinga 2 Features

`scripts/icinga2-features.conf` always enables `graphite` and `icingadb`,
pointed at the stack's own services, and optionally `otlpmetrics` (see
[Sending Metrics via OpenTelemetry](06-Going-Further.md#sending-metrics-via-opentelemetry)). ApiListener is managed by the
image's own entrypoint, CheckerComponent and NotificationComponent are
pre-enabled by the image, and the remaining features are deliberately left
out as deprecated, not meaningful in a container or not needed by this demo.

## Icinga Web Configuration

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
