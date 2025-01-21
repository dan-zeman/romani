#!/usr/bin/env perl
# Reads CoNLL-U and a separate file with morphological analysis of words.
# Projects the morphological analysis to the CoNLL-U and prints it.
# Copyright © 2025 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

# Read the output of Foma (morphological analysis), postprocessed with foma2ud.pl.
my $foma_output = 'output.txt';
open(FOMA, $foma_output) or die("Cannot read '$foma_output': $!");
my %dictionary;
while(<FOMA>)
{
    s/\r?\n$//;
    if(m/\t/)
    {
        my @f = split(/\t/, $_);
        my $form = $f[0];
        my $ma = $f[1];
        unless(exists($dictionary{$form}{$ma}))
        {
            $dictionary{$form}{$ma} =
            {
                'lemma' => $f[2],
                'upos'  => $f[3],
                'feats' => $f[4],
                'misc'  => $f[5]
            }
        }
    }
}
close(FOMA);

# Read, process and write the CoNLL-U file (STDIN to STDOUT).
while(<>)
{
    s/\r?\n$//;
    if(m/^[0-9]/)
    {
        my @f = split(/\t/, $_);
        if(exists($dictionary{$f[1]}))
        {
            my @analyses = sort(keys(%{$dictionary{$f[1]}}));
            # If there are multiple analyses (the word is ambiguous), pick the first one
            # and leave some trace in MISC that there were other possible solutions.
            my $ma = $dictionary{$f[1]}{$analyses[0]};
            $f[2] = $ma->{lemma};
            $f[3] = $ma->{upos};
            $f[5] = $ma->{feats};
            # The MISC could already contain SpaceAfter=No and we have to merge the two sources of MISC.
            my @misc = $f[9] eq '_' ? () : split(/\|/, $f[9]);
            my @mamisc = $ma->{misc} eq '_' ? () : split(/\|/, $ma->{misc});
            # We can simply concatenate the two misc because they do not contain the same kind of information.
            @misc = (@mamisc, @misc);
            $f[9] = scalar(@misc) == 0 ? '_' : join('|', @misc);
        }
        $_ = join("\t", @f);
    }
    print("$_\n");
}
