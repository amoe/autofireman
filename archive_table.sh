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
final_output_file="${archive_prefix}/${output_file_name}"


echo "Dumping"
pg_dump -U postgres -d "$database" -t "\"$table\"" \
  | pv \
  | gzip -c9 > "$final_output_file"

echo "Test uncompress."

length=$(zcat "$final_output_file" | pv | wc -c)
if [ "$length" -le 0 ]; then 
    echo "Zero length dump?  BAILING!" >&2
    exit 1
fi

echo "Uncompressed length is $length"
ls -lh "$final_output_file"

read -p "Drop table (y/n)? " choice
case "$choice" in 
    y|Y)
        printf 'DROP TABLE "%s"' "$table" | psql -U postgres "$database"
        ;;
    n|N) 
        echo "Exiting without drop."
        ;;
    *) 
        echo "invalid"
        ;;
esac



