package VCP::Source::cvsbk ;

=head1 NAME

VCP::Source::cvsbk - A CVS repository source extension for bk exported cvs repository

=head1 SYNOPSIS

   vcp cvsbk:/home/cvs:/module...changeset: cvsbkchangeset:

=head1 DESCRIPTION

The source driver handles the cvs repository exported by bk. It uses
the B<Logical change> numbers found in the log message and the
C<ChangeSet> control file to insert source_change_id.

This source driver is meant to use in conjunction with
L<VCP::Filter::cvsbkchangeset>, which has to be inserted after the
L<VCP::Filter::changeset> plugin

=cut

@ISA = qw( VCP::Source::cvs );
use strict ;
our $VERSION = '0.10';

use Carp ;
use VCP::Source::cvs;

sub _create_rev {
    my $self = shift ;
    my $r = $self->SUPER::_create_rev (@_);
    my ( $file_data, $rev_data ) = @_ ;
    # in the case of baserev, $r->{comment} is already stripped
    my $comment = $rev_data->{comment};

    my ($changeset) = $r->name eq 'ChangeSet' ? $r->rev_id :
	$comment =~ m/\(Logical change (\d+\.\d+)\)/m;

    $changeset = 0 if $comment eq "Initial revision\n";

    die "no changeset info in ".$r->as_string." comment was ".$comment
	unless $changeset;

    $changeset =~ s/\.//g;

    $r->change_id ($changeset);
    $r->source_change_id ($changeset);

    return $r;
}

=head1 NOTES

Revisions with message "Initial revision" are assumed empty.

=head1 SEE ALSO

=head1 AUTHORS

Chia-liang Kao E<lt>clkao@clkao.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Chia-liang Kao E<lt>clkao@clkao.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

1;
