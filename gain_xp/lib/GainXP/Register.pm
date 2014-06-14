package GainXP::Register;
use Mojo::Base 'Mojolicious::Controller';
use Mojolicious::Sessions;
use Digest;
use Mail::RFC822::Address qw(valid validlist);

sub register_handler {
	my $self = shift;
	my $login = $self->param('login');
	my $password = $self->param('password');
	my $confirm_password = $self->param('confirm_password');
	my $email = $self->param('email');
	my $sth = $self->db->prepare("select * From users where login=?")
		|| die "fail prepare\n";
	$sth->execute($login)
		|| die "fail execute\n";
	my $result = $sth->fetchrow_hashref();
	my $sth = $self->db->prepare("select * From users where email=?")
		|| die "fail prepare\n";
	$sth->execute($email)
		|| die "fail execute\n";
	my $result1 = $sth->fetchrow_hashref();
	if ($result) {
		$self->stash(invalidLogin => 1);
	}
	if (!valid($email)) {
		$self->stash(invalidEmail => 2);
	}
	elsif ($result1) {
		$self->stash(invalidEmail => 1);
	}
	if ($password != $confirm_password) {
		$self->stash(invalidPassword => 1);
	}
	if ($self->stash('invalidEmail') || $self->stash('invalidPassword') || $self->stash('invalidLogin')) {
		return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register Fail');
	}
	my $sth = $self->db->prepare('INSERT INTO users (login, access, password, email) VALUES (?, ?, ?, ?)')
		|| die "fail prepare\n";
	$sth->execute($login, 'user', $self->bcrypt($password), $email)
		|| die "fail execute\n";
	$self->session(auth => 1);
	return $self->render(template => 'index/welcome', layout => 'default', title => 'Register ok');
}
sub register_form {
	my $self = shift;
	return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register');
}

1;
