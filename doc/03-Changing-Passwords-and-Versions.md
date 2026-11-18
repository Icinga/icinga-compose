# Changing Passwords and Versions

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
the first start. Changing them later means [starting over](04-Starting-Over.md).

The database, Icinga 2 API and Redis passwords must not begin or end with
whitespace. They also end up in the generated Icinga Web configuration, whose
renderer strips leading and trailing whitespace from values, while the
database, Icinga 2 and Redis keep the original bytes. Authentication between
them would fail.
