#!/usr/bin/perl
require 5.6.1;

use strict;
use warnings;
use Config;

use ExtUtils::MakeMaker;

# Store the version for later use
my $mm_version = $ExtUtils::MakeMaker::VERSION;

# avoid stupid 'Argument "6.30_01" isn't numeric in numeric ge (>=)' warnings;
# strip off the beta subversion noise that causes the trouble.
$mm_version =~ s/_\S+$//;      # "6.30_01" => "6.30"
$mm_version += 0;

if ($mm_version < 6.17) {
  die "SpamAssassin Makefile.PL requires at least ExtUtils::MakeMaker v6.17";
}

use constant RUNNING_ON_WINDOWS => ($^O =~ /^(mswin|dos|os2)/oi);
use constant HAS_DBI => eval { require DBI; };

my @ATT_KEYS = (
  # PLEASE READ THE FILE 'PACKAGING' FOR INFORMATION ON THESE VARIABLES.
  #
  # (Current) EU::MMs make a difference between these three possible general
  # install destinations. One can set INSTALLDIRS to 'perl', 'site' or
  # 'vendor' to choose one explicitly (the default is 'site'). They have the
  # following meaning:
  #  * PERL:    Only essential modules shipped with Perl should be installed
  #             there. Don't put SpamAssassin there.
  #  * SITE:    The default. Normal installations via CPAN or from the sources
  #             should use these dirs.
  #  * VENDOR:  A special set of paths for packaged (RPM, deb, portage, ...)
  #             Perl modules. Not always (correctly) used but the intention
  #             is to keep the system from overwriting the modules installed
  #             by the user.
  #
  # See also
  # <http://search.cpan.org/author/MSCHWERN/ExtUtils-MakeMaker-6.16/lib/ExtUtils/MakeMaker.pm#Default_Makefile_Behaviour>
  # <http://www.debian.org/doc/packaging-manuals/perl-policy/ch-module_packages.html#s-vendor_dirs>
  # <http://archive.develooper.com/perl5-porters@perl.org/msg94113.html>
  # <https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=78053>
  # <http://www.mail-archive.com/makemaker@perl.org/msg00779.html>
  #
  # The options SYSCONFDIR, DATADIR and CONFDIR all support those three
  # possibilities. The '*' in the following comments refers to those.

  'SYSCONFDIR',       # Overwrite all $*SYSCONFDIRs; normally determined
  'PERLSYSCONFDIR',   # based on $*PREFIX.
  'SITESYSCONFDIR',   #
  'VENDORSYSCONFDIR', #

  'DATADIR',          # Overwrite all INSTALL*DATAs; normally determined
  'INSTALLDATA',      # based on $*PREFIX.
  'INSTALLSITEDATA',  #
  'INSTALLVENDORDATA',#

  'CONFDIR',          # Overwrite all INSTALL*CONFs; normally determined
  'INSTALLCONF',      # based on $*SYSCONFDIR.
  'INSTALLSITECONF',  #
  'INSTALLVENDORCONF',#

  'DEFRULESDIR',      # A synonym for 'DATADIR'.
  'LOCALRULESDIR',    # " "       "   'CONFDIR'.

  'LOCALSTATEDIR',    # normally determined based on $*PREFIX.
  'PERLLOCALSTATEDIR', 
  'SITELOCALSTATEDIR', 
  'VENDORLOCALSTATEDIR',

  'PERL_BIN',         # Sets the Perl interpreter used by the scripts.
  'PERL_WARN',        # Can be used to disable warnings in the scripts
  'PERL_TAINT',       # "   "  "    "  "    taint mode for the scripts (DON'T)


  'BUILD_SPAMC'  ,    # Set to 'no' to skip build of spamc.
  'ENABLE_SSL',       # Set to 'yes' to build spamc with SSL support.
  'CONTACT_ADDRESS',  # To not ask for the contact address, use this.
);


sub parse_arg {
  my($val, $name) = (@_);
  if ($val =~ /^($name)=["']?(.*?)["']?$/) {
    return $2;
  } else {
    return undef;
  }
}

sub bool {
  my($val, $def) = (@_, undef, undef);
  $def = 0          unless defined $def;
  return bool($def) unless defined $val;

  $val =~ s/^\s+|\s+$//g;
  return 0 if $val =~ /^(0|N(o)?|Off)$/i;
  return 1 if $val =~ /^(1|Y(es)?|On)$/i;
  return bool($def);
}
sub yesno {
  my($val, $def) = (@_, undef, undef);
  return 'yes' if bool($val, $def);
  return 'no';
}


my %opt = (
  'build_spamc'     => undef,
  'enable_ssl'      => undef,
  'contact_address' => undef,
  'destdir'         => undef,
);
ARGV: foreach (@ARGV) {
  foreach my $key (keys %opt) {
    my $val = parse_arg($_, uc($key));
    if (defined $val) {
      $opt{$key} = $val;
      next ARGV;
    }
  }
}






