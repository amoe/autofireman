#! /usr/bin/perl

use strict;
use warnings;
use v5.20.2;
use Data::Dump qw/dump/;
use File::Slurper qw/read_text/;
use Getopt::Long;
use autodie qw(:all);
use DBI;

my $driver = 'Pg';
my $database = undef;
my $host = 'localhost';
my $port = 5432;

my $data_source = "DBI:${driver}:dbname=${database};host=${host};port=${port}";
my $username = 'postgres';
my $auth = undef;
my %attr = (RaiseError => 1);

my $dbh = DBI->connect($data_source, $username, $auth, \%attr);
