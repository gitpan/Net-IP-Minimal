package Net::IP::Minimal;
{
  $Net::IP::Minimal::VERSION = '0.04';
}

#ABSTRACT: Minimal functions from Net::IP

use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(ip_get_version ip_is_ipv4 ip_is_ipv6);
our %EXPORT_TAGS = ( 'PROC' => [ @EXPORT_OK ] );

sub ip_get_version {
    my $ip = shift;

    # If the address does not contain any ':', maybe it's IPv4
    $ip !~ /:/ and ip_is_ipv4($ip) and return '4';

    # Is it IPv6 ?
    ip_is_ipv6($ip) and return '6';

    return;
}

sub ip_is_ipv4 {
  my @field = split /\./, shift;

  return 0 if @field > 4;       # too many fields
  return 0 if @field == 0;      # no fields at all

  foreach ( @field ) {
    return 0 unless /./;      # reject if empty
    return 0 if /[^0-9]/;     # reject non-digit
    return 0 if $_ > 255;     # reject bad value
  }

  return 1;
}


sub ip_is_ipv6 {
  for ( shift ) {
    my @field = split /:/;      # split into fields
    return 0 if (@field < 3) or (@field > 8);

    return 0 if /::.*::/;     # reject multiple ::

    if ( /\./ ) {       # IPv6:IPv4
      return 0 unless ip_is_ipv4(pop @field);
    }

    foreach ( @field ) {
      next unless /./;    # skip ::
      return 0 if /[^0-9a-f]/i; # reject non-hexdigit
      return 0 if length $_ > 4;  # reject bad value
    }
  }
  return 1;
}


qq[IP freely];

__END__

=pod

=head1 NAME

Net::IP::Minimal - Minimal functions from Net::IP

=head1 VERSION

version 0.04

=head1 SYNOPSIS

  use Net::IP::Minimal qw[:PROC];

  my $ip = '172.16.0.216';

  ip_is_ipv4( $ip ) and print "$ip is IPv4";

  $ip = 'dead:beef:89ab:cdef:0123:4567:89ab:cdef';

  ip_is_ipv6( $ip ) and print "$ip is IPv6";

  print ip_get_version( $ip );

=head1 DESCRIPTION

L<Net::IP> is very feature complete, but I found I was only using three of its functions
and it uses quite a bit of memory L<https://rt.cpan.org/Public/Bug/Display.html?id=24525>.

This module only provides the minimal number of functions that I use in my modules.

=head1 FUNCTIONS

The same as L<Net::IP> these functions are not exported by default. You may import them explicitly
or use C<:PROC> to import them all.

=over

=item C<ip_get_version>

Try to guess the IP version of an IP address.

    Params  : IP address
    Returns : 4, 6, undef(unable to determine)

C<$version = ip_get_version ($ip)>

=item C<ip_is_ipv4>

Check if an IP address is of type 4.

    Params  : IP address
    Returns : 1 (yes) or 0 (no)

C<ip_is_ipv4($ip) and print "$ip is IPv4";>

=item C<ip_is_ipv6>

Check if an IP address is of type 6.

    Params            : IP address
    Returns           : 1 (yes) or 0 (no)

C<ip_is_ipv6($ip) and print "$ip is IPv6";>

=back

=head1 SEE ALSO

L<Net::IP>

=head1 AUTHOR

Chris Williams <chris@bingosnet.co.uk>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Chris Williams and RIPE-NCC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
