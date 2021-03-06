package Foswiki::Store;

=begin TML

---+ package Foswiki::Store

Factory for Foswiki Data Objects - webs, topics, attachments...
<verbatim>
  #don't set the cuid, so we don't need Foswiki::Access and don't check ACLs
  my $result = Foswiki::Store->new(
      stores=>(
                {module=>'Foswiki::Store::RcsWrap', root=>'foswiki/data'}
            )
  );

  $result->load(address=>'Main.WebHome');
</verbatim>
The Foswiki::Store singleton is a factory object that manipulates data objects (traditionally called webs, topic and attachments)
by delegating requests to specific store implementations.

=cut

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

use Error qw( :try );
use Assert;

use Foswiki::Address();
use Foswiki::Meta();
use Foswiki::AccessControlException ();

my $singleton;

=begin TML

---++ ClassMethod new(...)

Named parameters:
   * stores => [{module => 'Foswiki::Store::RcsWrap', root=>$Foswiki::cfg{dataDir}}]
      * an ordered list of store implementations - can probably have several rcs stores with different root dirs. Last entry is the 'default' store that new webs would be created in
   * access => $session->access(),
   * cuid =>   $session->{user}
      * the default user - can be over-ridden in each call?

Returns the singleton Foswiki::Store object - must have a =stores= hash when initially called.

Returns a new Foswiki::Store or dies on error.

=cut

sub new {
    my $class = shift;

    $singleton ||= bless {@_}, $class;
    ASSERT( defined( $singleton->{stores} ) )
      if DEBUG;    #make sure we're not creating a Store that contains nothing.
    die if ( not defined( $singleton->{stores} ) );
    return $singleton;
}

=begin TML

---++ ClassMethod changeDefaultUser($cuid)
Change the "current" user in the store. Currently only used to initialise
the store.

=cut

# SMELL: what else would it ever be used for? - C.
sub changeDefaultUser {

    #pick the last param, so that we can be class or object called.
    $singleton->{cuid} = $_[$#_];

    ASSERT(
        not defined( $singleton->{cuid} )
          or ref( $singleton->{cuid} ) eq ''
    ) if DEBUG;
    die 'snow ' . ref( $singleton->{cuid} )
      if ( ref( $singleton->{cuid} ) ne '' );

    ASSERT(
             ( not defined( $singleton->{cuid} ) )
          or
          ( defined( $singleton->{cuid} ) and defined( $singleton->{access} ) )
    ) if DEBUG;
}

=begin TML

---++ ClassMethod load(address=>$address, cuid=>$cuid, create=>1, writeable=>1) -> $dataObject
   * =address=>$address= - (required) address of object - can be:
      * {web->$web, topic=>$topic, attachment=>$attachment, rev=>$rev}
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access
   * create=>1 (need to send 'create from?' or is create a blank as Foswiki::obj of some random tyle :(
   * writeable=>1

returns an object of the appropriate type from the Foswiki::Object:: hieracy

=cut

# TODO: or should it be create=>'Foswiki::Object::Web', and er, from what?
# TODO: or kill create=> and use some kind of 'copy' with defered commit
# TODO: note that most of the methods here will have the same codepath
# as load(), so it might be better to write it all as a switchboard..
sub load {
    # SMELL: this is a ClassMethod; why is it callable as an ObjectMethod? - C.
    # This is very confusing.
    shift
      if ( ( ref( $_[0] ) eq 'Foswiki::Store' )
        or ( $_[0] eq 'Foswiki::Store' ) );

    #default cuid from the singleton
    my %args = ( 'cuid', $singleton->{cuid}, @_ );
    $args{functionname} = 'load';

#    print STDERR ".cUID isa ".ref($args{cuid})." ($args{cuid}) - default (".ref($singleton->{cuid}).") == $singleton->{cuid}\n";
#ASSERT(not defined($args{cuid}) or ref($args{cuid}) eq '') if DEBUG;
#die 'here' if (ref($args{cuid}) ne '');

#really should insist that if the caller wants to over-ride the data of a loaded (and thus existant object), that they also say they want to write..
#as this shall become a copy of a loaded/cache obj, not the original
#ASSERT(
#       (defined($args{data}) and $args{writeable}) or
#       not defined($args{data})) if DEBUG;
#TODO: for now, auto set writeable
    $args{writeable} = 1 if ( defined( $args{data} ) );

    #assume that $args{data} is just for topics?
    ASSERT(
        ( defined( $args{data} ) and defined( $args{address}->{topic} ) )
          or not defined( $args{data} )
    ) if DEBUG;

    my $access_type = $args{writeable} ? 'CHANGE' : 'VIEW';

    my $result;
    $args{address} =
      $singleton->_getResourceAddressOrCachedResource( $args{address}, $args{attachment} );

    #print STDERR "-call: load ".($args{address}->getPath())."\n";

    #TODO: look into the different ways someone might ask for the 'root'
    if ( $args{address}->{root} ) {

        #TODO: use a singleton root obj?
        #print STDERR "faking up root obj\n";
        return Foswiki::Meta->NEWnew( address => { string => '/' } );
    }

    die "recursion? - load("
      . $singleton->{count}{load}{ $args{address}->getPath() } . ") "
      . $args{address}->getPath()
      if ( $singleton->{count}{load}{ $args{address}->getPath() }++ > 10 );

    if ( ref( $args{address} ) eq 'Foswiki::Meta' ) {
        $result = $args{address};
    }
    else {

	# see if we are _able_ to test permissions using just
	# an unloaded topic, if not, fall through to load&then test
        if (
            not(
                Foswiki::Store::haveAccess(
                    access_type => $access_type,
                    dontload    => 1,
                    %args
                )
            )
          )
        {
            throw Foswiki::AccessControlException(
                $access_type, $args{cuid},
                $args{address}->web(),
                $args{address}->topic(),
                $singleton->{access}->getReason()
            );
        }

	# $cfg::Foswiki{Stores} is an ordered list, managed by configure
	# that prioritises the cache stores first.
        foreach my $impl ( @{ $singleton->{stores} } ) {

	    # the impl is also able to throw exceptions - as there
	    # might be a store based permissions impl
            if ( not defined( $impl->{impl} ) ) {
                eval "require " . $impl->{module};
                ASSERT( !$@, $@ ) if DEBUG;
                $impl->{impl} = $Foswiki::cfg{Store}{Implementation}->new();
            }

            #$impl->{impl} ||= $impl.'::new'( store => $impl ) || next;
            $result = $impl->{impl}->load(%args);
            last if ( defined($result) );
        }
        if ( ref($result) eq 'Foswiki::Meta' ) {

            #ok, we have a resource object that actually exists in a store
            $singleton->_cacheResource( %args, return => $result );
        }

        if ( not defined($result) and $args{create} ) {
            $result = create(%args);
        }

        unless ( defined($result) ) {

            #HOW TO FIND OUT WHY?
            die 'cant load ' . $args{address}->getPath() if DEBUG;
            throw Error::Simple( 'Cannot load: ' . $args{address}->getPath() );
        }
    }

    if ( ref($result) eq 'Foswiki::Meta' ) {

        #now to make sure we're allowed to give it to the user.

        foreach my $impl ( @{ $singleton->{stores} } ) {
            if ( not defined( $impl->{impl} ) ) {
                eval "require " . $impl->{module};
                ASSERT( !$@, $@ ) if DEBUG;
                $impl->{impl} = $Foswiki::cfg{Store}{Implementation}->new();
            }

	    # a listener for load events.
	    #TODO: kill this and replace with call to logger, which
	    # stores can choose to consume!
            $impl->{impl}->log( %args, return => $result );
        }

	#can't do any better with the __current__ ACL impl, but there
	# should be a call before the readData for real store-fastening
        ASSERT( ref( $args{cuid} ) eq '' );

        #print STDERR "..cUID isa ".ref($args{cuid})." ($args{cuid})\n";

          if (
            not(
                Foswiki::Store::haveAccess(
                    access_type => $access_type,
                    cuid        => $args{cuid},
                    address     => $result
                )
            )
          ) {
            throw Foswiki::AccessControlException( $access_type, $args{cuid},
                $result->web(), $result->topic(),
                $singleton->{access}->getReason() )
          }
    }

    $singleton->{count}{load}{ $args{address}->getPath() }--;

    if ( defined( $args{data} ) ) {

	# TODO: need to deep__ copy the loaded object's data into a
	# new, uncached obj, and then over-ride with data..
        my $newResource = Foswiki::Meta->NEWnew(
            address => $result,
            data    => { %$result, %{ $args{data} } }
        );
        $result = $newResource;
    }

    return $result;
}

=begin TML

---++ ClassMethod create(address=>$address, cuid=>$cuid, writeable=>1) -> $dataObject
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * from=>address (like copy, but without commit)
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access
   * writeable=>1

returns an object of the appropriate type from the Foswiki::Object:: hieracy

=cut

sub create {
    return _template_function( 'create', @_, writeable => 1 );
}

=begin TML

---++ ObjectMethod __internal_save( %options  ) -> $rev

Save the current topic to a store location. Only works on topics.
*without* invoking plugins handlers.
   * =%options= - Hash of options, may include:
      * =forcenewrevision= - force an increment in the revision number,
        even if content doesn't change.
      * =dontlog= - don't include this change in statistics
      * =minor= - don't notify this change
      * =savecmd= - Save command (core use only)
      * =forcedate= - force the revision date to be this (core only)
      * =author= - cUID of author of change (core only - default current user)

Note that the %options are passed on verbatim from Foswiki::Func::saveTopic,
so an extension author can in fact use all these options. However those
marked "core only" are for core use only and should *not* be used in
extensions.

Returns the saved revision number.

=cut

# SMELL: arguably save should only be permitted if the loaded rev
# of the object is the same as the latest rev.
# SMELL: the pod is a doc for '__internal_save' but the method is save.
# SMELL: __internal_save is a private method and should *not* have a POD - use
# standard # comments. - C.
sub save {
    shift
      if ( ( ref( $_[0] ) eq 'Foswiki::Store' )
        or ( $_[0] eq 'Foswiki::Store' ) );

    ASSERT( scalar(@_) % 2 == 0 ) if DEBUG;
    my %args = @_;
    my $cUID = $args{author} || $args{cuid} || $singleton->{cuid};

    if ( $args{address}->type() ne 'topic' ) {

        #attachments don't have reprev mess?
        return _Simple_save(%args);
    }

    unless ( $args{address}->{topic} eq $Foswiki::cfg{WebPrefsTopicName} ) {

        # Don't verify web existance for WebPreferences, as saving
        # WebPreferences creates the web.
        unless (
            Foswiki::Store->exists(
                address => { web => $args{address}->web() }
            )
          )
        {
            throw Error::Simple( 'Unable to save topic '
                  . $args{address}->{topic}
                  . ' - web '
                  . $args{address}->{web}
                  . ' does not exist' );
        }
    }

    $args{address}->_atomicLock($cUID);
    my $i = Foswiki::Store->getRevisionHistory( address => $args{address} );
    my $currentRev = $i->hasNext() ? $i->next() : 1;
    try {
        if ( $currentRev && !$args{forcenewrevision} ) {

            # See if we want to replace the existing top revision
            my $mtime1 =
              Foswiki::Store->getApproxRevTime( address => $args{address} );
            my $mtime2 = time();
            my $dt     = abs( $mtime2 - $mtime1 );

            if ( $dt <= $Foswiki::cfg{ReplaceIfEditedAgainWithin} ) {
                my $info =
                  Foswiki::Store->getVersionInfo( address => $args{address} );

                # same user?
                if ( $info->{author} eq $cUID ) {

                    # reprev is required so we can tell when a merge is
                    # based on something that is *not* the original rev
                    # where another users' edit started.
                    $info->{reprev} = $info->{version};
                    $info->{date} = $args{forcedate} || time();
                    $args{address}->setRevisionInfo(%$info);
                    Foswiki::Store->repRev(
                        address => $args{address},
                        cuid    => $cUID,
                        %args
                    );
                    $args{address}->{_loadedRev} = $currentRev;

                    $singleton->_unCacheResource(%args);
                    #if we saved a webprefs, uncache the web meta too
                    #$singleton->_unCacheResource(address=>{web=>$args{address}->{web}}) if ($args{address}->{topic} eq 'WebPreferences');

                    return $currentRev;
                }
            }
        }
        my $nextRev =
          Foswiki::Store->getNextRevision( address => $args{address} );
        $args{address}->setRevisionInfo(
            date => $args{forcedate} || time(),
            author  => $cUID,
            version => $nextRev,
        );

        my $checkSave = Foswiki::Store->_Simple_save(
            address => $args{address},
            cuid    => $cUID,
            %args
        );
        ASSERT( $checkSave == $nextRev, "$checkSave != $nextRev" ) if DEBUG;
        $args{address}->{_loadedRev}      = $nextRev;
        $args{address}->{_latestIsLoaded} = 1;
        $singleton->_unCacheResource(%args);

        #if we saved a webprefs, uncache the web meta too
        #$singleton->_unCacheResource(address=>{web=>$args{address}->{web}}) if ($args{address}->{topic} eq 'WebPreferences');

    }
    finally {
        $args{address}->_atomicUnlock($cUID);
        $args{address}->fireDependency();
    };
    return $args{address}->{_loadedRev};
}

#TODO: kill this. make it a param to save.
sub repRev {
    return _template_function( 'repRev', @_, writeable => 1 );
}

=begin TML

---++ ClassMethod save(object=>$result, cuid=>$cuid, create=>1, writeable=>1, forcenewrevision=>0, ...) -> $integer?
   * =object=>$result= - (required) Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

Save a topic or attachment _without_ invoking plugin handlers.
   * =object= - Foswiki::Meta for the topic
   * =cuid= - cUID of user doing the saving
   * =forcenewrevision= - force a new revision even if one isn't needed
   * =forcedate= - force the revision date to be this (epoch secs)
   * =minor= - True if this is a minor change (used in log)
   * =author= - cUID of author of the change
   * =reprev=

Returns the new revision identifier.

=cut

# SMELL: the pod is a doc for 'save' but the method is _Simple_save - C.
# _Simple_save is a private moethod and does not need a POD doc
sub _Simple_save {
    return _template_function( 'save', @_, writeable => 1 );
}

=begin TML

---++ ClassMethod remove(address=>$address, cuid=>$cuid, -> success?
   * =address= - (required) Address - can be a specific revision, in which case it requests the store to =delRev=
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

delete a topic or attachment _without_ invoking plugin handlers.
   * =object= - Foswiki::Meta for the topic
   * =cuid= - cUID of user doing the saving

=cut

sub remove {
    return _template_function( 'remove', @_, writeable => 1 );
}

=begin TML

---++ ClassMethod move(from=>$address, address=>$address, cuid=>$cuid) -> success?
   * =from=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

=cut

sub move {
    shift
      if ( ( ref( $_[0] ) eq 'Foswiki::Store' )
        or ( $_[0] eq 'Foswiki::Store' ) );
    my %args = ( cuid => $singleton->{cuid}, @_ );

    if ( ref( $args{from} ) ne 'Foswiki::Meta' ) {
        $args{from} =
          Foswiki::Store->load( writeable => 1, address => $args{from} );
    }
    return _template_function( 'move', %args, writeable => 1 );
}

=begin TML

---++ ClassMethod copy(from=>$address, address=>$address, cuid=>$cuid) -> success?
   * =from=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access


not currently implemented - also from PluginHandlerTests

    #TODO: I'm only copying the DefaultPreferences because the Prefs code (now) doesn't like it when its missing
    #BROKEN
    #my $default = Foswiki::Store->create(address=>{web => $systemWeb, topic=>$Foswiki::cfg{SitePrefsTopicName}}, from=>{web => $Foswiki::cfg{SystemWebName}, topic=>$Foswiki::cfg{SitePrefsTopicName}});
    #BROKEN
    #my $default = Foswiki::Store->load(address=>{web => $Foswiki::cfg{SystemWebName}, topic=>$Foswiki::cfg{SitePrefsTopicName}});
    #$default->web($systemWeb);
    #WORKS - but probably shouldn't work quite this way.
    my $default = Foswiki::Store->load(
                                create=>1,
                                address=>{web => $systemWeb, topic=>$Foswiki::cfg{SitePrefsTopicName}},
                                from=>{web => $Foswiki::cfg{SystemWebName}, topic=>$Foswiki::cfg{SitePrefsTopicName}}
                                    );
    Foswiki::Store->save(address=>$default);

=cut

sub copy {
    die 'is there a good reason to do this?';
    return _template_function( 'copy', @_, writeable => 1 );
}

=begin TML

---++ ClassMethod exists(address=>$address, cuid=>$cuid) -> bool
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

=cut

sub exists {
    ASSERT($singleton) if DEBUG;
    return _template_function( 'exists', @_ );
}

=begin TML

---++ ClassMethod getRevisionHistory(address=>$address, cuid=>$cuid) -> $iterator
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

Get an iterator over the list of revisions of the object. The iterator returns
the revision identifiers (which will be numbers) starting with the most
recent revision.

if there are no versions, we probably return an empty itr

If the object does not exist, returns an empty iterator ($iterator->hasNext() will be
false).

=cut

sub getRevisionHistory {
    return _template_function( 'getRevisionHistory', @_ );
}

=begin TML

---++ ClassMethod getNextRevision ( address=>$address  ) -> $revision
   * =$address= - address of datum

Get the ientifier for the next revision of the topic. That is, the identifier
for the revision that we will create when we next save.

=cut

# SMELL: There's an inherent race condition with doing this, but it's always
# been there so I guess we can live with it.
sub getNextRevision {
    return _template_function( 'getNextRevision', @_ );
}

=begin TML

---++ ClassMethod getRevisionDiff(from=>$address, address=>$address, cuid=>$cuid, contextLines=>$contextLines) -> \@diffArray

Get difference between two versions of the same topic. The differences are
computed over the embedded store form.

Return reference to an array of differences
   * =from=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access
   * =$contextLines= - number of lines of context required

Each difference is of the form [ $type, $right, $left ] where
| *type* | *Means* |
| =+= | Added |
| =-= | Deleted |
| =c= | Changed |
| =u= | Unchanged |
| =l= | Line Number |

=cut

sub getRevisionDiff {
    return _template_function( 'getRevisionDiff', @_ );
}

=begin TML

---++ ClassMethod getVersionInfo(address=>$address, cuid=>$cuid) -> \%info

   * =address=>$address= - (required) address of object - can be:
      * ($web, $topic, $attachment, $rev) list
      * 'web.topic@4' style
      * Foswiki::Address
      * Foswiki::Object impl
   * cuid=>$cuid (canonical user id) - if undefined, presume 'admin' (or no perms check) access

Return %info with at least:
| date | in epochSec |
| user | user *object* |
| version | the revision number |
| comment | comment in the VC system, may or may not be the same as the comment in embedded meta-data |

=cut

# Formerly know as getRevisionInfo.
sub getVersionInfo {
    return _template_function( 'getVersionInfo', @_ );
}

=begin TML

---++ ClassMethod atomicLockInfo( address=>$address ) -> \($cUID, $time)
If there is a lock on the topic, return it.

NOTE: this has changed to an arrayref

=cut

sub atomicLockInfo {
    return _template_function( 'atomicLockInfo', @_ );
}

=begin TML

---++ ClassMethod atomicLock( address=>$address, cuid=>$cuid )

   * =$topicObject= - Foswiki::Meta topic object
   * =$cUID= cUID of user doing the locking
Grab a topic lock on the given topic.

=cut

sub atomicLock {
    return _template_function( 'atomicLock', @_ );
}

=begin TML

---++ ClassMethod atomicUnlock( address=>$address, cuid=>$cuid )

   * =$topicObject= - Foswiki::Meta topic object
Release the topic lock on the given topic. A topic lock will cause other
processes that also try to claim a lock to block. It is important to
release a topic lock after a guard section is complete. This should
normally be done in a 'finally' block. See man Error for more info.

Topic locks are used to make store operations atomic. They are
_note_ the locks used when a topic is edited; those are Leases
(see =getLease=)

=cut

sub atomicUnlock {
    return _template_function( 'atomicUnlock', @_ );
}

=begin TML

---++ ClassMethod getApproxRevTime (  address=>$address, cuid=>$cuid  ) -> $epochSecs

Get an approximate rev time for the latest rev of the topic. This method
is used to optimise searching. Needs to be as fast as possible.

=cut

sub getApproxRevTime {
    return _template_function( 'getApproxRevTime', @_ );
}

=begin TML

---++ ClassMethod eachChange( address=>$address, time=>$time ) -> $iterator

Get an iterator over the list of all the changes in the given web between
=$time= and now. $time is a time in seconds since 1st Jan 1970, and is not
guaranteed to return any changes that occurred before (now -
{Store}{RememberChangesFor}). Changes are returned in most-recent-first
order.

TODO: remove and replace with logger API?

=cut

sub eachChange {
    return _template_function( 'eachChange', @_ );
}

=begin TML

---++ ClassMethod eachWeb( address=>$address) -> $iterator

Get an iterator over the list of all elements of type '$type' that are sub elements of the addressed one

=cut

sub eachWeb {
    return _template_function( 'eachWeb', @_ );
}

=begin TML

---++ ClassMethod eachTopic( address=>$address) -> $iterator

Get an iterator over the list of all elements of type '$type' that are sub elements of the addressed one

=cut

sub eachTopic {
    return _template_function( 'eachTopic', @_ );
}

=begin TML

---++ ClassMethod eachAttachment( address=>$address) -> $iterator

Get an iterator over the list of all elements of type '$type' that are sub elements of the addressed one

=cut

sub eachAttachment {
    return _template_function( 'eachAttachment', @_ );
}

=begin TML

---++ ClassMethod openAttachment( address=>$address) -> $iterator

open the attachments
TODO: sven would like to replace this with a F::O::Attachment class - we'll see

=cut

sub openAttachment {
    return _template_function( 'openAttachment', @_ );
}

=begin TML

---++ ClassMethod testAttachment( address=>$address, attachment=>, test=>) -> mumble.

open the attachments
TODO: sven would like to replace this with a F::O::Attachment class - we'll see

=cut

sub testAttachment {
    return _template_function( 'testAttachment', @_ );
}

=begin TML

---++ ClassMethod query($query, $inputTopicSet, $session, \%options) -> $outputTopicSet

Search for data in the store (not web based).
   * =$query= either a =Foswiki::Search::Node= or a =Foswiki::Query::Node=.
   * =$inputTopicSet= is a reference to an iterator containing a list
     of topic in this web, if set to undef, the search/query algo will
     create a new iterator using eachTopic()
     and the topic and excludetopics options

Returns a =Foswiki::Search::InfoCache= iterator

This will become a 'query engine' factory that will allow us to plug in
different query 'types' (Sven has code for 'tag' and 'attachment' waiting
for this)

=cut

sub query {
    shift
      if ( ( ref( $_[0] ) eq 'Foswiki::Store' )
        or ( $_[0] eq 'Foswiki::Store' ) );

    #return _template_function( 'query', @_ );
    my $functionname = 'query';

    my $result;

    foreach my $impl ( @{ $singleton->{stores} } ) {

	# the impl is also able to throw exceptions - as there
	# might be a store based permissions impl
        if ( not defined( $impl->{impl} ) ) {
            eval "require " . $impl->{module};
            ASSERT( !$@, $@ ) if DEBUG;
            $impl->{impl} = $Foswiki::cfg{Store}{Implementation}->new();
        }

        #$impl->{impl} ||= $impl.'::new'( store => $impl ) || next;
        $result = $impl->{impl}->$functionname(@_);
        last if ( defined($result) );
    }

    # SD TODO: ok, so this is very wrong, need to iterate over all
    # impls and then combin results but I think it might actually
    # work for single store

    return $result;
}

=begin TML

---++ ClassMethod getRevisionAtTime( address=>$address, $time ) -> $rev

   * =$topicObject= - topic
   * =$time= - time (in epoch secs) for the rev

Get the revision identifier of a topic at a specific time.
Returns a single-digit rev number or undef if it couldn't be determined
(either because the topic isn't that old, or there was a problem)

=cut

sub getRevisionAtTime {
    return _template_function( 'getRevisionAtTime', @_ );
}

=begin TML

---++ ClassMethod getLease( address=>$address ) -> $lease

   * =$topicObject= - topic

If there is an lease on the topic, return the lease, otherwise undef.
A lease is a block of meta-information about a topic that can be
recovered (this is a hash containing =user=, =taken= and =expires=).
Leases are taken out when a topic is edited. Only one lease
can be active on a topic at a time. Leases are used to warn if
another user is already editing a topic.

=cut

sub getLease {
    return _template_function( 'getLease', @_ );
}

=begin TML

---++ ClassMethod setLease( address=>$address, cuid=>$cuid, length=>$length )

   * =$topicObject= - Foswiki::Meta topic object
Take out an lease on the given topic for this user for $length seconds.

See =getLease= for more details about Leases.

=cut

sub setLease {
    return _template_function( 'setLease', @_ );
}

=begin TML

---++ ClassMethod removeSpuriousLeases( address=>$address )

Remove leases that are not related to a topic. These can get left behind in
some store implementations when a topic is created, but never saved.

=cut

sub removeSpuriousLeases {
    return _template_function( 'removeSpuriousLeases', @_ );
}

=begin TML

---++ ClassMethod _template_function( functionname )

A switchboard function that contains the implementation to delegate
to the stores

=cut

# SMELL: what s the rationale for this indirection? - C.
sub _template_function {
    my $functionname = shift;
    shift
      if ( ( ref( $_[0] ) eq 'Foswiki::Store' )
        or ( $_[0] eq 'Foswiki::Store' ) );

    ASSERT($singleton) if DEBUG;

    # Help track down old-style calling convention
    ASSERT( !( scalar(@_) % 2 ) ) if DEBUG;

    #default cuid from the singleton
    my %args = ( cuid => $singleton->{cuid}, @_ );

    ASSERT( defined( $args{address} ) ) if DEBUG;

    $args{functionname} = $functionname;

#print STDERR ".cUID isa ".ref($args{cuid})." ($args{cuid}) - default (".ref($singleton->{cuid}).")\n";
#ASSERT(not defined($args{cuid}) or ref($args{cuid}) eq '') if DEBUG;
#die 'here' if (ref($args{cuid}) ne '');

    my $access_type = $args{writeable} ? 'CHANGE' : 'VIEW';

    my $result;
    if (    ( $access_type eq 'CHANGE' )
        and ( ref( $args{address} ) eq 'Foswiki::Meta' ) )
    {

	# we already have a valid meta obj - so we're likely going
	# to use it to commit to the store?
    }
    else {
        $args{address} =
          $singleton->_getResourceAddressOrCachedResource( $args{address}, $args{attachment} );
    }

#die "recursion? - $functionname(".$singleton->{count}{$functionname}{$args{address}->getPath()}.") ".$args{address}->getPath() if ($singleton->{count}{$functionname}{$args{address}->getPath()}++ > 10);

    #print STDERR "-call: $functionname: ".($args{address}->getPath())."\n";

    #    if (ref($args{address}) eq 'Foswiki::Meta') {
    #        $result = $args{address};
    #    } else
    {

	# see if we are _able_ to test permissions using just an
	# unloaded topic, if not, fall through to load&then test
        if (
            not(
                Foswiki::Store::haveAccess(
                    access_type => $access_type,
                    dontload    => 1,
                    %args
                )
            )
          )
        {
            throw Foswiki::AccessControlException(
                $access_type, $args{cuid},
                $args{address}->web(),
                $args{address}->topic(),
                $singleton->{access}->getReason()
            );
        }

        #        if ( defined( $args{from} ) ) {
        #
        #            #load will throw exceptions if things go wrong
        #            $args{from} = load( address => $args{from} )
        #              unless ( $args{from}->isa('Foswiki::Address') );
        #        }

	# $cfg::Foswiki{Stores} is an ordered list, managed by configure
	# that prioritises the cache stores first.
        foreach my $impl ( @{ $singleton->{stores} } ) {

	    # the impl is also able to throw exceptions - as there
	    # might be a store based permissions impl
            if ( not defined( $impl->{impl} ) ) {
                eval "require " . $impl->{module};
                ASSERT( !$@, $@ ) if DEBUG;
                $impl->{impl} = $Foswiki::cfg{Store}{Implementation}->new();
            }

            #$impl->{impl} ||= $impl.'::new'( store => $impl ) || next;
            $result = $impl->{impl}->$functionname(%args);
            last if ( defined($result) );
        }
        if (   ( $functionname eq 'move' )
            or ( $functionname eq 'exists' )
            or ( $functionname eq 'getVersionInfo' )
            or ( $functionname eq 'setLease' )
            or ( $functionname eq 'getLease' )
            or ( $functionname eq 'atomicLockInfo' )
            or ( $functionname eq 'atomicLock' )
            or ( $functionname eq 'eachWeb' )
            or ( $functionname eq 'eachTopic' )
            or ( $functionname eq 'eachAttachment' )
            or ( $functionname eq 'getRevisionAtTime' )
            or 1 == 0 )
        {

#use Data::Dumper;
#print STDERR "-$functionname => ".(defined($result)?Dumper($result):'undef')."\n";
            return $result;
        }
        throw Error::Simple( "No such method '$functionname' accessing "
              . $args{address}->stringify() )
          unless ( defined($result) );
    }

    if ( ref($result) eq 'Foswiki::Meta' ) {

        #now to make sure we're allowed to give it to the user.

        foreach my $impl ( @{ $singleton->{stores} } ) {
            if ( not defined( $impl->{impl} ) ) {
                eval "require " . $impl->{module};
                ASSERT( !$@, $@ ) if DEBUG;
                $impl->{impl} = $Foswiki::cfg{Store}{Implementation}->new();
            }

	    # a listener for load events.
	    # TODO: kill this and replace with call to logger, which
	    # stores can choose to consume!
            $impl->{impl}->log( %args, return => $result );
        }

	# can't do any better with the __current__ ACL impl, but there
	# should be a call before the readData for real store-fastening
        ASSERT( ref( $args{cuid} ) eq '' );

        #print STDERR "..cUID isa ".ref($args{cuid})." ($args{cuid})\n";

        if (
            not(
                Foswiki::Store::haveAccess(
                    access_type => $access_type,
                    cuid        => $args{cuid},
                    address     => $result
                )
            )
          )
        {
            throw Foswiki::AccessControlException( $access_type, $args{cuid},
                $result->web(), $result->topic(),
                $singleton->{access}->getReason() );
        }
    }

    $singleton->{count}{$functionname}{ $args{address}->getPath() }--;

    return $result;
}

#called onsave etc to flush the cache
sub _unCacheResource {
    my $self = shift;
    my %args = @_;
    
    my $address = $args{address};

    $address = Foswiki::Address->new( string => $address )
      if ( ref($address) eq '' );    #justa string/scalar
    $address = Foswiki::Address->new(@$address)
      if ( ref($address) eq 'ARRAY' );
    $address = Foswiki::Address->new(%$address)
      if ( ref($address) eq 'HASH' );
      
    ASSERT($address->isa('Foswiki::Address')) if DEBUG;

#ASSERT(defined($obj->{_text})) if DEBUG; #if itsa topic.
#print STDERR "_cacheResource(".$args{functionname}.", ".$args{return}->getPath().") \n";

    my $name = $address->getPath();
    
    #can't finish this obj - it is being used by the caller of the store :/
    #$self->{cache}{$name}->finish() if (exists($self->{cache}{$name}));
    delete $self->{cache}{$name};
}

sub _cacheResource {
    my $self = shift;
    my %args = @_;

#ASSERT(defined($obj->{_text})) if DEBUG; #if itsa topic.
#print STDERR "_cacheResource(".$args{functionname}.", ".$args{return}->getPath().") \n";

    return unless ( $args{functionname} eq 'load' );

    my $name = $args{return}->getPath();
    $self->{cache}{$name} = $args{return};
}

sub _getResourceAddressOrCachedResource {
    my $self    = shift;
    my $address = shift;
    my $attachment = shift; #need to mush this in for now - #TODO: replace with die one day for new F::Address based API

    #TODO: this should be in the Foswiki::Address constructor
    $address = Foswiki::Address->new( string => $address )
      if ( ref($address) eq '' );    #justa string/scalar
    $address = Foswiki::Address->new(@$address)
      if ( ref($address) eq 'ARRAY' );
    $address = Foswiki::Address->new(%$address)
      if ( ref($address) eq 'HASH' );
      
    ASSERT($address->isa('Foswiki::Address')) if DEBUG;
    if (defined($attachment)) {
        if ($address->isa('Foswiki::Meta')) {
            #make an address pointing to the topic..
            $address = Foswiki::Address->new($address);
        }
        $address->attachment($attachment);
    }

    my $name = $address->getPath();

    #print STDERR "_getResourceAddressOrCachedResource($name)\n";
    $address = $self->{cache}{$name} if ( exists( $self->{cache}{$name} ) );

#print STDERR "notincache --- _getResourceAddressOrCachedResource($name) --> root:".(defined($address->{root})?$address->{root}:'undef')."\n";
    return $address;
}

sub finish {
    undef $singleton->{cache};
    undef $singleton;

    #print STDERR "--------------------------------- end Store singleton\n";
}

=begin TML

---++ StaticMethod cleanUpRevID( $rev ) -> $integer

Cleans up (maps) a user-supplied revision ID and converts it to an integer
number that can be incremented to create a new revision number.

This method should be used to sanitise user-provided revision IDs.

Returns 0 if it was unable to determine a valid rev number from the
string passed.

=cut

sub cleanUpRevID {
    my $rev = shift;

    # RCS format: 1.2, or plain integer: 2
    if ( defined $rev && $rev =~ /^(?:\d+\.)?(\d+)$/ ) {
        return $1;
    }

    return 0;
}

sub haveAccess {
    return 1 unless ( defined( $singleton->{access} ) );
    my %args = @_;
    if ( not defined( $args{cuid} ) ) {

      #no cuid defined at all == admin (could be used without a foswiki session)
        return 1 if ( not defined( $singleton->{cuid} ) );
        $args{cuid} = $singleton->{cuid};
    }
    return $singleton->{access}
      ->haveAccess( $args{access_type}, $args{cuid}, $args{address},
        dontload => $args{dontload} );
}

1;

__END__
Author: Sven Dowideit, http://fosiki.com

Module of Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2011 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.

