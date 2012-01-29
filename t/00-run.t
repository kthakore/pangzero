use strict;
use warnings;
use Time::HiRes;
use Capture::Tiny;
use Test::Most 'bail';

my $time                   = Time::HiRes::time;
$ENV{'PANGZERO_TEST'} = 1;

ok( -e 'bin/pangzero',     'bin/pangzero exists' );
is( system("$^X -e 1"), 0, "we can execute perl as $^X" );
my ($stdout, $stderr) = Capture::Tiny::capture { system("$^X bin/pangzero") };
$stdout             ||= '';
ok( !$stderr, 'pangzero ran ' . (Time::HiRes::time - $time) . ' seconds' );
ok( $stdout =~ /player killed/, 'Player got killed' );


if($stderr) {
    diag( "\$^X   = $^X");
    diag( "STDERR = $stderr");
}

pass 'Are we still alive? Checking for segfaults';

done_testing();
