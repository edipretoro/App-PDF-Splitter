package App::PDF::Splitter;

use strict;
use warnings;

use Spreadsheet::Read;
use Getopt::Long::Descriptive;

__PACKAGE__->run() unless caller();

sub run {
  my ( $options, $usage ) = describe_options(
    '%c %o',
    [ 'path|p=s', 'path to the pdftk binary', { default => '/usr/bin/pdftk' } ],
    [ 'spreadsheet|s=s', 'path to the spreadsheet', { required => 1 } ],
    [ 'directory|d=s', 'path to the directory where the PDF are stored', { required => 1 } ],
    [],
    [ 'help|h', 'print usage message and exit' ],
  );
  print ( $usage->text ), exit if $options->help();
}

1;
