package AnyEvent::Connector;
use strict;
use warnings;

our $VERSION = "0.01";

1;
__END__

=pod

=head1 NAME

AnyEvent::Connector - tcp_connect with transparent proxy handling

=head1 SYNOPSIS

    use AnyEvent::Connector;
    
    ## Specify the proxy setting explicitly.
    my $c = AnyEvent::Connector->new(
        proxy => 'http://proxy.example.com:8080',
        no_proxy => ['localhost', 'your-internal-domain.net']
    );
    
    ## Proxy setting from "http_proxy" and "no_proxy" environment variables.
    my $cenv = AnyEvent::Connector->new(
        env_proxy => "http",
    );
    
    ## Same API as AnyEvent::Socket::tcp_connect
    my $guard = $c->tcp_connect(
        "target.hogehoge.org", 80,
        sub {
            ## connect callback
            my ($fh ,$host, $port, $retry) = @_;
            ...;
        },
        sub {
            ## prepare calback
            my ($fh) = @_;
            ...;
        }
    );

=head1 DESCRIPTION

L<AnyEvent::Connector> object has C<tcp_connect> method compatible
with that from L<AnyEvent::Socket>, and it handles proxy settings
transparently.

=head1 CLASS METHODS

=head2 $conn = AnyEvent::Connector->new(%args)

The constructor.

Fields in C<%args> are:

=over

=item C<proxy> => STR (optional)

String of proxy URL. Currently only C<http> proxy is supported.

If both C<proxy> and C<env_proxy> are not specified, the C<$conn> will directly connect to the destination host.

If both C<proxy> and C<env_proxy> are specified, setting by C<proxy> is used.

Setting empty string to C<proxy> disables the proxy setting done by C<env_proxy> option.

=item C<no_proxy> => STR or ARRAYREF of STR (optional)

String or array-ref of strings of domain names, to which the C<$conn> will directly connect.

If both C<no_proxy> and C<env_proxy> are specified, setting by C<no_proxy> is used.

Setting empty string or empty array-ref to C<no_proxy> disables the no_proxy setting done by C<env_proxy> option.

=item C<env_proxy> => STR (optional)

String of protocol specifier. If specified, proxy settings for that
protocol are loaded from environment variables, and C<$conn> is
created.

For example, if C<"http"> is specified, C<http_proxy> (or
C<HTTP_PROXY>) and C<no_proxy> (or C<NO_PROXY>) environment variables
are used to set C<proxy> and C<no_proxy> options.

C<proxy> and C<no_proxy> options have precedence over C<env_proxy>
option.

=back

=head1 OBJECT METHOD

=head2 $guard = $conn->tcp_connect($host, $port, $connect_cb, $prepare_cb)

Make a TCP connection to the given C<$host> and C<$port>.


=head2 $proxy = $conn->proxy_for($host, $port)

If a proxy is used for connecting to the given C<$host> and C<$port>,
it returns the string of the proxy URL. Otherwise, it returns
C<undef>.


=head1 SEE ALSO

=over

=item *

L<AnyEvent::Socket>

=item *

L<AnyEvent::HTTP> - it has C<tcp_connect> option to implement proxy
connection. You can use L<AnyEvent::Connector> for it.

=back

=head1 REPOSITORY

L<https://github.com/debug-ito/AnyEvent-Connector>

=head1 BUGS AND FEATURE REQUESTS

Please report bugs and feature requests to my Github issues
L<https://github.com/debug-ito/AnyEvent-Connector/issues>.

Although I prefer Github, non-Github users can use CPAN RT
L<https://rt.cpan.org/Public/Dist/Display.html?Name=AnyEvent-Connector>.
Please send email to C<bug-AnyEvent-Connector at rt.cpan.org> to report bugs
if you do not have CPAN RT account.


=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2018 Toshio Ito.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

