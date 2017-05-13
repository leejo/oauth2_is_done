#!perl

use strict;
use warnings;
use feature qw/ say /;

use Net::OAuth2::AuthorizationServer;
use Getopt::Long;

my $opts = {};

GetOptions(
	$opts,
	'username|u=s',
	'password|p=s',
	'client-id|c=s',
	'client-secret|s=s',
	'access-token|a=s',
);

my $Server = Net::OAuth2::AuthorizationServer->new;
my $Grant  = $Server->password_grant(
	jwt_secret => 'weeeeee',
	clients => {
		bob => {
			client_secret => 'foo',
		},
	},
	users => {
		sue => 'letmein',
	}
);

if ( my $access_token = $opts->{'access-token'} ) {

	my ( $is_valid,$error ) = $Grant->verify_access_token(
		access_token     => $access_token,
		is_refresh_token => 0,
	);

	die $error if ! $is_valid;

	say "Welcome";

} else {

	my ( $is_valid,$error,$scopes ) = $Grant->verify_user_password(
		client_id     => $opts->{'client-id'}     // '',
		client_secret => $opts->{'client-secret'} // '',
		username      => $opts->{'username'}      // '',
		password      => $opts->{'password'}      // '',
	);

	die $error if ! $is_valid;

	say $Grant->token(
		client_id       => $opts->{'client-id'} // '',
		scopes          => undef,
		type            => 'access',
	);
}
