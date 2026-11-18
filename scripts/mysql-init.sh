# Sourced by the MariaDB entrypoint on first start (empty /var/lib/mysql)
hex() {
  printf %s "$1" | od -An -tx1 -v | tr -d ' \n'
}

# The password travels hex-encoded, so no character in it can break the SQL.
# IDENTIFIED BY takes only a literal, hence QUOTE() into a prepared statement.
init_database() {
  docker_process_sql <<EOF
CREATE DATABASE \`$1\`;
SET @password = CONVERT(UNHEX('$(hex "$3")') USING utf8mb4);
PREPARE grant_all FROM CONCAT('GRANT ALL ON \`$1\`.* TO ''$2''@''%'' IDENTIFIED BY ', QUOTE(@password));
EXECUTE grant_all;
DEALLOCATE PREPARE grant_all;
EOF
}

init_database director director "$DIRECTOR_DATABASE_PASSWORD"
init_database icingadb icingadb "$ICINGADB_DATABASE_PASSWORD"
init_database icingaweb icingaweb "$ICINGAWEB_DATABASE_PASSWORD"
init_database x509 x509 "$X509_DATABASE_PASSWORD"
