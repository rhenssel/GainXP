package GainXP::Auth;
use Mojo::Base 'Mojolicious::Controller';

use Mojo::Util qw(b64_encode b64_decode url_escape url_unescape hmac_sha1_sum);

use Data::Dumper;

# This action will render a template
sub login {
	my $self = shift;
	
	$self->app->log->debug('XX '.$self->param('referer') . ' ZZ');
	
	if($self->param('referer')) {
		return $self->render(template => 'auth/login', referer => $self->param('referer') );
	}

	return $self->render(template => 'auth/login' );
}

sub auth {
	my $self = shift;
		
    my $username = $self->param('UserName') || die('missing username');
    my $password = $self->param('Password') || die('missing password');
    
    my $sth = $self->db->prepare_cached('SELECT * FROM USERS WHERE username = ?') || confess("ERROR: Preparing statement ".$self->db::errstr);
	$sth->execute($username);
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
$self->app->log->debug(__FILE__ .'::'. __LINE__);
	if(!defined $row) {
		$self->flash(invalidLogin => 1);
		return $self->redirect_to('/login');
	}
	if ( $self->bcrypt_validate( $password, $row->{password} ) ) {
		$self->session(auth => 1);
		$self->session(user => $username);
		$self->session(email => $row->{email});
	
		if($self->param('referer')) {
			my ($referer, $hmac) = split(/::/, $self->param('referer'));
			if($hmac eq hmac_sha1_sum($referer, $self->app->secrets->[0])) {
                return $self->redirect_to(b64_decode($referer));
            }
        }
$self->app->log->debug(__FILE__ .'::'. __LINE__);
        return $self->redirect_to('/');
$self->app->log->debug(__FILE__ .'::'. __LINE__);
	} else {
		$self->flash(invalidLogin => 1);
		return $self->redirect_to('/login');
	}
}

sub logout {
    my $self = shift;
    
    $self->session(auth => 0);
    $self->session(expires => 1);
    $self->redirect_to('/login');
    return;
}

1;
