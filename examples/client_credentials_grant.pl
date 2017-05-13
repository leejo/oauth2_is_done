#!/usr/bin/env perl

use Mojolicious::Lite;
use Net::OAuth2::AuthorizationServer;
use CGI;

plugin CGI => {
  route => "/token",
  run   => sub {
		my $Server = Net::OAuth2::AuthorizationServer->new;
		my $Grant  = $Server->client_credentials_grant(
			jwt_secret => 'weeeeee',
			clients => {
				bob => {
					client_secret => 'foo',
				},
			}
		);

		my $query = CGI->new;

		if ( my $access_token = $query->param( 'access-token' ) ) {

			my ( $is_valid,$error ) = $Grant->verify_access_token(
				access_token     => $access_token,
				is_refresh_token => 0,
			);

			print $query->header;
			print $error if ! $is_valid;
			exit( 1 )    if ! $is_valid;

			print "Welcome";

		} else {

			my $client_id     = $query->param( 'client-id' )     // '';
			my $client_secret = $query->param( 'client-secret' ) // '';

			my ( $is_valid,$error,$scopes ) = $Grant->verify_client(
				client_id     => $client_id,
				client_secret => $client_secret,
			);

			print $query->header('application/json');
			print "\"$error\"" if ! $is_valid;
			exit( 1 )          if ! $is_valid;

			print '{ "access_token":"' . $Grant->token(
				client_id       => $client_id,
				scopes          => undef,
				type            => 'access',
			) . '" }';
		}

		exit( 0 );
  }
};

app->start;
