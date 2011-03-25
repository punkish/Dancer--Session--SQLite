package Dancer::Session::SQLite;

use warnings;
use strict;
use base 'Dancer::Session::Abstract';
use vars qw($VERSION);

use Dancer::ModuleLoader;
use Dancer::Config 'setting';
use DBI qw(:sql_types);

our $dbh;

=head1 NAME

Dancer::Session::SQLite - SQLite-based session backend for Dancer

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

This module implements a SQLite-based backend to Dancer::Session.

=head1 EXPORT

This module doesn't export any methods. All interaction is via your Dancer application.

=head1 SUBROUTINES/METHODS

=head2 init

=cut

sub init {
    my ($class) = @_;
	$class->SUPER::init(@_);
	
	my $db = setting('db');
    $dbh = DBI->connect(
        "dbi:SQLite:dbname=$session_db",
        "",
        "", 
        {RaiseError => 1, AutoCommit => 1}
    ) or die "Can't connect to $session_db: ", $DBI::errstr, "\n";
    

    # make sure session_table exists
    my $sth = $dbh->prepare(qq{
        SELECT name FROM sqlite_master WHERE type='table' AND name='sessions'; 
    });
    $sth->execute;
    my ($name) = $sth->fetchrow_array;
    
    unless ($name) {
        my $str = "'sessions' table doesn't exist in $session_db. ";
        $str .= "Please create a table with the following schema:\n\n";
        $str .= "    CREATE TABLE sessions (\n";
        $str .= "        id TEXT UNIQUE NOT NULL, \n";
        $str .= "        a_session BLOB \n";
        $str .= "    );'\n";
        die $str;
    }
}

=head2 create

Create a new session and return the newborn object representing that session.

=cut

sub create {
    my ($class) = @_;

    my $self = Dancer::Session::SQLite->new;
    $self->flush;
    
    return $self;
}

=head2 retrieve

Return the session object corresponding to the given id.

=cut

sub retrieve {
    my ($class, $id) = @_;

    return undef unless session_db($id);
    return Storable::thaw(session_db($id));
}

=head2 session_db

Return the session object corresponding to the given id.

=cut

sub session_db {
    my ($id) = @_;
    
    my $sth = $dbh->prepare(qq{
        SELECT a_session FROM sessions WHERE id = ?
    });
    $sth->execute($id);
    my ($a_session) = $sth->fetchrow_array;
    
    return $a_session;
}

=head2 destroy

Destroy the session given a session id.

=cut

sub destroy {
    my ($self) = @_;
    
    if (session_db($self->id)) {
    	my $sth = $dbh->prepare(qq{
        	DELETE FROM sessions WHERE id = ?
	    });
	    $sth->execute($self->id);
    }
}

=head2 flush

Update or create a new session and write it to the database table.

=cut

sub flush {
    my $self = shift;

    my $sth;
    if (session_db($self->id)) {
    	$sth = $dbh->prepare(qq{
        	UPDATE sessions 
        	SET a_session = ? 
        	WHERE id = ?
	    });
    }
    else {
		$sth = $dbh->prepare(qq{
	    	INSERT INTO sessions (a_session, id) 
	    	VALUES (?, ?)
	    });
    }
    $sth->execute(Storable::freeze($self), $self->id);
    
    return $self;
}

=head1 AUTHOR

Puneet Kishor, C<< <punkish at eidesis.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-session-sqlite at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Session-SQLite>.  I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Session::SQLite


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Session-SQLite>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Session-SQLite>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Session-SQLite>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Session-SQLite/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This module is released under a CC0 waiver of license by Puneet Kishor <punkish@eidesis.org>. This module is free software. To the extent that there may be rights in this software held by Puneet Kishor, all those rights are waived.


=cut

1; # End of Dancer::Session::SQLite
