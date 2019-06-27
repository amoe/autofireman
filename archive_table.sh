#! /bin/sh

set -e

database=$1
table=$2

if [ "$(id -u)" -ne 0 ]; then
    echo "you are not root" >&2
    exit 1
fi

if [ -z "$database" -o -z "$table" ]; then
    echo "need database and table" >&2
    exit 1
fi

archive_prefix=/archive/pg
output_file_name="${database}.${table}.sql.gz"


pg_dump -U postgres -d "$database" -t "$table" \
  | pv \
  | gzip -c9 > "${archive_prefix}/${output_file_name}"

printf 'DROP TABLE "%s"' "$table" | psql -U postgres "$database"
