#!/usr/bin/env perl
# Přečte výstup z analyzátoru romštiny (Foma) a vyrobí z něj značky, které budou potřeba v UD.
# Copyright © 2025 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

while(<>)
{
    s/\r?\n$//;
    # Prázdné řádky oddělují jednotlivá vstupní slova.
    # Posloupnost po sobě jdoucích neprázdných řádků představuje různé možné analýzy téhož vstupního slova.
    unless(m/^\s*$/)
    {
        # Neprázdný řádek obsahuje vstupní slovo, TAB a za ním výstup analýzy (slovníkový řetězec).
        my ($word, $ma) = split(/\t/, $_);
        # Nedaří se mi přimět Fomu, aby zpracovala některá interpunkční znaménka, tak to zkouším dohnat tady.
        if($ma eq '+?' && $word =~ m/^\pP+$/)
        {
            $ma = $word.'+Punct';
        }
        # Uvnitř analýzy je nejdřív lemma (nebo kmen, volitelně s překladem v závorce), pak plusem oddělené jednotlivé morfologické rysy.
        my @parts = split(/\+/, $ma);
        my $lemmapart = shift(@parts);
        my $upos = 'X';
        my %feats;
        foreach my $part (@parts)
        {
            if($part eq '1pl')
            {
                set_feature(\%feats, 'Person', '1');
                set_feature(\%feats, 'Number', 'Plur');
            }
            elsif($part eq '1sg')
            {
                set_feature(\%feats, 'Person', '1');
                set_feature(\%feats, 'Number', 'Sing');
            }
            elsif($part eq '2pl')
            {
                set_feature(\%feats, 'Person', '2');
                set_feature(\%feats, 'Number', 'Plur');
            }
            elsif($part eq '2sg')
            {
                set_feature(\%feats, 'Person', '2');
                set_feature(\%feats, 'Number', 'Sing');
            }
            elsif($part eq '3pl')
            {
                set_feature(\%feats, 'Person', '3');
                set_feature(\%feats, 'Number', 'Plur');
            }
            elsif($part eq '3sg')
            {
                set_feature(\%feats, 'Person', '3');
                set_feature(\%feats, 'Number', 'Sing');
            }
            elsif($part eq 'Acc')
            {
                set_feature(\%feats, 'Case', 'Acc');
            }
            elsif($part eq 'Adj')
            {
                $upos = 'ADJ';
            }
            elsif($part eq 'Adp')
            {
                $upos = 'ADP';
            }
            elsif($part eq 'Adv')
            {
                $upos = 'ADV';
            }
            elsif($part eq 'CConj')
            {
                $upos = 'CCONJ';
            }
            elsif($part eq 'Cop')
            {
                $upos = 'AUX';
                set_feature(\%feats, 'VerbForm', 'Fin');
                set_feature(\%feats, 'Mood', 'Ind');
            }
            elsif($part eq 'Dem')
            {
                $upos = 'DET';
                set_feature(\%feats, 'PronType', 'Dem');
            }
            elsif($part eq 'Det')
            {
                $upos = 'DET';
                set_feature(\%feats, 'PronType', 'Art');
            }
            elsif($part eq 'Dist')
            {
                set_feature(\%feats, 'Deixis', 'Remt');
            }
            elsif($part eq 'F')
            {
                set_feature(\%feats, 'Gender', 'Fem');
            }
            elsif($part eq 'Gen')
            {
                set_feature(\%feats, 'Case', 'Gen');
            }
            elsif($part eq 'Imp')
            {
                set_feature(\%feats, 'Mood', 'Imp');
            }
            elsif($part eq 'Impf')
            {
                set_feature(\%feats, 'Aspect', 'Imp');
            }
            elsif($part eq 'M')
            {
                set_feature(\%feats, 'Gender', 'Masc');
            }
            elsif($part eq 'NFa')
            {
                $upos = 'NOUN';
                set_feature(\%feats, 'Gender', 'Fem');
            }
            elsif($part eq 'NFb')
            {
                $upos = 'NOUN';
                set_feature(\%feats, 'Gender', 'Fem');
            }
            elsif($part eq 'NMa')
            {
                $upos = 'NOUN';
                set_feature(\%feats, 'Gender', 'Masc');
            }
            elsif($part eq 'NMb')
            {
                $upos = 'NOUN';
                set_feature(\%feats, 'Gender', 'Masc');
            }
            elsif($part eq 'Nom')
            {
                set_feature(\%feats, 'Case', 'Nom');
            }
            elsif($part eq 'Num')
            {
                $upos = 'NUM';
            }
            elsif($part eq 'Obl')
            {
                # Není jasné, co si počít s pádem "oblique". Podle pravidel UD by se měl přejmenovat na akuzativ, jenže romština má zřejmě dva různé pády, jeden je akuzativ a druhý je oblique.
                set_feature(\%feats, 'Case', 'Obl');
            }
            elsif($part eq 'Part')
            {
                $upos = 'PART';
            }
            elsif($part eq 'Pl')
            {
                set_feature(\%feats, 'Number', 'Plur');
            }
            elsif($part eq 'Pfv')
            {
                set_feature(\%feats, 'Aspect', 'Perf');
            }
            elsif($part eq 'Prf')
            {
                set_feature(\%feats, 'Aspect', 'Perf');
            }
            elsif($part eq 'Pron')
            {
                $upos = 'PRON';
                set_feature(\%feats, 'PronType', 'Prs');
            }
            elsif($part eq 'PropNa')
            {
                $upos = 'PROPN';
            }
            elsif($part eq 'PropNb')
            {
                $upos = 'PROPN';
            }
            elsif($part eq 'Pst')
            {
                set_feature(\%feats, 'Tense', 'Past');
            }
            elsif($part eq 'Punct')
            {
                $upos = 'PUNCT';
            }
            elsif($part eq 'SConj')
            {
                $upos = 'SCONJ';
            }
            elsif($part eq 'Sg')
            {
                set_feature(\%feats, 'Number', 'Sing');
            }
            elsif($part eq 'V')
            {
                $upos = 'VERB';
                set_feature(\%feats, 'VerbForm', 'Fin');
                set_feature(\%feats, 'Mood', 'Ind');
            }
            elsif($part eq '?')
            {
                print STDERR ("WARNING: Analyzer does not know word '$word'.\n");
            }
            else
            {
                print STDERR ("WARNING: Unknown tag '$part'.\n");
            }
        }
        my @feats = sort {lc($a) cmp lc($b)} (keys(%feats));
        my $feats = scalar(@feats) > 0 ? join('|', map {"$_=$feats{$_}"} (@feats)) : '_';
        my $lemma = $lemmapart;
        my $misc = '_';
        if($lemmapart =~ m/^(.+)\((.+)\)$/)
        {
            $lemma = $1;
            $misc = "Gloss=$2";
        }
        elsif($upos =~ m/^(PROPN|PUNCT)$/)
        {
            $misc = "Gloss=$lemma";
        }
        $_ .= "\t$lemma\t$upos\t$feats\t$misc";
    }
    print("$_\n");
}



#------------------------------------------------------------------------------
# Sets a feature in a hash. Before doing so, checks whether the feature already
# is set. Issues a warning if it is.
#------------------------------------------------------------------------------
sub set_feature
{
    my $fhash = shift; # hash ref
    my $fname = shift; # feature name
    my $fvalue = shift; # feature value
    if(exists($fhash->{$fname}) && $fhash->{$fname} ne '' && $fhash->{$fname} ne $fvalue)
    {
        print STDERR ("WARNING: Trying to set feature $fname=$fvalue while it already is $fname=$fhash->{$fname}.\n");
    }
    $fhash->{$fname} = $fvalue;
}
