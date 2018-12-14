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
    SELECT relname FROM pg_catalog.pg_class c
    INNER JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname !~ '^pg_toast'
";


for my $database (@$result) {
    my $dbh = DBI->connect(get_dsn($database), $username, $auth, \%attr);

    my $result2 = $dbh->selectcol_arrayref($list_tables_query);
    dump($result2);
    
    $dbh->disconnect;
}

