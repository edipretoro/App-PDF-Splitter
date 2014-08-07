package App::PDF::Splitter;
# ABSTRACT: a simple script to extract relevant information from PDF files

use strict;
use warnings;

use Spreadsheet::Read;
use Getopt::Long::Descriptive;
use IPC::Run;
use Progress::Any;
use Progress::Any::Output;
Progress::Any::Output->set('TermProgressBarColor');

__PACKAGE__->run() unless caller();

sub run {
  my ( $options, $usage ) = describe_options(
    '%c %o',
    [ 'pdftk|p=s', 'path to the pdftk binary', { default => '/usr/bin/pdftk' } ],
    [ 'spreadsheet|s=s', 'path to the spreadsheet', { required => 1 } ],
    [ 'directory|d=s', 'path to the directory where the PDF are stored', { required => 1 } ],
    [],
    [ 'help|h', 'print usage message and exit' ],
  );

  print $usage->text() && exit if $options->help();

  my $spreadsheet = ReadData( $options->spreadsheet() );
  my $sheet = $spreadsheet->[1];

  my $first_row = 2;
  my $progress = Progress::Any->get_indicator( task => 'pdftk', target => $sheet->{maxcol} - $first_row );

  chdir( $options->directory() );

  foreach my $line ( $first_row .. $sheet->{maxrow}) {
    my @row = Spreadsheet::Read::row( $sheet, $line );
    $progress->update( message => $row[0] );
    next unless -e $row[0] . '.pdf';

    # delete the covers
    run_pdftk( $options->pdftk(), $row[0] . '.pdf', $row[1], $row[4], $row[0] . '-clean.pdf' ) if (defined( $row[1] ) && defined( $row[4] ));
    # extract the index
    run_pdftk( $options->pdftk(), $row[0] . '.pdf', $row[2], $row[3], $row[0] . '-index.pdf' ) if (defined( $row[2] ) && defined( $row[3] ));
  }

  $progress->finish();
}

sub run_pdftk {
  my ( $pdftk, $filename, $start, $end, $output ) = @_;
  my ( $in, $out, $err );
  my @cmd = (
    $pdftk,
    $filename,
    'cat',
    $start . '-' . $end,
    'output',
    $output
  );

  IPC::Run::run \@cmd, \$in, \$out, \$err or die "pdftk: $?\n";
}

1;
