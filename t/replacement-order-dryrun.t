#!/usr/bin/perl -wl

use Test::Simple tests => 9;
use File::Path qw(mkpath rmtree);
use File::Slurp;
use Data::Dumper;

my $BASE = 't/replacement-order-dryrun';
my $HOME = "$BASE/1";
my $TARGET = "$BASE/2";
my $PREFIX = "u";

# Set a debug environment
$ENV{HOME} = $HOME;

# 1
ok( mkpath("$HOME/.foobar/blatest/barba", "$TARGET") );

# 2 + 3
ok( write_file("$BASE/list", 'm d .foo*/bla*/bar* bar%3-bla%2-foo%1') );
ok( write_file("$BASE/config", "TARGETDIR=$TARGET\nFILELAYOUT=$PREFIX-\%s") );

# 4
ok( system("bin/unburden-home-dir -n -C $BASE/config -L $BASE/list > $BASE/output" ) == 0 );

# 5
my $wanted = <<EOF;
Create directory $TARGET
Symlinking $TARGET/u-barba-blatest-foobar ->  $HOME/.foobar/blatest/barba
EOF
ok( read_file("$BASE/output") eq $wanted );

# 5 - 7
ok( ! -e "$TARGET/$PREFIX-barba-blatest-foobar" );
ok( ! -l "$HOME/.foobar/blatest/barba" );
ok( -d "$HOME/.foobar/blatest/barba" );

# 8
ok( rmtree("$BASE") );