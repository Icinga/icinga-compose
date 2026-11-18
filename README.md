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

## Documentation

The full documentation lives in [doc/](doc/01-About.md):

1. [About](doc/01-About.md)
2. [Quick Start](doc/02-Quick-Start.md), including PostgreSQL
3. [Changing Passwords and Versions](doc/03-Changing-Passwords-and-Versions.md)
4. [Starting Over](doc/04-Starting-Over.md)
5. [What's Inside](doc/05-Whats-Inside.md)
6. [Going Further](doc/06-Going-Further.md)
7. [Under the Hood](doc/07-Under-the-Hood.md)

## Quick Start

```shell
cp .env.example .env
docker compose up
```

Then log in at <http://localhost:8080/> as **icingaadmin** / **icinga**.
You need Docker Compose v2.35+ on Docker Engine 28.1+, or an equally recent Podman Compose.
See [Quick Start](doc/02-Quick-Start.md) for details.
