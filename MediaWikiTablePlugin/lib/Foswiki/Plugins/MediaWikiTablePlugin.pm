# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2006-2010 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package Foswiki::Plugins::MediaWikiTablePlugin;

use strict;
use Foswiki::Func ();
our $VERSION = '$Rev$';
our $RELEASE = '1.31';
our $NO_PREFS_IN_TOPIC = 1;
our $SHORTDESCRIPTION = 'Format tables the <nop>MediaWiki way';
our $doneInit = 0;

###############################################################################
sub initPlugin { 
  $doneInit = 0;
  return 1; 
}

###############################################################################
sub preRenderingHandler {
  handleMWTable($_[0]) if $_[0] =~ /(^|[\n\r])\s*{\|/;
}

###############################################################################
sub init {

  return if $doneInit;
  $doneInit = 1;

  require Foswiki::Plugins::MediaWikiTablePlugin::Core;
  Foswiki::Func::addToZone('head', 'MEDIAWIKITABLEPLUGIN:CSS', <<'HERE');
<link rel="stylesheet" href="%PUBURLPATH%/%SYSTEMWEB%/MediaWikiTablePlugin/styles.css" type="text/css" media="all" />
HERE

}


###############################################################################
sub handleMWTable {
  init();
  return Foswiki::Plugins::MediaWikiTablePlugin::Core::handleMWTable(@_);
}

1;
