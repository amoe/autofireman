#! /usr/bin/perl

use strict;
use warnings;
use v5.20.2;
use Data::Dump qw/dump/;
use File::Slurper qw/read_text/;
use Getopt::Long;
use autodie qw(:all);
use DBI;

# This configuration will do the equivalent of 'psql -U postgres' at the shell
my $driver = 'Pg';
my $data_source = "DBI:${driver}:";
my $username = 'postgres';
my $auth = undef;
my %attr = (RaiseError => 1);

my $dbh = DBI->connect($data_source, $username, $auth, \%attr);
