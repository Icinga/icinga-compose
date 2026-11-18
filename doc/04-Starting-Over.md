# Starting Over

Some settings only take effect on the very first start (hostname, database
type, database passwords). To apply them later, or just to get a clean slate,
throw away all data and start fresh:

```shell
docker compose down -v
docker compose up
```
