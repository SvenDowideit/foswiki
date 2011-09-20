# Copyright (C) 2009-2011 Foswiki Contributors
#
# For licensing info read LICENSE file in the Foswiki root.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at 
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Contrib::Stringifier::Plugins::DOC_wv;
use Foswiki::Contrib::Stringifier::Base ();
use Foswiki::Contrib::Stringifier ();
our @ISA = qw( Foswiki::Contrib::Stringifier::Base );
use File::Temp qw/tempdir/;

my $wvHtml = $Foswiki::cfg{StringifierContrib}{wvHtmlCmd} || 'wvHtml';

if (!defined($Foswiki::cfg{StringifierContrib}{WordIndexer}) || 
    ($Foswiki::cfg{StringifierContrib}{WordIndexer} eq 'wv')) {
    # Only if wv exists, I register myself.
    if (__PACKAGE__->_programExists($wvHtml)){
        __PACKAGE__->register_handler("application/word", ".doc");
    }
}


sub stringForFile {
    my ($self, $file) = @_;

    my $tmp_dir = tempdir();
    my $tmp_file = $tmp_dir."/output.html";

    my $in;
    my $text = '';
    
    my $cmd = $wvHtml . ' --charset=utf8 --targetdir=%TMPDIR|F% %FILENAME|F% %TMPFILE|F%';
    my ($output, $exit) = Foswiki::Sandbox->sysCommand($cmd, 
      TMPDIR => $tmp_dir, 
      FILENAME => $file, 
      TMPFILE => $tmp_file,
    );
    
    return '' unless ($exit == 0);

    $text = Foswiki::Contrib::Stringifier->stringFor($tmp_file);

    # Deletes temp files (main html and images)
    unlink($tmp_file);
    $self->rmtree($tmp_dir);

    return $text;
}

1;
