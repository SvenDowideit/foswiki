use strict;

package DateTimePluginTests;

use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use strict;
use Foswiki::UI::Save;
use Error qw( :try );
use Foswiki::Plugins::DateTimePlugin;

my $fatwilly;

sub new {
    my $self = shift()->SUPER::new( 'DateTimePluginFunctions', @_ );
    return $self;
}

sub loadExtraConfig {
    my $this = shift;
    $this->SUPER::loadExtraConfig();

    $Foswiki::cfg{Plugins}{DateTimePlugin}{Enabled} = 1;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();

    $Foswiki::cfg{LocalSitePreferences} = "$this->{users_web}.SitePreferences";
    $fatwilly = $this->{session};
}

sub doTest {
    my ( $this, $actual, $expected, $assertFalse ) = @_;

    _trimSpaces($actual);
    _trimSpaces($expected);

    my $renderedActual =
      Foswiki::Func::expandCommonVariables( $actual, $this->{test_topic},
        $this->{test_web}, undef );
    my $renderedExpected =
      Foswiki::Func::expandCommonVariables( $expected, $this->{test_topic},
        $this->{test_web}, undef );

    if ($assertFalse) {
        $this->assert_str_not_equals( $renderedExpected, $renderedActual );
    }
    else {
        $this->assert_str_equals( $renderedExpected, $renderedActual );
    }
}

=pod

---++ Default

%DATETIME{}%

Assumes that the default format setting in configure is "$day $month $year".

=cut

sub test_default {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$day \$month \$year"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

All GMTIME supported formats
=cut

sub test_gmtime_format_seconds {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$seconds"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$seconds"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_minutes {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$minutes"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$minutes"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_hours {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$hours"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$hours"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_day {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$day"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_wday {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$wday"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$wday"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_dow {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$dow"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$dow"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_week {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$week"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$week"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_month {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$month"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$month"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_mo {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$mo"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$mo"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_month_long {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/12/31 23:59:59" format="\$month_long"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
December
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_year {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$year"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$year"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_ye {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$ye"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$ye"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_tz {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$tz"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$tz"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_iso {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$iso"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$iso"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_rcs {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$rcs"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$rcs"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_http {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$http"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$http"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_gmtime_format_epoch {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$epoch"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$epoch"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

DEPRECATED FORMATS

=cut

sub test_deprecated_format_sec {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$sec"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$seconds"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_deprecated_format_min {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$min"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$minutes"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_deprecated_format_hour {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$hour"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$hours"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_deprecated_format_lmonth {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$lmonth"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%DATETIME{format="\$month_long"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_deprecated_format_i_month {
    my $this = shift;

    $this->_setSitePref( 'LANGUAGE', 'pt' );
    my $t = new Foswiki( $this->{test_user_login} );
    $t->enterContext('DateTimePluginEnabled');

    my $source = <<END_SOURCE;
%LANGUAGE% %DATETIME{format="\$i_month"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
pt %DATETIME{format="\$month" language="%LANGUAGE%"}%
END_EXPECTED

    $this->doTest( $source, $expected );

    $t->finish();
}

sub test_deprecated_format_i_lmonth {
    my $this = shift;

    $this->_setSitePref( 'LANGUAGE', 'pt' );
    my $t = new Foswiki( $this->{test_user_login} );
    $t->enterContext('DateTimePluginEnabled');

    my $source = <<END_SOURCE;
%LANGUAGE% %DATETIME{format="\$i_lmonth"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
pt %DATETIME{format="\$month_long" language="%LANGUAGE%"}%
END_EXPECTED

    $this->doTest( $source, $expected );

    $t->finish();
}

sub test_deprecated_format_lwday {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$lwday"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%DATETIME{format="\$wday_long"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_deprecated_format_i_wday {
    my $this = shift;

    $this->_setSitePref( 'LANGUAGE', 'pt' );
    my $t = new Foswiki( $this->{test_user_login} );
    $t->enterContext('DateTimePluginEnabled');

    my $source = <<END_SOURCE;
%LANGUAGE% %DATETIME{format="\$i_wday"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
pt %DATETIME{format="\$wday" language="%LANGUAGE%"}%
END_EXPECTED

    $this->doTest( $source, $expected );

    $t->finish();
}

sub test_deprecated_format_i_lwday {
    my $this = shift;

    $this->_setSitePref( 'LANGUAGE', 'pt' );
    my $t = new Foswiki( $this->{test_user_login} );
    $t->enterContext('DateTimePluginEnabled');

    my $source = <<END_SOURCE;
%LANGUAGE% %DATETIME{format="\$i_lwday"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
pt %DATETIME{format="\$wday_long" language="%LANGUAGE%"}%
END_EXPECTED

    $this->doTest( $source, $expected );

    $t->finish();
}

=pod

Additional formats

=cut

sub test_format_month_long {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$month_long"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
October
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_format_wday_long {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$wday_long"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
Tuesday
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

---++ Set date GMTIME format

%DATETIME{format="$day $month $year" date="%GMTIME{\"$day $month $year\"}%"}%

Assumes that the default format setting in configure is "$day $month $year".

=cut

sub test_set_date_GMTIME {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year" date="%GMTIME{\"\$day \$month \$year\"}%"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$day \$month \$year"}%
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

---++ Set date specific

%DATETIME{format="$day $month $year" date="2 Jul 2008 - 14:15:32"}%
%DATETIME{format="$day $month $year" date="2 Jul 1971"}%

Note: does not work yet with dates before 1970!

=cut

sub test_set_date_specific {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year" date="2 Jul 1969"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
02 Jul 1969
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_set_date_specific_hour_minutes_seconds {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year" date="2 Jul 2008 - 14:15:32"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
02 Jul 2008
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

---++ Set date format

Note: does not work yet with dates before 1970!

=cut

sub test_set_date_input_variations {
    my $this = shift;
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="31 Dec 2001"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 00:00
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="31 Dec 2001 - 23:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001/12/31 23:59:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001.12.31.23.59.59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001/12/31 23:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001.12.31.23.59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001-12-31 23:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001-12-31 - 23:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001-12-31T23:59:59"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001-12-31T23:59:59+01:00"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 22:59
END_EXPECTED
    );
    $this->doTest(
        <<END_RAW,
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="2001-12-31T23:59Z"}%
END_RAW
        <<END_EXPECTED
31 Dec 2001 - 23:59
END_EXPECTED
    );
}

sub test_set_date_epoch {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="1009843140 "}%
END_SOURCE

    my $expected = <<END_EXPECTED;
31 Dec 2001 - 23:59
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_set_date_epoch_0 {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="0"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
01 Jan 1970 - 00:00
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_set_date_epoch_minus {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="-100000"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
30 Dec 1969 - 20:13
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_set_date_epoch_float {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{format="\$day \$month \$year - \$hours:\$minutes" date="100000.5"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
02 Jan 1970 - 03:46
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

---++ Date relative

Note: does not work yet with dates before 1970!

=cut

sub test_date_relative_incdays_positive {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="31 Dec 2001" incdays="1"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
01 Jan 2002
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

=cut

sub test_date_relative_incdays_negative {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="31 Dec 2001" incdays="-2"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
29 Dec 2001
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

=cut

sub test_date_relative_inchours_negative {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="31 Dec 2001 - 07:00" format="\$hours" inchours="-1"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
06
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

=cut

sub test_date_relative_incminutes_positive {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="31 Dec 2001" format="\$minutes" incminutes="15"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
15
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

=cut

sub test_date_relative_incseconds_positive {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="31 Dec 2001" format="\$seconds" incseconds="20"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
20
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

=cut

sub test_language_month_long {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$month_long" language="pt"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
Outubro
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_language_month {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$month" language="pt"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
Out
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_language_wday_long {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$wday_long" language="pt"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
Ter&ccedil;a-feira
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub test_language_wday {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/10/30 23:59:59" format="\$wday" language="pt"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
Ter
END_EXPECTED

    $this->doTest( $source, $expected );
}

=pod

Not current time: should ignore the offset.

=cut

sub test_timezone_setting {
    my $this = shift;

    my $currentTimezoneOffset =
      $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset};
    $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset} = -7;
    my $source = <<END_SOURCE;
%DATETIME{date="2001/06/30 23:59:59" format="\$hours"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
23
END_EXPECTED

    $this->doTest( $source, $expected );

    $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset} =
      $currentTimezoneOffset;
}

=pod

Not current time: should use the offset.

=cut

sub test_timezone_setting_current_time {
    my $this = shift;

    my $currentTimezoneOffset =
      $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset};
    $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset} = -5;
    my $source = <<END_SOURCE;
%DATETIME{format="\$hours"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
%GMTIME{"\$hours"}%
END_EXPECTED

    $this->doTest( $source, $expected, 1 );

    $Foswiki::cfg{Plugins}{DateTimePlugin}{TimezoneOffset} =
      $currentTimezoneOffset;
}

=pod

=cut

sub test_timezone_param {
    my $this = shift;

    my $source = <<END_SOURCE;
%DATETIME{date="2001/06/30 23:59:59" format="\$hours" timezoneoffset="-5"}%
END_SOURCE

    my $expected = <<END_EXPECTED;
18
END_EXPECTED

    $this->doTest( $source, $expected );
}

sub _trimSpaces {

    #my $text = $_[0]

    $_[0] =~ s/^[[:space:]]+//s;    # trim at start
    $_[0] =~ s/[[:space:]]+$//s;    # trim at end
}

=pod

Copied from PrefsTests.
Used to set the SKIN preference to text, so that the smaller response page is easier to handle.

=cut

sub _setSitePref {
    my ( $this, $pref, $val, $type ) = @_;
    my ( $web, $topic ) =
      $fatwilly->normalizeWebTopicName( '',
        $Foswiki::cfg{LocalSitePreferences} );
    $this->assert_str_equals( $web, $Foswiki::cfg{UsersWebName} );
    $this->_set( $web, $topic, $pref, $val, $type );
}

sub _setWebPref {
    my ( $this, $pref, $val, $type ) = @_;
    $this->_set( $this->{test_web}, $Foswiki::cfg{WebPrefsTopicName},
        $pref, $val, $type );
}

sub _set {
    my ( $this, $web, $topic, $pref, $val, $type ) = @_;
    $this->assert_not_null($web);
    $this->assert_not_null($topic);
    $this->assert_not_null($pref);
    $type ||= 'Set';

    my $user = $fatwilly->{user};
    $this->assert_not_null($user);
    my $topicObject = Foswiki::Store::load(address=>{web=>$web, topic=>$topic });
    my $text = $topicObject->text();
    $text =~ s/^\s*\* $type $pref =.*$//gm;
    $text .= "\n\t* $type $pref = $val\n";
    $topicObject->text($text);
    try {
        $topicObject->save();
    }
    catch Foswiki::AccessControlException with {
        $this->assert( 0, shift->stringify() );
    }
    catch Error::Simple with {
        $this->assert( 0, shift->stringify() || '' );
    };
}

1;
