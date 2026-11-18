# What's Inside

## Director Example

Director sets itself up on its own: it connects to Icinga 2, imports the
stack's own containers as hosts from `fileshipper/example/tcp.csv`, adds TCP,
SSL and HTTP checks for their ports (via the import sources and sync rules
in `scripts/director-basket.json`) and deploys the result. Watch them in
Icinga Web, or see how they're built under **Icinga Director > Automation**.

## Fileshipper Playground

Want to play with CSV imports without touching the example? Create a
`fileshipper/playground` directory (it's git-ignored), drop CSV files there
and add a new import source for them under **Icinga Director > Automation**.
Leave `fileshipper/example` as it is, since the Director example depends on it.

## x509 Certificate Monitoring

The x509 module is installed and its scanner is running, but there's nothing
to scan yet. Add a scan job under **Certificate Monitoring > Configuration**.

## Graphite

Icinga 2 writes performance data to Graphite, and Icinga Web shows the
graphs. Graphite's own web UI isn't published; see
[Going Further](06-Going-Further.md) if you want it.
