package GainXP;
use Mojo::Base 'Mojolicious';

use Mojo::Util qw(b64_encode b64_decode url_escape url_unescape hmac_sha1_sum);

# This method will run once at server start
sub startup {
	my $self = shift;
	
	
    $self->{secrets} = ['DUMMY']; # Keeps Mojolicious happy until the real secrets can be loaded from the config file.
    # Loading configuration and applying app settings
    $self->plugin('Config' => {file => $self->app->home->rel_file('Config/GainXP.conf')});

    $self->plugin('bcrypt', { cost => $self->{config}->{Security}->{BCryptCost} });

	$self->plugin('database', {
		dsn      => $self->{config}->{DataBase}->{ConnectString},
		username => $self->{config}->{DataBase}->{User},
		password => $self->{config}->{DataBase}->{Password},
		options  => { PrintError => 0,
			RaiseError => 1,
			AutoCommit => 1,
			LongReadLen => 64 * 1024,
			LongTruncOk => 1,
			Callbacks => { 'connect_cached.reused' => sub { delete $_[4]->{AutoCommit} },
			},
		},
		helper   => 'db',
		});

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('index#welcome');
  
	my $rs = $r->bridge("/")->to(cb => sub {
		my $self = shift;

		# Authenticated
		if($self->session('auth')) {
			return 1;
		}

		my $encodedReferer = b64_encode($self->req->url(),'');

		my $checksum = hmac_sha1_sum($encodedReferer, $self->app->secrets->[0]);

		# Not authenticated
		$self->redirect_to('/login/?ref='.b64_encode($self->req->url(),'').'::'.$checksum);
		return 0;
	});
	
	$r->route('/login/')->via('get')->to('Login#login_form');
	$r->route('/register')->via('get')->to('Register#register_form');
	$r->route('/register')->via('post')->to('Register#register_handler');
	$r->route('/login/')->via('post')->to('Login#login');
	$rs->route('/logout/')->via('get')->to('Login#logout');
	
}

1;
