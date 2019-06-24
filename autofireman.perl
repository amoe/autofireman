#! /usr/bin/perl

use strict;
use warnings;
use v5.20.2;
use Data::Dump qw/dump/;
use File::Slurper qw/read_text/;
use Getopt::Long;
use autodie qw(:all);
use DBI;

# sudo sudo -u postgres perl autofireman.perl

# This configuration will do the equivalent of 'psql -U postgres' at the shell
my $driver = 'Pg';
my $data_source = "DBI:${driver}:";
my $username = 'postgres';
my $auth = undef;
my %attr = (RaiseError => 1);

my $dbh = DBI->connect($data_source, $username, $auth, \%attr);

my $qry = "
    SELECT pd.datname FROM pg_database pd WHERE pd.datistemplate IS FALSE
";

my $result = $dbh->selectcol_arrayref($qry);
$dbh->disconnect;


sub get_dsn {
    my $dbname = shift;
    my $data_source = "DBI:${driver}:dbname=${dbname}";
    return $data_source;
}


my $list_tables_query = "
    SELECT relname AS table_name, pg_total_relation_size(c.oid) AS size
    FROM pg_catalog.pg_class c
    INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname !~ '^pg_toast'
";


my @all_stats;

for my $database (@$result) {
    my $dbh = DBI->connect(get_dsn($database), $username, $auth, \%attr);

    my %attr = (Slice => {});
    # Use hashref and return the total size
    my $result2 = $dbh->selectall_arrayref($list_tables_query, \%attr);

    for my $record (@$result2) {
        push @all_stats, {
            table_name => $record->{table_name},
            table_size => $record->{size},
            database => $database
        };
    }
    
    $dbh->disconnect;
}

my @sorted = sort { $a->{table_size} <=> $b->{table_size} } @all_stats;


for my $rec (@sorted) {
    printf(
        "%d\t%s.%s\n",
        $rec->{table_size}, $rec->{database}, $rec->{table_name}
    );
}
