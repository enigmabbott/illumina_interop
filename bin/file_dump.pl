#!/usr/bin/env lims-perl

use strict;
use warnings FATAL => 'all';
use IlluminaSAV::QMetricsOut;
use Data::Dumper;

die unless @ARGV;
my $q =IlluminaSAV::QMetricsOut->new(file =>$ARGV[0]);

print Dumper $q->file_data;


