# See bottom of file for default license and copyright information

=begin TML

---+ package Foswiki::Plugins::BibtexFormfieldPlugin::Core

=cut

package Foswiki::Plugins::BibtexFormfieldPlugin::Core;

# Always use strict to enforce variable scoping
use strict;
use warnings;

use Assert;
use Error;
use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version
use Foswiki::Form();
use Text::BibTeX();         # library for parsing bibtex files
use Data::Dumper;           # library for debugging

# How to debug:
#    print STDERR "MESSAGE: SCRIPT CALLED!!!";
# writeDebug("This debug message goes to working/logs/debug.log");

sub TRACE { 1 }

sub beforeSaveHandler {
    my ( $text, $topic, $web, $topicObject ) = @_;
    my $formData = $topicObject->get('FORM');

    if ( defined $formData and $formData->{name} ) {
        my ( $formWeb, $formTopic ) =
          Foswiki::Func::normalizeWebTopicName( $web, $formData->{name} );
        my $formDef = Foswiki::Form->new( $Foswiki::Plugins::SESSION, $formWeb,
            $formTopic );
        my ( $bibtexCodeFieldName, @bibtexFieldNames ) =
          getBibtexFields($formDef);
        my $bibtexCodeString;
        if ($bibtexCodeFieldName) {
            writeDebug("Found bibtexCode field!") if TRACE;
            my $field = $topicObject->get( 'FIELD', $bibtexCodeFieldName );
            ASSERT( exists $field->{value} and $field->{value} ) if DEBUG;
            $bibtexCodeString = $field->{value};
            writeDebug($bibtexCodeString) if TRACE;
        }

        if (    $bibtexCodeString
            and $bibtexCodeString =~ /\w/
            and scalar(@bibtexFieldNames) )
        {
            writeDebug(
                "In detection loop, got code string: '$bibtexCodeString'")
              if TRACE;
            my $entry = Text::BibTeX::Entry->new();
            my @fieldList;

            $entry->parse_s($bibtexCodeString);
            @fieldList = $entry->fieldlist;
            foreach my $fieldName (@fieldList) {
                writeDebug( "Processing bibtex field '$fieldName' -> "
                      . $entry->get($fieldName) )
                  if TRACE;

                if ( grep { $_ eq $fieldName } @bibtexFieldNames ) {
                    writeDebug("Parsed field in bibtexForm!!!") if TRACE;
                    my $fieldValue = $entry->get($fieldName);

                    # DOI fields often contain an annoying DOI: prefix on the
                    # value. Perhaps there's a good reason for this (Eg. non-DOI
                    # things going into DOI fields), so double-check that RHS
                    # of this junk looks roughly as if it could be a DOI.
                    if ( lc($fieldName) eq 'doi' ) {
                        if ( $fieldValue =~ /^doi:\s*(\d+\..*)$/i ) {
                            $fieldValue = $1;
                        }
                    }
                    writeDebug("Putting '$fieldName': '$fieldValue'") if TRACE;
                    $topicObject->putKeyed( 'FIELD',
                        { name => $fieldName, value => $fieldValue } );
                }
            }
        }
    }
    else {
        writeDebug("No bibtex fields detected in '$web.$topic'");
    }

    return;
}

sub getBibtexFields {
    my ($formDef) = @_;
    my ( $bibtexCodeFieldName, @bibtexFieldNames );

    if ($formDef) {
        ASSERT( $formDef->can('getFields') ) if DEBUG;
        ASSERT( ref( $formDef->getFields ) eq 'ARRAY' ) if DEBUG;
        ASSERT( scalar( @{ $formDef->getFields } ) ) if DEBUG;
        ASSERT( scalar( @{ $formDef->getFields } ) ) if DEBUG;
        my $fields = $formDef->getFields();

        if ( $fields and ref($fields) eq 'ARRAY' and scalar( @{$fields} ) )
        {    # form definition found, if not the formfields aren't indexed
            writeDebug("Got form field definitions!") if TRACE;
            foreach my $fieldDef ( @{ $formDef->getFields() } ) {
                writeDebug("Start 1") if TRACE;
                if ( $fieldDef->{type} and $fieldDef->{name} ) {
                    writeDebug(
                        "Start 2: $fieldDef->{type} is $fieldDef->{name}")
                      if TRACE;
                    if ( $fieldDef->{type} =~ /^bibtex\+code\b/ ) {
                        writeDebug(
"In bibtexCode IF-clause, got type $fieldDef->{type} in $fieldDef->{name}"
                        ) if TRACE;
                        $bibtexCodeFieldName = $fieldDef->{name};
                    }
                    elsif ( $fieldDef->{type} =~ /^bibtex\b/ ) {
                        writeDebug(
"In bibtex IF-clause, got type $fieldDef->{type} in $fieldDef->{name}"
                        ) if TRACE;
                        push( @bibtexFieldNames, $fieldDef->{name} );
                    }
                }
            }
        }
    }

    return ( $bibtexCodeFieldName, @bibtexFieldNames );
}

sub writeDebug {
    my ($message) = @_;

    Foswiki::Func::writeDebug( 'BibtexFormfieldsPlugin: ' . $message );
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2011-2011 Foswiki Contributors. Foswiki Contributors
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
