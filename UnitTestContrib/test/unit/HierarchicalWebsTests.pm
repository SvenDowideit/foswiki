use strict;

package HierarchicalWebsTests;
use FoswikiTestCase;
our @ISA = qw( FoswikiTestCase );

use Foswiki;
use Error qw( :try );

# Make sure it's a wikiname so we can check squab handling
my $testWeb           = 'TemporaryHierarchicalWebsTestsTestWeb';
my $testWebSubWeb     = 'SubWeb';
my $testWebSubWebPath = $testWeb . '/' . $testWebSubWeb;
my $testTopic         = 'Topic';

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();

    $Foswiki::cfg{EnableHierarchicalWebs} = 1;
    $Foswiki::cfg{Htpasswd}{FileName} = '$Foswiki::cfg{TempfileDir}/junkpasswd';
    $Foswiki::cfg{PasswordManager}    = 'Foswiki::Users::HtPasswdUser';
    $Foswiki::cfg{UserMappingManager} = 'Foswiki::Users::TopicUserMapping';
    $Foswiki::cfg{LoginManager}       = 'Foswiki::LoginManager::TemplateLogin';
    $Foswiki::cfg{Register}{EnableNewUserRegistration} = 1;

    try {
        $this->{session} = new Foswiki('AdminUser');

        my $webObject =
          Foswiki::Store->create( address => { web => $testWeb } );
        $webObject->populateNewWeb();
        $this->assert( $this->{session}->webExists($testWeb) );
        my $topicObject = Foswiki::Store::create(
            address =>
              { web => $testWeb, topic => $Foswiki::cfg{HomeTopicName} },
            data => { _text => "SMELL" }
        );
        $topicObject->save();
        $this->assert( $this->{session}
              ->topicExists( $testWeb, $Foswiki::cfg{HomeTopicName} ) );

        $webObject =
          Foswiki::Store->create( address => { web => $testWebSubWebPath } );
        $webObject->populateNewWeb();
        $this->assert( $this->{session}->webExists($testWebSubWebPath) );
        $topicObject = Foswiki::Store::create(
            address => {
                web   => $testWebSubWebPath,
                topic => $Foswiki::cfg{HomeTopicName}
            },
            data => { _text => "SMELL" }
        );
        $topicObject->save();
        $this->assert( $this->{session}
              ->topicExists( $testWebSubWebPath, $Foswiki::cfg{HomeTopicName} )
        );

    }
    catch Error::Simple with {
        $this->assert( 0, shift->stringify() || '' );
    };
}

sub tear_down {
    my $this = shift;

    unlink $Foswiki::cfg{Htpasswd}{FileName};
    $this->removeWebFixture( $this->{session}, $testWebSubWebPath );
    $this->removeWebFixture( $this->{session}, $testWeb );

    $this->SUPER::tear_down();
}

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub test_createSubSubWeb {
    my $this = shift;
    $this->{session}->finish();

    $this->{session} = new Foswiki();

    my $webTest = 'Item0';
    my $webObject =
      Foswiki::Store->create(
        address => { web => "$testWebSubWebPath/$webTest" } );
    $webObject->populateNewWeb();
    $this->assert( $this->{session}->webExists("$testWebSubWebPath/$webTest") );

    $webTest = 'Item0_';
    $webObject =
      Foswiki::Store->create(
        address => { web => "$testWebSubWebPath/$webTest" } );
    $webObject->populateNewWeb();
    $this->assert( $this->{session}->webExists("$testWebSubWebPath/$webTest") );
}

sub test_createSubWebTopic {
    my $this = shift;
    $this->{session}->finish();
    $this->{session} = new Foswiki();
    my $topicObject = Foswiki::Store::create(
        address => { web   => $testWebSubWebPath, topic => $testTopic },
        data    => { _text => "page stuff\n" }
    );
    $topicObject->save();
    $this->assert(
        $this->{session}->topicExists( $testWebSubWebPath, $testTopic ) );
}

sub test_include_subweb_non_wikiword_topic {
    my $this = shift;
    $this->{session}->finish();
    $this->{session} = new Foswiki();
    my $user = $this->{session}->{user};

    my $baseTopic    = 'IncludeSubWebNonWikiWordTopic';
    my $includeTopic = 'Topic';
    my $testText     = 'TEXT';

    # create the (including) page
    my $topicObject = Foswiki::Store::create(
        address => { web   => $testWebSubWebPath, topic => $baseTopic },
        data    => { _text => <<__TOPIC__ } );
%INCLUDE{ "$testWebSubWebPath/$includeTopic" }%
__TOPIC__
    $topicObject->save();
    $this->assert(
        $this->{session}->topicExists( $testWebSubWebPath, $baseTopic ) );

    # create the (included) page
    $topicObject = Foswiki::Store::create(
        address => { web   => $testWebSubWebPath, topic => $includeTopic },
        data    => { _text => $testText }
    );
    $topicObject->save();
    $this->assert(
        $this->{session}->topicExists( $testWebSubWebPath, $includeTopic ) );

    # verify included page's text
    $topicObject = Foswiki::Store::load(
        address => { web => $testWebSubWebPath, topic => $includeTopic } );
    $this->assert_matches( qr/$testText\s*$/, $topicObject->text );

    # base page should evaluate (more or less) to the included page's text
    $topicObject =
      Foswiki::Store->load(
        address => { web => $testWebSubWebPath, topic => $baseTopic } );
    my $text = $topicObject->text;
    $text = $topicObject->expandMacros($text);
    $this->assert_matches( qr/$testText\s*$/, $text );
}

sub test_create_subweb_with_same_name_as_a_topic {
    my $this = shift;
    $this->{session}->finish();
    $this->{session} = new Foswiki();
    my $user = $this->{session}->{user};

    my $testTopic = 'SubWeb';
    my $testText  = 'TOPIC';

    # create the page
    my $topicObject = Foswiki::Store::create(
        address => { web   => $testWebSubWebPath, topic => $testTopic },
        data    => { _text => $testText }
    );
    $topicObject->save();
    $this->assert(
        $this->{session}->topicExists( $testWebSubWebPath, $testTopic ) );

    my $meta =
      Foswiki::Store->load(
        address => { web => $testWebSubWebPath, topic => $testTopic } );
    $this->assert_matches( qr/$testText\s*$/, $topicObject->text );

    # create the subweb with the same name as the page
    my $webObject =
      Foswiki::Store->create(
        address => { web => "$testWebSubWebPath/$testTopic" } );
    $webObject->populateNewWeb();
    $this->assert(
        $this->{session}->webExists("$testWebSubWebPath/$testTopic") );

    $topicObject =
      Foswiki::Store->load(
        address => { web => $testWebSubWebPath, topic => $testTopic } );
    $this->assert_matches( qr/$testText\s*$/, $topicObject->text );

    Foswiki::Store::remove( address => $webObject );

    $this->assert(
        !$this->{session}->webExists("$testWebSubWebPath/$testTopic") );
}

sub test_createSubweb_missingParent {
    my $this = shift;
    use Error qw( :try );
    use Foswiki::AccessControlException;

    $this->createNewFoswikiSession();

    my $user = $this->{session}->{user};

    try {
        my $webObject =
          Foswiki::Store->create( address => { web => "Missingweb/Subweb" } );
        $webObject->populateNewWeb();
        $this->assert('No error thrown from populateNewWe() ');
    }
    catch Error::Simple with {
        my $e = shift;
        $this->assert_matches( qr/^Parent web Missingweb does not exist.*/,
            $e, "Unexpected error $e" );
    };
    $this->assert( !$this->{session}->webExists("Missingweb/Subweb") );
    $this->assert( !$this->{session}->webExists("Missingweb") );
}

sub test_createWeb_InvalidBase {
    my $this = shift;
    use Error qw( :try );
    use Foswiki::AccessControlException;

    $this->createNewFoswikiSession();

    my $user = $this->{session}->{user};

    my $webTest = 'Item0';
    my $webObject =
      Foswiki::Store->create(
        address => { web => "$testWebSubWebPath/$webTest" } );

    try {
        $webObject->populateNewWeb("Missingbase");
        $this->assert('No error thrown from populateNewWe() ');
    }
    catch Error::Simple with {
        my $e = shift;
        $this->assert_matches( qr/^Template web Missingbase does not exist.*/,
            $e, "Unexpected error $e" );
    };
    $this->assert(
        !$this->{session}->webExists("$testWebSubWebPath/$webTest") );
}

sub test_createWeb_hierarchyDisabled {
    my $this = shift;
    use Error qw( :try );
    use Foswiki::AccessControlException;
    $Foswiki::cfg{EnableHierarchicalWebs} = 0;

    $this->{test_web} = '$testWeb';
    $this->createNewFoswikiSession();

    my $user = $this->{session}->{user};

    my $webTest = 'Item0';
    my $webObject =
      Foswiki::Store->create(
        address => { web => "$testWebSubWebPath/$webTest" . 'x' } );

    try {
        $webObject->populateNewWeb();
        $this->assert('No error thrown from populateNewWe() ');
    }
    catch Error::Simple with {
        my $e = shift;
        $this->assert_matches(
            qr/^Unable to create .* Hierarchical webs are disabled.*/,
            $e, "Unexpected error '$e'" );
    };
    $this->assert(
        !$this->{session}->webExists( "$testWebSubWebPath/$webTest" . 'x' ) );
}

sub test_url_parameters {
    my $this = shift;
    $this->createNewFoswikiSession();
    my $user = $this->{session}->{user};

    my $topicquery;

    # Now query the subweb path. We should get the webhome of the subweb.
    $topicquery = new Unit::Request(
        {
            action => 'view',
            topic  => "$testWebSubWebPath",
        }
    );

    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName},
        $topicquery );

    # Item3243:  PTh and haj suggested to change the spec
    $this->assert_str_equals( $testWeb,       $this->{session}->{webName} );
    $this->assert_str_equals( $testWebSubWeb, $this->{session}->{topicName} );

    # make a topic with the same name as the subweb. Now the previous
    # query should hit that topic
    my $topicObject = Foswiki::Store->create(
        address => { web   => $testWeb, topic => $testWebSubWeb },
        data    => { _text => "nowt" }
    );
    $topicObject->save();

    $topicquery = new Unit::Request(
        {
            action => 'view',
            topic  => "$testWebSubWebPath",
        }
    );

    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName},
        $topicquery );

    $this->assert_str_equals( $testWeb,       $this->{session}->{webName} );
    $this->assert_str_equals( $testWebSubWeb, $this->{session}->{topicName} );

    # try a query with a non-existant topic in the subweb.
    $topicquery = new Unit::Request(
        {
            action => 'view',
            topic  => "$testWebSubWebPath/NonExistant",
        }
    );

    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName},
        $topicquery );

    $this->assert_str_equals( $testWebSubWebPath, $this->{session}->{webName} );
    $this->assert_str_equals( 'NonExistant', $this->{session}->{topicName} );

    # Note that this implictly tests %TOPIC% and %WEB% expansions, because
    # they come directly from {webName}
}

# Check expansion of [[TestWeb]] in TestWeb/NonExistant
# It should expand to creation of topic TestWeb
sub test_squab_simple {
    my $this = shift;

    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName}, $query );

    my $text = "[[$testWeb]]";
    my $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);
    $this->assert_matches(
qr!<span class="foswikiNewLink">$testWeb<a.*href=".*edit$Foswiki::cfg{ScriptSuffix}/$testWeb/$testWeb\?topicparent=$testWeb.NonExistant"!,
        $text
    );
}

# Check expansion of [[SubWeb]] in TestWeb/NonExistant.
# It should expand to a create link to the TestWeb/SubWeb topic with
# TestWeb.WebHome as the parent
sub test_squab_subweb {
    my $this = shift;

    # Make a query that should set topic=$testSubWeb
    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName}, $query );

    my $text = "[[$testWebSubWeb]]";
    my $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);
    $this->assert_matches(
qr!<span class="foswikiNewLink">$testWebSubWeb<a.*href=".*edit$Foswiki::cfg{ScriptSuffix}/$testWeb/$testWebSubWeb\?topicparent=$testWeb.NonExistant"!,
        $text
    );
}

# Check expansion of [[TestWeb.SubWeb]] in TestWeb/NonExistant.
# It should expand to create topic TestWeb/SubWeb
sub test_squab_subweb_full_path {
    my $this = shift;

    # Make a query that should set topic=$testSubWeb
    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName}, $query );

    my $text = "[[$testWeb.$testWebSubWeb]]";
    my $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);
    $this->assert_matches(
qr!<span class="foswikiNewLink">$testWeb.$testWebSubWeb<a.*href=".*edit$Foswiki::cfg{ScriptSuffix}/$testWeb/$testWebSubWeb\?topicparent=$testWeb.NonExistant"!,
        $text
    );
}

# Check expansion of [[SubWeb]] in TestWeb/NonExistant.
# It should expand to TestWeb/SubWeb
sub test_squab_subweb_wih_topic {
    my $this = shift;

    # Make a query that should set topic=$testSubWeb
    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName}, $query );

    my $topicObject = Foswiki::Store->create(
        address => { web   => $testWeb, topic => $testWebSubWeb },
        data    => { _text => "" }
    );
    $topicObject->save();
    $this->assert( $this->{session}->topicExists( $testWeb, $testWebSubWeb ) );

    my $text = "[[$testWebSubWeb]]";
    $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);
    my $scripturl =
      $this->{session}->getScriptUrl( 0, 'view' ) . "/$testWeb/$testWebSubWeb";
    $this->assert_matches( qr!<a href="$scripturl">$testWebSubWeb</a>!, $text );
}

# Check expansion of [[TestWeb.SubWeb]] in TestWeb/NonExistant.
# It should expand to TestWeb/SubWeb
sub test_squab_full_path_with_topic {
    my $this = shift;

    # Make a query that should set topic=$testSubWeb
    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->{session}->finish();

# SMELL:   If this call to getScriptUrl occurs before the finish() call
# It decides it is in $this->inContext('command_line') and returns
# absolute URLs.   Moving it here after the finish() and it returns relative URLs.
    my $scripturl =
      $this->{session}->getScriptUrl( 0, 'view' ) . "/$testWeb/$testWebSubWeb";

    $this->{session} = new Foswiki( $Foswiki::cfg{DefaultUserName}, $query );

    my $topicObject = Foswiki::Store->create(
        address => { web   => $testWeb, topic => $testWebSubWeb },
        data    => { _text => "" }
    );
    $topicObject->save();
    $this->assert( $this->{session}->topicExists( $testWeb, $testWebSubWeb ) );

    my $text = "[[$testWeb.$testWebSubWeb]]";
    $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);

    $this->assert_matches( qr!<a href="$scripturl">$testWeb.$testWebSubWeb</a>!,
        $text );
}

# Check expansion of [[TestWeb.SubWeb.WebHome]] in TestWeb/NonExistant.
# It should expand to TestWeb/SubWeb/WebHome
sub test_squab_path_to_topic_in_subweb {
    my $this = shift;

    # Make a query that should set topic=$testSubWeb
    my $query = new Unit::Request("");
    $query->path_info("/$testWeb/NonExistant");
    $this->createNewFoswikiSession( $Foswiki::cfg{DefaultUserName}, $query );

    my $topicObject = Foswiki::Store->create(
        address => { web   => $testWeb, topic => $testWebSubWeb },
        data    => { _text => "" }
    );
    $topicObject->save();
    $this->assert( $this->{session}->topicExists( $testWeb, $testWebSubWeb ) );

    my $text = "[[$testWeb.$testWebSubWeb.WebHome]]";
    $topicObject =
      Foswiki::Store->create(
        address => { web => $testWeb, topic => 'NonExistant' } );
    $text = $topicObject->renderTML($text);

    my $scripturl = Foswiki::Func::getScriptUrl( "$testWeb/$testWebSubWeb",
        "$Foswiki::cfg{HomeTopicName}", 'view' );
    ($scripturl) = $scripturl =~ m/https?:\/\/[^\/]+(\/.*)/;

    $this->assert_matches(
qr!<a href="$scripturl">$testWeb.$testWebSubWeb.$Foswiki::cfg{HomeTopicName}</a>!,
        $text
    );

}

1;
