# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
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


package Foswiki::Contrib::Stringifier;
use strict;
use Foswiki::Contrib::Stringifier::Base;
our @ISA = qw( Foswiki::Contrib::Stringifier::Base );
use Carp;
use File::MMagic;
use File::Spec::Functions qw(rel2abs);

our $magic = File::MMagic->new();

sub stringFor {
  my ($class, $filename) = @_;

  return unless -r $filename;
  my $mime = $magic->checktype_filename($filename);
  my $self = $class->handler_for($filename, $mime)->new();

  #print STDERR "file $filename is a $mime ... using $self\n";

  return $self->stringForFile($filename);
}

1;

