use strict;
use warnings;
use Test::More;
use Net::EmptyPort qw(empty_port);
use AnyEvent::Socket qw(tcp_server);
use AnyEvent::Handle;
use AnyEvent::Connector;

sub setup_echo_proxy {
    my $port = empty_port();
    my $cv = AnyEvent->condvar;
    my $proxied_data = "";
    my $cb_established = sub {
        my ($h) = @_;
        my $got_data = delete $h->{rbuf};
        $proxied_data .= $got_data;
        $h->push_write($got_data);
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
                $ah->destroy();
                undef $ah;
                $finish->();
            },
            on_eof => sub {
                $ah->destroy();
                undef $ah;
                $finish->();
            },
            on_read => $cb_receive_conn
        );
    };
    return ($port, $server, $cv);
}

subtest 'successful echo proxy', sub {
    my ($proxy_port, $proxy_guard, $proxy_cv) = setup_echo_proxy();
    my $conn = AnyEvent::Connector->new(
        proxy => "http://127.0.0.1:$proxy_port"
    );
    my $client_cv = AnyEvent->condvar;
    my ($got_host, $got_port);
    $conn->tcp_connect("this.never.exist.i.guess.com", 5500, sub {
        (my $fh, $got_host, $got_port) = @_;
        my $ah;
        $ah = AnyEvent::Handle->new(
            fh => $fh,
            on_error => sub {
                my ($h, $fatal, $msg) = @_;
                $ah->destroy();
                undef $ah;
                $client_cv->croak($fatal, $msg);
            },
            on_eof => sub {
                undef $ah;
                $client_cv->send();
            },
            on_read => sub {
                my ($h) = @_;
                my $data = delete $h->{rbuf};
                $ah->push_shutdown();
                $ah->destroy();
                undef $ah;
                $client_cv->send(delete $h->{rbuf});
            }
        );
        $ah->push_write("data submitted\n");
        $ah->push_read(line => sub {
            my ($h, $line) = @_;
            $ah->push_shutdown();
            $ah->destroy();
            undef $ah;
            $client_cv->send($line);
        });
    });
    my $client_got = $client_cv->recv();
    my $proxy_got = $proxy_cv->recv();
    is $client_got, "data submitted";
    is $got_host, "127.0.0.1";
    is $got_port, $proxy_port;
    is $proxy_got->[0], "CONNECT this.never.exist.i.guess.com:5500 HTTP/1.1\r\nHost: this.never.exist.i.guess.com:5500\r\n\r\n";
    is $proxy_got->[1], "data submitted\n";
    is_deeply $proxy_got->[2], [];
};

done_testing;
