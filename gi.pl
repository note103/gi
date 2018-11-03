#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';

my $status = `git status`;
my @msg = split /\n/, $status;

my $msg;
my %msg;
my $marker = '';

for (@msg) {
    if ($_ =~ /\AChanges to be committed:/) {
        $marker = 'staged';
    }
    elsif ($_ =~ /\AChanges not staged for commit:/) {
        $marker = 'not staged';
    }
    elsif ($_ =~ /\AUntracked files:/) {
        $marker = 'untracked';
    }

    if ($_ =~ /\A\t(.+)\z/) {
        $msg = $1;
        if ($marker eq 'staged') {
            if ($msg =~ /\A(.+):\s+(.+)\z/) {
                $msg{$2} = 'staged';
            }
        }
        elsif ($marker eq 'not staged') {
            if ($msg =~ /\A(.+):\s+(.+)\z/) {
                $msg{$2} = $1;
            }
        }
        elsif ($marker eq 'untracked') {
            if ($msg =~ /(.+)\z/) {
                $msg{$1} = 'untracked';
            }
        }
    }
}

my @result = ();

while (1) {
    my @list = ();
    my $list = '';

    for (sort keys %msg) {
        push @list, "$msg{$_}:\t$_";
    }
    $list = join "\n", 'OK', @list;

    my $selected_line = `echo "$list" | peco`;
    chomp $selected_line;

    my $selected_status;
    my $selected_file = '';

    if ($selected_line =~ /\* (.+):\t(.+)\z/) {
        $selected_status = $1;
        $selected_file = $2;
        shift @result;
    }
    elsif ($selected_line =~ /(.+):\t(.+)\z/) {
        $selected_status = '* '.$1;
        $selected_file = $2;
        push @result, $selected_file;
    }
    delete $msg{$selected_file};
    $msg{$selected_file} = $selected_status;

    if ($selected_line =~ /\A(OK|)\z/) {
        if ($selected_line eq '' || ($selected_line eq 'OK' && scalar(@result) == 0)) {
            @result = ();
            # say STDERR 'Canceled.';
        }
        last;
    }
}

print "@result";
