#!/bin/sh

case "$DATABASE_TYPE" in
	mysql) port=3306 ;;
	pgsql) port=5432 ;;
	*) echo 'Unsupported $DATABASE_TYPE' >&2; exit 1 ;;
esac

until nc -vz "$DATABASE_TYPE" "$port"; do
	sleep 1
done
