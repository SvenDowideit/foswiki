package AccessControlTests;
use strict;
use warnings;

use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use Foswiki          ();
use Foswiki::Meta    ();
use Foswiki::Plugins ();
use Foswiki::Configure::Dependency ();

# For Anchor test
use Foswiki::UI ();

my $post11 = 0;

sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( 'AccessControl', @args );

    my $dep = new Foswiki::Configure::Dependency(
            type    => "perl",
            module  => "Foswiki",
            version => ">=1.2"
           );
    my ( $ok, $message ) = $dep->check();
    $post11 = $ok;

    return $self;
}

my $MrWhite;
my $MrBlue;
my $MrOrange;
my $MrGreen;
my $MrYellow;

sub set_up {
    my $this = shift;
    $this->SUPER::set_up();

    my $topicObject = Foswiki::Store->create(
        address=>{web=>$Foswiki::cfg{UsersWebName},
            topic=>$Foswiki::cfg{DefaultUserWikiName}}, 
            data=>{_text=>''}
    );
    $topicObject->save();
    $this->registerUser( 'white', 'Mr', "White", 'white@example.com' );
    $MrWhite = $this->{session}->{users}->getCanonicalUserID('white');
    $this->registerUser( 'blue', 'Mr', "Blue", 'blue@example.com' );
    $MrBlue = $this->{session}->{users}->getCanonicalUserID('blue');
    $this->registerUser( 'orange', 'Mr', "Orange", 'orange@example.com' );
    $MrOrange = $this->{session}->{users}->getCanonicalUserID('orange');
    $this->registerUser( 'green', 'Mr', "Green", 'green@example.com' );
    $MrGreen = $this->{session}->{users}->getCanonicalUserID('green');
    $this->registerUser( 'yellow', 'Mr', "Yellow", 'yellow@example.com' );
    $MrYellow = $this->{session}->{users}->getCanonicalUserID('yellow');

    $topicObject =
      Foswiki::Store->create( address=>{web=>$this->{users_web},
        topic=>"ReservoirDogsGroup"}, data=>{_text=><<"THIS"});
   * Set GROUP = MrWhite, $this->{users_web}.MrBlue
THIS
    $topicObject->save();

    return;
}

sub DENIED {
    my ( $this, $mode, $user, $web, $topic ) = @_;
    $web   ||= $this->{test_web};
    $topic ||= $this->{test_topic};
    my $topicObject = Foswiki::Store->load(address=>{web=> $web, topic=> $topic });
    $this->assert( !$topicObject->haveAccess( $mode, $user ),
        "$user $mode $web.$topic" );

    if ($post11) {
        require Foswiki::Address;
        $this->assert(
            !$this->{session}->access->haveAccess( $mode, $user, $topicObject ),
            "$user $mode $web.$topic" );
        $this->assert(
            !$this->{session}->access->haveAccess(
                $mode, $user, $topicObject->web, $topicObject->topic
            ),
            "$user $mode $web.$topic"
        );
        $this->assert(
            !$this->{session}->access->haveAccess(
                $mode, $user,
                Foswiki::Address->new(
                    web   => $topicObject->web,
                    topic => $topicObject->topic
                )
            ),
            "$user $mode $web.$topic"
        );
    }


    return;
}

sub PERMITTED {
    my ( $this, $mode, $user, $web, $topic ) = @_;
    $web   ||= $this->{test_web};
    $topic ||= $this->{test_topic};
    my $topicObject = Foswiki::Store->load(address=>{web=> $web, topic=> $topic });
    $this->assert( $topicObject->haveAccess( $mode, $user ),
        "$user $mode $web.$topic" );

    if ($post11) {
        require Foswiki::Address;
        $this->assert(
            $this->{session}->access->haveAccess( $mode, $user, $topicObject ),
            "$user $mode $web.$topic" );
        $this->assert(
            $this->{session}->access->haveAccess(
                $mode, $user, $topicObject->web, $topicObject->topic
            ),
            "$user $mode $web.$topic"
        );
        $this->assert(
            $this->{session}->access->haveAccess(
                $mode, $user,
                Foswiki::Address->new(
                    web   => $topicObject->web,
                    topic => $topicObject->topic
                )
            ),
            "$user $mode $web.$topic"
        );
    }

    return;
}

# Note: As we do not initialize with a query, the topic that topic prefs
# are initialized from is WebHome. Thus these tests also test reading a topic
# other than the current topic.

# Test that explicitly defined users are denied topic view
sub test_denytopic {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If DENYTOPIC is set to a list of wikinames
    * people in the list will be DENIED.
   * Set DENYTOPICVIEW = MrGreen
   * Set DENYTOPICVIEW = ,,MrYellow,,$this->{users_web}.MrOrange,%USERSWEB%.ReservoirDogsGroup,,,
THIS
    $topicObject->save();

    $this->createNewFoswikiSession( );

    $this->PERMITTED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that an empty DENYTOPIC doesn't deny anyone
sub test_empty_denytopic {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If DENYTOPIC is set to empty ( i.e. Set DENYTOPIC = )
    * access is PERMITTED _i.e _ no-one is denied access to this topic
   * Set DENYTOPICVIEW=
THIS
    $topicObject->save();

    $this->createNewFoswikiSession( );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->PERMITTED( "VIEW", $MrWhite );
    $this->PERMITTED( "view", $MrBlue );

    return;
}

# Test that an empty DENYTOPIC doesn't deny anyone
sub test_whitespace_denytopic {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If DENYTOPIC is set to empty ( i.e. Set DENYTOPIC = )
    * access is PERMITTED _i.e _ no-one is denied access to this topic
   * Set DENYTOPICVIEW =   
THIS
    $topicObject->save();

    $this->createNewFoswikiSession( );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->PERMITTED( "VIEW", $MrWhite );
    $this->PERMITTED( "view", $MrBlue );

    return;
}

# Test that an whitespace at the end of DENYTOPIC is ok
sub test_denytopic_whitespace {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If DENYTOPIC is set to empty ( i.e. Set DENYTOPIC = )
    * access is PERMITTED _i.e _ no-one is denied access to this topic
   * Set DENYTOPICVIEW = MrBlue  
THIS
    $topicObject->save();

    $this->createNewFoswikiSession( );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->PERMITTED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that explicitly defined ALLOWTOPIC excludes everyone else
sub test_allowtopic {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If ALLOWTOPIC is set
   1. people in the list are PERMITTED
   2. everyone else is DENIED
   * Set ALLOWTOPICVIEW = %USERSWEB%.MrOrange
THIS
    $topicObject->save();

    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that explicitly defined ALLOWTOPIC excludes everyone else
# Renew the session after each check to force refresh of any caches
sub test_allowtopic_a {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If ALLOWTOPIC is set
   1. people in the list are PERMITTED
   2. everyone else is DENIED
   * Set ALLOWTOPICVIEW = %USERSWEB%.MrOrange
THIS
    $topicObject->save();

    my $topicquery = Unit::Request->new("");
    $topicquery->path_info("/$this->{test_web}/$this->{test_topic}");

    # renew Foswiki, so WebPreferences gets re-read
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin}, $topicquery );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that explicitly defined ALLOWTOPIC excludes everyone else
# Renew the session after each check to force refresh of any caches,
# but don't provide a context,
sub test_allowtopic_b {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If ALLOWTOPIC is set
   1. people in the list are PERMITTED
   2. everyone else is DENIED
   * Set ALLOWTOPICVIEW = %USERSWEB%.MrOrange
THIS
    $topicObject->save();

    # renew Foswiki, so WebPreferences gets re-read
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that explicitly defined ALLOWTOPIC excludes everyone else
# Access control in META:PREFERENCE
sub test_allowtopic_c {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"});
If ALLOWTOPIC is set
   1. people in the list are PERMITTED
   2. everyone else is DENIED
THIS
    $topicObject->putKeyed(
        'PREFERENCE',
        {
            name  => "ALLOWTOPICVIEW",
            title => "ALLOWTOPICVIEW",
            type  => "Set",
            value => "%USERSWEB%.MrOrange MrYellow"
        }
    );
    $topicObject->save();

    # renew Foswiki, so WebPreferences gets re-read
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that DENYWEB works in a top-level web with no finalisation
sub test_denyweb {
    my $this = shift;
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
If DENYWEB is set to a list of wikiname
    * people in the list are DENIED access
   * Set DENYWEBVIEW = $this->{users_web}.MrOrange %USERSWEB%.MrBlue
THIS
    $topicObject->save();

    # renew Foswiki, so WebPreferences gets re-read
    $this->createNewFoswikiSession(  );
    $topicObject = Foswiki::Store->load(
        address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=>"Null points"}
    );
    $topicObject->save();
    $this->DENIED( "VIEW", $MrOrange );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->PERMITTED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that ALLOWWEB works in a top-level web with no finalisation
sub test_allow_web {
    my $this        = shift;
    my $topicObject = Foswiki::Store->load(
        address=>{web=>$this->{test_web}, topic=>$Foswiki::cfg{WebPrefsTopicName}},
        data=>{_text=><<"THIS"}
If ALLOWWEB is set to a list of wikinames
    * people in the list will be PERMITTED
    * everyone else will be DENIED
   * Set ALLOWWEBVIEW = MrGreen MrYellow MrWhite
THIS
    );
    $topicObject->save();

    # renew Foswiki, so WebPreferences gets re-read
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $topicObject = Foswiki::Store->load(
        address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=>"Null points"}
    );
    $topicObject->save();
    $this->DENIED( "VIEW", $MrOrange );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->PERMITTED( "VIEW", $MrWhite );
    $this->DENIED( "view", $MrBlue );

    return;
}

# Test that Web.UserName is equivalent to UserName in ACLs
sub test_webDotUserName {
    my $this        = shift;
    my $topicObject = Foswiki::Store->load(
        address=>{web=>$this->{test_web}, topic=>$this->{test_topic}},
        data=>{_text=><<"THIS"}
If ALLOWTOPIC is set
   1. people in the list are PERMITTED
   2. everyone else is DENIED
   * Set ALLOWTOPICVIEW = MrYellow,%USERSWEB%.MrOrange,Nosuchweb.MrGreen,%MAINWEB%.MrBlue,%SYSTEMWEB%.MrWhite
THIS
    );
    $topicObject->save();
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $this->PERMITTED( "VIEW", $MrOrange );
    $this->DENIED( "VIEW", $MrGreen );
    $this->PERMITTED( "VIEW", $MrYellow );
    $this->DENIED( "VIEW", $MrWhite );
    $this->PERMITTED( "view", $MrBlue );

    return;
}

sub _checkSettings {
    my ( $this, $meta ) = @_;

    $this->assert(
        !$meta->haveAccess( 'VIEW', $MrOrange ),
        " 'VIEW' $this->{test_web}.$this->{test_topic}"
    );
    $this->assert(
        $meta->haveAccess( 'VIEW', $MrGreen ),
        " 'VIEW' $this->{test_web}.$this->{test_topic}"
    );
    $this->assert(
        !$meta->haveAccess( 'VIEW', $MrYellow ),
        " 'VIEW' $this->{test_web}.$this->{test_topic}"
    );
    $this->assert(
        !$meta->haveAccess( 'VIEW', $MrWhite ),
        " 'VIEW' $this->{test_web}.$this->{test_topic}"
    );
    $this->assert(
        !$meta->haveAccess( 'VIEW', $MrBlue ),
        " 'VIEW' $this->{test_web}.$this->{test_topic}"
    );

    return;
}

# Test a * Set embedded in text
sub test_SetInText {
    my $this = shift;

    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"} );
   * Set ALLOWTOPICVIEW = %USERSWEB%.MrGreen
THIS
    $topicObject->save();
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}} );
    $this->_checkSettings($topicObject);

    return;
}

# Test a set in meta-data
sub test_setInMETA {
    my $this = shift;

    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=>'Empty'} );
    my $args = {
        name  => 'ALLOWTOPICVIEW',
        title => 'ALLOWTOPICVIEW',
        value => "%USERSWEB%.MrGreen",
        type  => "Set"
    };
    $topicObject->putKeyed( 'PREFERENCE', $args );
    $topicObject->save();
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}} );

    $this->_checkSettings($topicObject);

    return;
}

# Check that a PREFERENCE takes precedence over a setting in text
sub test_setInSetAndMETA {
    my $this = shift;

    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=><<"THIS"} );
   * Set ALLOWTOPICVIEW = %USERSWEB%.MrOrange
THIS
    my $args = {
        name  => 'ALLOWTOPICVIEW',
        title => 'ALLOWTOPICVIEW',
        value => "%USERSWEB%.MrGreen",
        type  => "Set"
    };
    $topicObject->putKeyed( 'PREFERENCE', $args );
    $topicObject->save();
    $this->createNewFoswikiSession( $Foswiki::cfg{AdminUserLogin} );
    $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}} );
    $this->_checkSettings($topicObject);

    return;
}

# Test that hierarchical subweb controls override the parent web
sub test_subweb_controls_override_parent {
    my $this   = shift;
    my $subweb = "$this->{test_web}.SubWeb";

    $Foswiki::cfg{EnableHierarchicalWebs} = 1;

    # First build a parent web with view restricted to MrGreen
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$this->{test_topic}}, data=>{_text=>"Nowt"} );
    $topicObject->save();

    $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
   * Set ALLOWWEBVIEW = MrGreen
THIS
    $topicObject->save();

    # Now build a subweb with view restricted to MrOrange
    my $webObject = Foswiki::Store->create(address=>{web=>$subweb});
    $webObject->populateNewWeb();
    $topicObject =
      Foswiki::Store->load(address=>{web=>$subweb,
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
   * Set ALLOWWEBVIEW = MrOrange
THIS
    $topicObject->save();

    # Ensure that MrOrange can read the subweb and MrGreen the parent web
    $this->createNewFoswikiSession(  );
    $this->PERMITTED( "VIEW", $MrOrange, $subweb );
    $this->DENIED( "VIEW", $MrGreen, $subweb );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrOrange );

    return;
}

# Test that controls are inherited from parent webs
sub test_subweb_inherits_from_parent {
    my $this   = shift;
    my $subweb = "$this->{test_web}.SubWeb";

    $Foswiki::cfg{EnableHierarchicalWebs} = 1;

    # First build a parent web with view restricted to MrGreen, and
    # finalise the setting
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
   * Set ALLOWWEBVIEW = MrGreen
   * Set FINALPREFERENCES = ALLOWWEBVIEW
THIS
    $topicObject->save();

    # Now build a subweb with no restrictions
    my $webObject = Foswiki::Store->create(address=>{web=>$subweb});
    $webObject->populateNewWeb();
    $topicObject =
      Foswiki::Store->load(address=>{web=>$subweb,
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
THIS
    $topicObject->save();
    $this->createNewFoswikiSession(  );
    $this->PERMITTED( "VIEW", $MrGreen, $subweb );
    $this->DENIED( "VIEW", $MrOrange, $subweb );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrOrange );

    return;
}

# Test that finalised controls in parent web override the subweb controls
sub test_finalised_parent_overrides_subweb {
    my $this   = shift;
    my $subweb = "$this->{test_web}.SubWeb";

    $Foswiki::cfg{EnableHierarchicalWebs} = 1;

    # First build a parent web with view restricted to MrGreen, and
    # finalise the setting
    my $topicObject =
      Foswiki::Store->load(address=>{web=>$this->{test_web},
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
   * Set ALLOWWEBVIEW = MrGreen
   * Set FINALPREFERENCES = ALLOWWEBVIEW
THIS
    $topicObject->save();

    # Now build a subweb with view restricted to MrOrange
    my $webObject = Foswiki::Store->create(address=>{web=>$subweb});
    $webObject->populateNewWeb();
    $topicObject =
      Foswiki::Store->load(address=>{web=>$subweb,
        topic=>$Foswiki::cfg{WebPrefsTopicName}}, data=>{_text=><<"THIS"});
   * Set ALLOWWEBVIEW = MrOrange
THIS
    $topicObject->save();
    $this->createNewFoswikiSession(  );
    $this->DENIED( "VIEW", $MrOrange, $subweb );
    $this->PERMITTED( "VIEW", $MrGreen, $subweb );
    $this->PERMITTED( "VIEW", $MrGreen );
    $this->DENIED( "VIEW", $MrOrange );

    return;
}

# As anchors are never sent by the browser, this is done through JS
# and only testable by Selenium
# Kept this test here as it is the only one I (Babar) know of doing the full
# Foswiki::UI chain, therefore catching the AccessControlExceptions
sub test_login_redirect_preserves_anchor {
    my $this       = shift;
    my $test_topic = 'TestAnchor';

    # Create a topic with an anchor, viewable only by MrYellow
    my $topicObject = Foswiki::Store->load(
        address=>{web=>$this->{test_web}, topic=>$test_topic},
        data=>{_text=><<"THIS"}
If there is an anchor, and some access restrictions,
anchor is preserved after login.
#anchor
   * Set ALLOWTOPICVIEW = MrYellow
THIS
    );
    $topicObject->save();

    # Request the page with the full UI
    my $query = Unit::Request->new(
        {
            webName   => [ $this->{test_web} ],
            topicName => ["$test_topic"],
        }
    );
    $query->path_info("/$this->{test_web}/$test_topic");
    $query->method('GET');
    $query->action('view');
    my $viewUrl =
      $this->{session}
      ->getScriptUrl( '0', 'view', $this->{test_web}, $test_topic );
    $query->uri("$viewUrl");
    my ($text) = $this->capture(
        sub {
            $Foswiki::Plugins::SESSION->{response} =
              Foswiki::UI::handleRequest($query);
        }
    );

    # Get the login URL to compare
    my $loginUrl =
      $this->{session}
      ->getScriptUrl( '0', 'login', $this->{test_web}, $test_topic );

    # Item11121: the test doesn't tolerate ShortURLs, for example.
    # ShortURLs may involve a {ScriptUrlPaths}{view} of '' or something
    # like '/foswiki' (where {ScriptUrlPath} looks like '/foswiki/bin').
    # In any case, the test is hard-wired to ignore {ScriptSuffix}
    if (    exists $Foswiki::cfg{ScriptUrlPaths}{view}
        and defined $Foswiki::cfg{ScriptUrlPaths}{view}
        and not $Foswiki::cfg{ScriptUrlPaths}{view} =~ /view$/ )
    {
        $this->expect_failure();
    }

    # Extract what we've been redirected to
    my ($redirect_to) = $text =~ /^Location: (.*?)\r?$/m;
    $this->assert_not_null( $redirect_to,
            "Request should have return a 302 to $loginUrl\n"
          . "But it returned:\n$text" );

    # Check the redirect contains the login url + view to this topic
    $this->assert_matches(
        qr#^$loginUrl.*/view/$this->{test_web}/$test_topic$#,
        $redirect_to,
        "Login did not redirect to a page with the proper anchor:\n"
          . "Location: $redirect_to\n"
          . "Expected: ^$loginUrl.*\%23anchor\$"
    );

    # Get the redirected page after login

    return;
}

1;
