package GainXP::Login;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub login {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub login_post {
	my $self = shift;

    my $username = $self->param('UserName') || '';
    my $password = $self->param('Password') || '';

    my $sth = $self->db->prepare_cached('SELECT * FROM USERS WHERE username = ? and password = ?') || confess("ERROR: Preparing statement ".$self->db::errstr);
	my $sth->execute($username, $password);
	my $row = $sth->fetchrow_hashref();

}

1;
