# Going Further

## Local Overrides: `compose.override.yml`

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

## Sending Metrics via OpenTelemetry

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

## More Icinga Web Modules

To enable additional modules shipped with the Icinga Web image, list them in
`.env`:

```env
ICINGAWEB_ENABLEDMODULES=module1,module2
```
