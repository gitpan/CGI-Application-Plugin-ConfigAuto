package CGI::Application::Plugin::ConfigAuto;

use strict;
use vars qw($VERSION @ISA  @EXPORT_OK);
require Exporter;
@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT_OK = qw(
    init_cfg
    cfg_file
    cfg
);

$VERSION = '1.00';

=pod 

=head1 NAME

CGI::Application::Plugin::ConfigAuto - Easy config file management for CGI::Application

=head1 SYNOPSIS

 use CGI::Application::Plugin::ConfigAuto (qw/cfg cfg_file/);

 # In your instance script
 my $app = WebApp->new();
 $app->cfg_file('../../config/config.pl');
 $app->run();

 sub my_run_mode {
    my $self = shift;

    # Access a config hash key directly 
    $self->cfg('field');
       
    # Return config as hash
    %CFG = $self->cfg; 

 } 


=head1 DESCRIPTION

CGI::Application::Plugin::ConfigAuto adds easy access to config file variables
to your L<CGI::Application|CGI::Application> modules.  Lazy loading is used to
prevent the config file from being parsed if no configuration variables are
accessed during the request.  In other words, the config file is not parsed
until it is actually needed. The L<Config::Auto|Config::Auto> package provides
the framework for this plugin.

=head1 RATIONALE

C<CGI::Application> promotes re-usable applications by moving a maximal amount
of code into modules. For an application to be fully re-usable without code changes,
it is also necessary to store configuration variables in a separate file.

This plugin supports multiple config files for a single application, allowing
config files to override each other in a particular order. This covers even
complex cases, where you have a global config file, and second local config
file which overrides a few variables.

This plugin can be called in either the instance script or the setup method.
It is recommended that you to declare your config file locations in the
instance scripts, where it will have minimum impact on your application. This
technique is ideal when you intend to reuse your module to support multiple
configuration files. If you have an application with multiple instance scripts
which share a single config file, you may prefer to call the plugin from the
setup() method.



=head1 DECLARING CONFIG FILE LOCATIONS

 # In your instance script
 my $app = WebApp->new();

 # Pass in an array of config files, and they will be processed in order.  
 $app->cfg_file('../../config/config.pl');

Your config files should be referenced using the syntax example above. The format 
is detected automatically using L<Config::Auto|Config::Auto>. It it known to support
the following formats: colon separated, space separated, equals separated, XML,
Perl code, and Windows INI. See that modules documentation for complete details. 

=head1 METHODS

=head2 cfg()

 # Access a config hash key directly 
 $self->cfg('field');
    
 # Return config as hash
 my %CFG = $self->cfg; 

 # return as hashref
 my $cfg_href = $self->cfg;
    
A method to access project configuration variables. The config
file is parsed on the first call with a perl hash representation stored in memory.    
Subsequent calls will use this version, rather than re-reading the file.

In list context, it returns the configuration data as a hash.
In scalar context, it returns the configuration data as a hashref.

=cut

sub cfg {
    my $self = shift;

    die "must call cfg_files() before calling cfg()." unless $self->{__CFG_FILES};

    if (!$self->{__CFG}) {
        require Config::Auto;
        # Read in config files in the order the appear in this array.
        my %combined_cfg;
        for my $file (@{ $self->{__CFG_FILES} }) {
            my $cfg = Config::Auto::parse($file);
            %combined_cfg = (%combined_cfg, %$cfg);
        }
        $self->{__CFG} = \%combined_cfg;
    }

    my $cfg = $self->{__CFG};
    my $field = shift;
    return $cfg->{$field} if $field;
    if (ref $cfg) {
        return wantarray ? %$cfg : $cfg;
    }
}

sub cfg_file {
    my $self = shift;
    my @cfg_files = @_;
    unless (scalar @cfg_files) { die "cfg_file: must have at least one config file." }
    $self->{__CFG_FILES} = \@cfg_files;
}

# =head2 init_cfg()
# 
#  # In your instance script
#  my $app = WebApp->new(
#  	PARAMS => {
#  		# Read in the config files, in the order they appear in this array. 
#  		config_files => ['../../config/config.pl'],
#  	}
#  );
# 
#  sub cgiapp_init  {
#     my $self = shift;
# 
#     $self->init_cfg;
# 
#  }



1;
__END__

=pod

=head1 FILE FORMAT HINTS

=head2  Perl

Here's a simple example of my favorite config file format: Perl.
Having the "shebang" line at the top helps C<Config::Auto> to identify
it as a Perl file. Also, be sure that your last statement returns a 
hash reference.

    #!/usr/bin/perl

    # directory path name
    $CFG{DIR} = '/home/mark/www';

    # website URL
    $CFG{URL} = 'http://mark.stosberg.com/';

    \%CFG;

=head1 LIMITATIONS

Currently there is not a way to specify explicity what format your config file
is, which means we rely on L<Config::Auto> to guess it correctly. This feature
may be added in the future in a backwards compatible way. 

=head1 SEE ALSO

L<CGI::Application|CGI::Application> 
L<CGI::Application::Plugin::ValidateRM|CGI::Application::Plugin::ValidateRM>
L<CGI::Application::Plugin::DBH|CGI::Application::Plugin::DBH>
perl(1)

=head1 AUTHOR

Mark Stosberg <mark@summersault.com>

=head1 LICENSE

Copyright (C) 2004 Mark Stosberg <mark@summersault.com>

This library is free software. You can modify and or distribute it under the same terms as Perl itself.

=cut

