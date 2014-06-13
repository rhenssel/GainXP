package GainXP::Register;
use Mojo::Base 'Mojolicious::Controller';

sub register_form {
        my $self = shift;
        return $self->render(template => 'Register/register_form', layout => 'default', title => 'Register');
}

1;
