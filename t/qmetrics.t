#!/usr/bin/env lims-perl

use strict;
use warnings FATAL => 'all';
use Test::More;
use IlluminaSAV::QMetricsOut;
use Path::Class qw/file/;
use Data::Dumper;
use List::AllUtils qw/ max/;

=cut
example data_structure
my $sav =IlluminaSAV::QMetricsOut->new(file => $f);
my $file_data= $q->file_data;



'8' => {
       '32' => {
                 'q30' => 395368080,
                 'all_qscore_instances' => 414622601,
                 'bcl_count' => 96,
                 'all_qscores_weighted' => '16581693886'
               },
}
=cut

 my %subtest = ( 
                version4 => {file => './t/var/Version4/InterOp/QMetricsOut.bin',
                             max_cycle => 179
                            },
                version5 => {file => './t/var/Version5/InterOp/QMetricsOut.bin',
                             max_cycle => 310 
                            },
                version5_no_bin => {
                             file => './t/var/Version5NoBin/InterOp/QMetricsOut.bin',
                             max_cycle => 218,
                             lanes => 2
                            },

                version6 => {file => './t/var/Version6/InterOp/QMetricsOut.bin',
                             max_cycle => 310 
                            },

);

for (sort keys %subtest) {
    {
        no strict 'refs';
        subtest $_ => sub { &_qtester(%{$subtest{$_}}); };
    }
}

&done_testing;

sub _qtester {
    my %p = @_;
    my $file = $p{file};
    my $max_cycle = $p{max_cycle};
    my $lanes = $p{lanes} ? $p{lanes} : 8;

    my $f = file($file);
    ok($f->stat, 'file exists');

    my $sav =IlluminaSAV::QMetricsOut->new(file => $f);
    ok($sav, 'got qmetrics instance');

    my $file_data= $sav->file_data;
    ok(($file_data and %$file_data), 'got file data hash');

    is(scalar(keys %$file_data), $lanes, 'lanes match');
    ok($file_data->{$_}, "lane $_ exists")  for( 1 .. $lanes );

    
    my $lane_cycle_summary = $file_data->{1}->{$max_cycle};
    my @data_points =('q30', 'all_qscore_instances', 'bcl_count', 'all_qscores_weighted');
    for(@data_points){
       ok($lane_cycle_summary->{$_}, "$_ exists");
    }

    is(scalar(@data_points), scalar(keys %$lane_cycle_summary), 'data metrics matches');

    my $max_cycle_resolved= $sav->max_cycle;
    ok($max_cycle_resolved, 'got max cycle');
    is($max_cycle_resolved, $max_cycle, 'max cycles match');

    my $max_cycle_all_resolved= $sav->max_cycle_all_lanes;
    ok($max_cycle_all_resolved, 'got max cycle');
    is($max_cycle_all_resolved, $max_cycle, 'max cycles match');

    my $avg = $sav->average_qscore(start_cycle => 1 , end_cycle => 50, lane => 1);
    ok($avg, 'got avg ' . $avg);

    my $q30_pct= $sav->percent_qscore_greater_30(start_cycle => 1 , end_cycle => 50, lane => 1);
    ok($q30_pct , 'got q30_pct ' . $q30_pct);

}

