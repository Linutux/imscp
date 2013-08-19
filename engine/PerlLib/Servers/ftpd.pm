#!/usr/bin/perl

=head1 NAME

 Servers::ftpd - i-MSCP FTPD Server implementation

=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010-2013 by internet Multi Server Control Panel
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @category    i-MSCP
# @copyright   2010-2013 by i-MSCP | http://i-mscp.net
# @author      Daniel Andreca <sci2tech@gmail.com>
# @author      Laurent Declercq <l.declercq@nuxwin.com>
# @link        http://i-mscp.net i-MSCP Home Site
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Servers::ftpd;

use strict;
use warnings;

use iMSCP::Debug;

my $instance = undef;

=head1 DESCRIPTION

 i-MSCP FTPD server implementation.

=head1 CLASS METHODS

=over 4

=item factory([$server = $main::imscpConfig{'FTPD_SERVER'}]))

 Factory

 Return Servers::ftpd::proftpd|Servers::noserver

=cut

sub factory($;$)
{
	if(! defined $instance) {
		my $self = shift;
		my $server = shift || $main::imscpConfig{'FTPD_SERVER'};
		my ($file, $class);

		if(lc($server) eq 'no') {
			$file = 'Servers/noserver.pm';
			$class = 'Servers::noserver';
		} else {
			$file = "Servers/ftpd/$server.pm";
			$class = "Servers::ftpd::$server";
		}

		eval { require $file };
		fatal($@) if $@;

		$instance = $class->getInstance();
	}

	$instance;
}

=back

=head1 AUTHORS

 Daniel Andreca <sci2tech@gmail.com>
 Laurent Declercq <l.declercq@nuxwin.com>

=cut

1;
