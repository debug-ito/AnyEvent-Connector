package AnyEvent::Connector::Proxy::http;
use strict;
use warnings;

sub new {
    my ($class, $uri) = @_;
    my $self = bless {
        uri => $uri
    }, $class;
    return $self;
}

sub uri_string {
    my ($self) = @_;
    return $self->{uri}->as_string;
}

sub host {
    my ($self) = @_;
    return $self->{uri}->host;
}

sub port {
    my ($self) = @_;
    return $self->{uri}->port;
}


1;

__END__

=pod

=head1 NAME

AnyEvent::Connector::Proxy::http - http Proxy connector

=head1 DESCRIPTION

This module is internal. End-users should not use it directly.

=cut
