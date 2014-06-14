package GainXP::Register;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Sessions;
use DBI;
use Digest;

sub register_handler {
	my $self = shift;
	my $login = $self->param('login');
	my $password = $self->param('password');
	my $confirm_password = $self->param('confirm_password');
	my $email = $self->param('email');
	if ($password != $confirm_password) {
		$self->stash(invalidPassword => 1);
		return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register Fail');
	}
	return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register ok');
}
sub register_form {
	my $self = shift;
	return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register');
}

1;
