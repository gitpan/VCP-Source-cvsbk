package VCP::Filter::cvsbkchangeset;

=head1 NAME

VCP::Filter::cvsbkchangeset - alter cvsbk revisions for proper log message

=head1 SYNOPSIS

   vcp cvsbk:/home/cvs:/module...cvsbkchangeset:

=head1 DESCRIPTION

The filter strips the ChangeSet control file from revisions generated
by L<VCP::Source::cvsbk> source driver after copying the comments to
revisions that belong to the same chagneset.

Additionally revisions with C<change_id> 0 are dropped as cvsbk source
driver gives that for initial revisions.

=cut

@ISA = qw( VCP::Filter );
our $VERSION = '0.11';

use strict ;
use VCP::Logger qw( pr_doing );

sub new {
   my $self = shift->SUPER::new;
   $self->{BKC_PENDING} = [];
   return $self ;
}

sub filter_name { return "cvsbkchangeset" }

sub emit {
    my $self = shift;
    my $changeset = $self->{BKC_CHANGESET};

    for (@{$self->{BKC_PENDING}}) {
	$_->comment ($changeset->comment);
	$self->dest->handle_rev( $_ );
	$self->dest->head_revs->set
	    ( [ $changeset->source_repo_id, $changeset->source_filebranch_id ],
	      $changeset->source_rev_id
	    );
    }
    $self->{BKC_PENDING} = [];
    undef $self->{BKC_CHANGESET};
}

sub handle_rev {
   my $self = shift;
   my ($r) = @_;

   if ($r->is_base_rev) {
       $r->name eq 'ChangeSet' ?
	   pr_doing # dummy
	 : $self->dest->handle_rev ($r);
       return;
   }

   my $change_id = $r->change_id;

   pr_doing, return if $change_id == 0;

   if (defined $self->{BKC_CHANGESET} &&
       defined $self->{BKC_PREV_CHANGE_ID} &&
       $change_id ne $self->{BKC_PREV_CHANGE_ID}) {

       $self->emit;
   };

   $self->{BKC_PREV_CHANGE_ID} = $change_id;

   if ($r->name eq 'ChangeSet') {
       die "two ChangeSet revision in one changeset:\n".$self->{BKC_CHANGESET}->as_string."\n".$r->as_string
	   if $self->{BKC_CHANGESET};
       $self->{BKC_CHANGESET} = $r;
       pr_doing;
   }
   else {
       push @{$self->{BKC_PENDING}}, $r;
   }

}

sub handle_footer {
   my $self = shift ;
   $self->emit if @{$self->{BKC_PENDING}};
   $self->SUPER::handle_footer ;
}

=head1 NOTES

The filter should be inserted right before the L<VCP::Dest> driver.

=head1 AUTHORS

Chia-liang Kao E<lt>clkao@clkao.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Chia-liang Kao E<lt>clkao@clkao.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

1;
