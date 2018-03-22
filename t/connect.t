use strict;
use warnings;
use Test::More;
use Net::EmptyPort qw(empty_port);
use AnyEvent::Socket qw(tcp_server);
use AnyEvent::Handle;

sub setup_proxy {
    my $port = empty_port();
    my $cv = AnyEvent->condvar;
    my $proxied_data = "";
    my $cb_established = sub {
        my ($h) = @_;
        $proxied_data .= delete $h->{rbuf};
    };
    my $connect_req = "";
    my $cb_receive_conn = sub {
        my ($h) = @_;
        $connect_req .= delete $h->{rbuf};
        if($connect_req !~ /\r\n\r\n$/) {
            return;
        }
        $h->push_write(qq{HTTP/1.1 200 OK\r\nX-Hoge-Header: hogehoge\r\n\r\n});
        $h->on_read($cb_established);
    };
    my @error;
    my $finish = sub {
        $cv->send([$connect_req, $proxied_data, \@error]);
    };
    my $server = tcp_server "127.0.0.1", $port, sub {
        my ($fh) = @_;
        my $ah;
        $ah = AnyEvent::Handle->new(
            fh => $fh,
            on_error => sub {
                my ($h, $fatal, $msg) = @_;
                push @error, [$fatal, $msg];
                undef $ah;
                $finish->();
            },
            on_eof => sub {
                $finish->();
            },
            on_read => $cb_receive_conn
        );
    };
    return ($port, $server, $cv);
}

## TODO: setup_proxyを使ってテストする。

done_testing;
