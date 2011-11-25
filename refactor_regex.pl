#!/usr/bin/perl -w

use strict;

#find the files that contain stuff..
my @results = `rgrep Foswiki::Meta *`;
my $count_of_replacements = 0;

my %files;
foreach my $match (@results) {
     my ($file, $line) = split(/:/, $match);
     
     next unless($file =~ /\//);#ignore files in the root..
     
     push(@{$files{$file}}, $line);
}

print join("\n", map {$_.' -> '.scalar(@{$files{$_}})} keys(%files));

foreach my $file (keys(%files)) {
     convert_file($file);
}

print "\n----\ntotal conversions:           $count_of_replacements\n";

#convert_file($ARGV[0]);


sub convert_file {
     my $filename = shift || 'UnitTestContrib/test/unit/SaveScriptTests.pm';
     print "\n------------\nopening $filename\n";

     my $fh;
     open($fh, '<', $filename) or die "can't";
     local $/;
     my $text = <$fh>;

     $text =~ s/(Foswiki::Meta(->|::)(new|load)([^;]*));/matched($1, $3, $4).';'/gem;
     $text =~ s/((new|load) Foswiki::Meta([^;]*));/matched($1, $2, $3).';'/gem;

     close($fh);
     open($fh, '>', $filename) or die "can't";
     print $fh $text;
     close($fh);
}


#####
sub matched {
     my $found = shift;
     my $orig = $found;
     my $call = shift;
     my $params = shift;
     
     $params =~ s/^\s*\(//;
     $params =~ s/\)\s*$//;
     
     my @arg = split(/\s*,\s*/, $params);
     shift @arg;    #remove session
     
     if ($call eq 'load') {
          #foswiki::Meta::load(session, web, topic, $rev) (don't confuse with $meta->load($rev) which is dead.
          my ($web, $topic, $rev) = @arg;
          
          return $found unless (defined($web));
          
          #replace with Foswiki::Store::load(address=>{web=>$web, $topic=>$topic, rev=>$rev})
          $found = 'Foswiki::Store::load(address=>{';
          $found .= 'web=>'.$web if (defined($web));
          $found .= ', topic=>'.$topic if (defined($topic));
          $found .= ', rev=>'.$rev if (defined($rev));
          $found .= '}';
          $found .= ')';
          $count_of_replacements++;
          
     } elsif ($call eq 'new') {
          #foswiki::Meta::new(session, web, topic, $text) 
          my ($web, $topic, $text) = @arg;
          #replace with Foswiki::Store::create(address=>{web=>$web, $topic=>$topic}, data=>{_text=>$text})
          return $found unless (defined($web));
          
          my $new_call = 'create';
          
          #someone keeps calling 'new' for webs - I want create / get existing to be more explicit
          $new_call = 'load' if ((defined($web)) and not(defined($topic)));
          
          $found = 'Foswiki::Store::'.$new_call.'(address=>{';
          $found .= 'web=>'.$web if (defined($web));
          $found .= ', topic=>'.$topic if (defined($topic));
          $found .= '}';
          $found .= ', data=>{_text=>'.$text.'}' if (defined($text));
          $found .= ')';
          $count_of_replacements++;
     } else {
          die 'what the? '.$found;
     }
     
     print "\t\t($orig) $call : ".join(' - ', @arg)." ==>> $found\n";
     return $found;
}