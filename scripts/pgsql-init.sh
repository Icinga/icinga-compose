# Sourced by the Postgres entrypoint on first start (empty data dir)

# Like MARIADB_RANDOM_ROOT_PASSWORD, which the Postgres image lacks
random_password="$(head -c 24 /dev/urandom | base64)"
docker_process_sql <<<"ALTER USER CURRENT_USER WITH PASSWORD '$random_password';"
echo "GENERATED POSTGRES PASSWORD: $random_password"
unset random_password

hex() {
  printf %s "$1" | od -An -tx1 -v | tr -d ' \n'
}

# The password travels hex-encoded, so no character in it can break the SQL.
# CREATE USER takes only a literal, hence format() into a dynamic statement.
init_database() {
  docker_process_sql <<EOF
DO \$\$BEGIN
EXECUTE format('CREATE USER $2 WITH PASSWORD %L', convert_from(decode('$(hex "$3")', 'hex'), 'UTF8'));
END\$\$;
CREATE DATABASE $1 OWNER $2;
EOF
}

init_database director director "$DIRECTOR_DATABASE_PASSWORD"
init_database icingadb icingadb "$ICINGADB_DATABASE_PASSWORD"
init_database icingaweb icingaweb "$ICINGAWEB_DATABASE_PASSWORD"
init_database x509 x509 "$X509_DATABASE_PASSWORD"
