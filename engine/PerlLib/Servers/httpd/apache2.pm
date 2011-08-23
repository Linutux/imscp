#!/usr/bin/perl

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010 - 2011 by internet Multi Server Control Panel
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
# @category		i-MSCP
# @copyright	2010 - 2011 by i-MSCP | http://i-mscp.net
# @author		Daniel Andreca <sci2tech@gmail.com>
# @version		SVN: $Id$
# @link			http://i-mscp.net i-MSCP Home Site
# @license		http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Servers::httpd::apache2;

use strict;
use warnings;
use iMSCP::Debug;

use vars qw/@ISA/;

@ISA = ('Common::SingletonClass', 'Common::SetterClass');
use Common::SingletonClass;
use Common::SetterClass;

sub _init{
	debug((caller(0))[3].': Starting...');

	my $self				= shift;
	$self->{hasPHP}			= undef;
	$self->{hasCGI}			= undef;
	$self->{isAlias}		= undef;
	$self->{isSub}			= undef;
	$self->{parentDMN}		= undef;
	$self->{masterConf}		= '00_master.conf';
	$self->{masterSSLConf}	= '00_master_ssl.conf';

	$self->{cfgDir} = "$main::imscpConfig{'CONF_DIR'}/apache";
	$self->{bkpDir} = "$self->{cfgDir}/backup";
	$self->{wrkDir} = "$self->{cfgDir}/working";

	$self->{$_} = $main::imscpConfig{$_} foreach(keys %main::imscpConfig);

	debug((caller(0))[3].': Ending...');
	0;
}

sub buildConfFile{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $fileName		= shift;

	use iMSCP::File;
	use iMSCP::Templator;
	use iMSCP::Execute;

	my ($rs, $cfgTpl, $file);


	if(-f "$main::imscpConfig{'APACHE_SITES_DIR'}/$fileName") {
		iMSCP::File->new(filename => "$main::imscpConfig{'APACHE_SITES_DIR'}/$fileName")->copyFile("$self->{bkpDir}/$fileName." . time()) and return 1;
	}

	$cfgTpl = iMSCP::File->new(filename => "$self->{cfgDir}/$fileName")->get();
	return 1 if(!$cfgTpl);

	my $tplValues = {};

	foreach(keys %{$self}){
		$tplValues->{$_} = $self->{$_};
	}

	foreach(@{$self->{preCalls}}){
		eval {$rs = &$_(\$cfgTpl);};
		error((caller(0))[3]."$@");
		return $rs if $rs;
	}

	$cfgTpl = process($tplValues, $cfgTpl);
	return 1 if (!$cfgTpl);

	foreach(@{$self->{postCalls}}){
		eval {$rs = &$_(\$cfgTpl);};
		error((caller(0))[3]."$@");
		return $rs if $rs;
	}

	$file = iMSCP::File->new(filename => "$self->{wrkDir}/$fileName");
	$file->set($cfgTpl) and return 1;
	$file->save() and return 1;
	$file->mode(0644) and return 1;
	$file->owner($main::imscpConfig{'ROOT_USER'}, $main::imscpConfig{'ROOT_GROUP'}) and return 1;

	# Installing the new file
	$file->copyFile("$main::imscpConfig{'APACHE_SITES_DIR'}/") and return 1;

	debug((caller(0))[3].': Ending...');
	0;
}

sub registerPreCall{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $callback		= shift;

	push (@{$self->{preCalls}}, $callback) if (ref $callback eq 'CODE');

	debug((caller(0))[3].': Ending...');
	0;
}

sub registerPostCall{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $callback		= shift;

	push (@{$self->{postCalls}}, $callback) if (ref $callback eq 'CODE');

	debug((caller(0))[3].': Ending...');
	0;
}

sub test{
	debug((caller(0))[3].': Starting...');
	my $self = shift;
	my $param = shift;
	debug((caller(0))[3].': Ending...');
	0;
}
sub enableSite{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $fileName		= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	if (-f '/usr/sbin/a2ensite') {
		$rs = execute("/usr/sbin/a2ensite $fileName", \$stdout, \$stderr);
		debug((caller(0))[3].": $stdout") if($stdout);
		error((caller(0))[3].": $stderr") if($stderr);
		return $rs if $rs;
	}

	debug((caller(0))[3].': Ending...');
	0;
}

sub disableSite{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $fileName		= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	if (-f '/usr/sbin/a2dissite') {
		$rs = execute("/usr/sbin/a2dissite $fileName", \$stdout, \$stderr);
		debug((caller(0))[3].": stdout $stdout") if($stdout);
		error((caller(0))[3].": stderr $stderr") if($stderr);
		return $rs if $rs;
	}

	debug((caller(0))[3].': Ending...');
	0;
}

sub enableMod{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $fileName		= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	if(! -f '/etc/SuSE-release' && -f '/usr/sbin/a2enmod') {
		$rs = execute("/usr/sbin/a2enmod $fileName", \$stdout, \$stderr);
		debug((caller(0))[3].": $stdout") if($stdout);
		error((caller(0))[3].": $stderr") if($stderr);
		return $rs if $rs;
	}

	debug((caller(0))[3].': Ending...');
	0;
}

sub disableMod{

	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my $fileName		= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	if(! -f '/etc/SuSE-release' && -f '/usr/sbin/a2dismod') {
		$rs = execute("/usr/sbin/a2dismod $fileName", \$stdout, \$stderr);
		debug((caller(0))[3].": $stdout") if($stdout);
		error((caller(0))[3].": $stderr") if($stderr);
		return $rs if $rs;
	}

	debug((caller(0))[3].': Ending...');
	0;
}

sub restart{
	debug((caller(0))[3].': Starting...');

	my $self			= shift;
	my ($rs, $stdout, $stderr);

	use iMSCP::Execute;

	# Reload apache config
	$rs = execute("$main::imscpConfig{'CMD_HTTPD'} reload", \$stdout, \$stderr);
	debug((caller(0))[3].": $stdout") if $stdout;
	error((caller(0))[3].": $stderr") if $stderr;
	return $rs if $rs;

	debug((caller(0))[3].': Ending...');
	0;
}

1;