# Quick Start

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
later means [starting over](04-Starting-Over.md).

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
`docker compose up` again (see [Starting Over](04-Starting-Over.md)).
