
=pod

---+ package Foswiki::Plugins::LinkedInPlugin


=cut

package Foswiki::Plugins::LinkedInPlugin;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

our $VERSION           = '$Rev$';
our $RELEASE           = '1.0.4';
our $SHORTDESCRIPTION  = 'Add LinkedIn Widgets to your Foswiki';
our $NO_PREFS_IN_TOPIC = 1;

=begin TML

=cut

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerTagHandler( 'SHARE',   \&SHARE );
    Foswiki::Func::registerTagHandler( 'PROFILE', \&PROFILE );

    Foswiki::Func::registerRESTHandler( 'example', \&restExample );
    return 1;
}

sub SHARE {
    my ( $session, $params, $topic, $web, $topicObject ) = @_;

    my $url =
      Foswiki::urlEncode( $params->{_DEFAULT}
          || $params->{url}
          || Foswiki::Func::getScriptUrl( $web, $topic, 'view' ) );
    my $title =
      Foswiki::urlEncode( $params->{title}
          || Foswiki::Func::spaceOutWikiWord($topic) );
    my $summary =
      Foswiki::urlEncode( $params->{summary}
          || Foswiki::Func::spaceOutWikiWord($topic) );
    my $source = Foswiki::urlEncode(
        $params->{source} || Foswiki::Func::spaceOutWikiWord(
            Foswiki::Func::getWikiName( Foswiki::Func::getCanonicalUserID() )
        )
    );

    my $shareto = $params->{shareto} || 'linkedin';
    Foswiki::Func::loadTemplate($shareto);

    my $html =
      Foswiki::Func::expandTemplate( '"share" URL="' 
          . $url
          . '" TITLE="'
          . $title
          . '" SUMMARY="'
          . $summary
          . '" SOURCE="'
          . $source
          . '"' );
    return $html;
}


=begin TML

---++ StaticMethod validateUrl($url) -> $url

Check that the url is valid and safe to use as a url. Method used for
validation with untaint(). Returns the url, or undef if it is invalid.

=cut

sub validateUrl {
    my $url = shift;
    
    #ignore any ? or # params
    if ($url =~ m|^(https?://)([a-zA-Z0-9.]*)(/[^#?]*)| ) {
        my $out = $1.$2.$3;
        if (lc($2) =~ /linkedin.com$/) {
            return $out;
        }
    }
    return;
}

my %valid_types = (
    inline=>1,
    hover=>1,
    click=>1,
    popup=>1
);

sub PROFILE {
    my ( $session, $params, $topic, $web, $topicObject ) = @_;

    my $user =
         $params->{_DEFAULT}
      || $params->{user}
      || Foswiki::Func::getWikiName( Foswiki::Func::getCanonicalUserID() );
    my $type = lc( $params->{type} ) || 'inline';
    $type = 'inline' if ( not defined($valid_types{$type}) );
    $type = 'click' if ($type eq 'popup');
    
    
    my $shareto = $params->{shareto} || 'linkedin';

    Foswiki::Func::loadTemplate($shareto);

    if ($user eq '%LINKEDINPLUGIN_DEFAULTPROFILE%') {
        $user = Foswiki::Func::getPreferencesValue( 'LINKEDINPLUGIN_DEFAULTPROFILE') || 'disabled';
    }

    my $url = $params->{url};
    if (defined($url))  {
        #need to untaint, and to confirm this is indeed a valid url to linkedin - not some spammers / hackers way to get the user's login
        $url = Foswiki::Sandbox::untaint( $url, \&validateUrl );
    }
    if (!defined($url))  {
        if (lc($user) eq 'disabled') {
            return Foswiki::Func::expandTemplate('profile:disabled');
        }
        $url = Foswiki::Func::expandTemplate('"profile:url" USER="' . $user . '"' );
    }

    my $html = Foswiki::Func::expandTemplate(
        '"profile" USER="' . $user . '" URL="' . $url . '" TYPE="' . $type . '"' );
    return $html;
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2011 SvenDowideit@fosiki.com

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 3
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
