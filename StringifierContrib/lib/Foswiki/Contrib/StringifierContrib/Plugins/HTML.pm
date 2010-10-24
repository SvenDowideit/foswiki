# Copyright (C) 2009-2010 Foswiki Contributors
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


package Foswiki::Contrib::StringifierContrib::Plugins::HTML;
use Foswiki::Contrib::StringifierContrib::Base;
our @ISA = qw( Foswiki::Contrib::StringifierContrib::Base );

my $html2text = $Foswiki::cfg{StringifierContrib}{html2text} || 'html2text';

__PACKAGE__->register_handler("text/html", ".html");

sub stringForFile {
    my ($self, $filename) = @_;
    
    # check it is a text file
    return '' unless ( -T $filename );

    my $cmd = $html2text . ' -ascii %FILENAME|F%';
    my ($text, $exit) = Foswiki::Sandbox->sysCommand($cmd, FILENAME => $filename);
    
    # encode text
    $text =~ s/<\?xml.*?\?>\s*//g;
    return $self->fromUtf8($text);
}

1;
