use Test::More qw/no_plan/;
BEGIN { use_ok('CGI::Application::Plugin::ConfigAuto') };

use lib './t';
use strict;

$ENV{CGI_APP_RETURN_ONLY} = 1;

use TestAppBasic;
my $t1_obj = TestAppBasic->new();
   $t1_obj->cfg_file('t/basic_config.pl','t/empty_config.pl');
my $t1_output = $t1_obj->run();

is($t1_obj->cfg('test_key_1'),11,'cfg(), accessing a field directly');

my %cfg = $t1_obj->cfg;

is($cfg{test_key_2},22,'cfg(), returning whole hash');

my $href = $t1_obj->cfg;

is($href->{test_key_2},22,'cfg(), returning hashref');

is($t1_obj->cfg->{test_key_2},22,'cfg(), accessing hash key directly via hashref');

{
    my $a = TestAppBasic->new( PARAMS => { cfg_file => 't/basic_config.pl' } );
    is($a->cfg('test_key_1'),11,'cfg_file param with scalar');
}
{
    my $a = TestAppBasic->new( PARAMS => { cfg_file => ['t/basic_config.pl'] } );
    is($a->cfg('test_key_1'),11,'cfg_file param with arrayref');
}
{
    my $a = TestAppBasic->new( PARAMS => { config_files => 't/basic_config.pl' } );
    is($a->cfg('test_key_1'),11,'config_files param with scalar');
}
{
    my $a = TestAppBasic->new( PARAMS => { config_files => ['t/basic_config.pl'] } );
    is($a->cfg('test_key_1'),11,'config_files param with arrayref');
}

###

my $t2_obj = TestAppBasic->new();
   $t2_obj->cfg_file('t/basic_config.pl', {format => 'wrong'} );
   eval { $t2_obj->cfg };
ok($@,'death expected if cfg file format is wrong');

   $t2_obj->cfg_file('t/basic_config.pl', {format => 'perl'} );
   eval { $t2_obj->cfg };
   is($@,'', 'correct file format works');

   $t2_obj->cfg_file('t/empty_config.t','t/basic_config.pl', {format => 'perl'} );
   eval { $t2_obj->cfg };
   is($@,'', 'correct file format works with second file');

