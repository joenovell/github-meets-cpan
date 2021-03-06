package GMC::Util;

use Mojo::Base 'Exporter';
use Cpanel::JSON::XS qw( decode_json );
use Path::Tiny qw( path );

our @EXPORT_OK = qw( environment github_config mongodb_config );
my $ENVIRONMENT;

sub mongodb_config {
    my ($self) = @_;

    my %config = (
        host => environment()->{DOTCLOUD_DATA_MONGODB_HOST},
        port => environment()->{DOTCLOUD_DATA_MONGODB_PORT},
    );

    my ( $user, $pass )
        = @{ environment() }
        {qw(DOTCLOUD_DATA_MONGODB_LOGIN DOTCLOUD_DATA_MONGODB_PASSWORD)};

    $config{password} = $pass if defined $pass;
    $config{username} = $user if defined $user;

    return %config;
}

sub github_config {
    my ($self) = @_;

    my $env = environment();

    my $token = $env->{GITHUB_TOKEN} || $ENV{GITHUB_TOKEN};
    warn 'No GitHub token found in %ENV' unless $token;

    return { $token ? ( TOKEN => $token ) : () };
}

sub environment {
    my ($self) = @_;

    return $ENVIRONMENT if $ENVIRONMENT;

    my $file = path('environment.json');

    if ( $file->exists ) {
        my $env = $file->slurp_raw;
        $ENVIRONMENT = decode_json($env);
        return $ENVIRONMENT;
    }

    $ENVIRONMENT = {
        DOTCLOUD_DATA_MONGODB_HOST => $ENV{MONGODB_HOST} || 'mongodb',
        DOTCLOUD_DATA_MONGODB_PORT => 27017,
    };

    return $ENVIRONMENT;
}

1;
